import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/auth/session.dart';
import '../../../core/models/app_models.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/brand.dart';
import '../../../core/widgets/chips.dart';
import '../../../core/widgets/motion.dart';

/// Post-login profile setup: name, mobile, body stats, goal, BMI,
/// target kg and workout split. Reused later as the edit screen
/// (prefilled, with back navigation).
class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});
  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _weight;
  late final TextEditingController _ft;
  late final TextEditingController _inch;
  late final TextEditingController _target;
  String _goal = 'maintain';
  String? _splitId;
  bool _saving = false;
  bool _init = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _phone = TextEditingController();
    _weight = TextEditingController();
    _ft = TextEditingController();
    _inch = TextEditingController();
    _target = TextEditingController();
    for (final c in [_weight, _ft, _inch]) {
      c.addListener(() => setState(() {})); // live BMI
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _weight.dispose();
    _ft.dispose();
    _inch.dispose();
    _target.dispose();
    super.dispose();
  }

  void _prefill(AppUser me) {
    if (_init) return;
    _init = true;
    _name.text = me.name;
    _phone.text = me.phone ?? '';
    if (me.weightKg != null) {
      _weight.text = _num(me.weightKg!);
    }
    if (me.heightCm != null) {
      final ftIn = AppUser.cmToFtIn(me.heightCm!);
      _ft.text = '${ftIn[0]}';
      _inch.text = '${ftIn[1]}';
    }
    if (me.goal != null) _goal = me.goal!;
    if (me.targetKg != null) _target.text = _num(me.targetKg!);
    _splitId = me.splitId ?? 'split_ppl';
  }

  String _num(double v) => v == v.roundToDouble() ? '${v.toInt()}' : '$v';

  double? get _w => double.tryParse(_weight.text.trim());
  double? get _h {
    final ft = int.tryParse(_ft.text.trim());
    final inch = int.tryParse(_inch.text.trim());
    if (ft == null || inch == null) return null;
    return AppUser.ftInToCm(ft, inch);
  }

  double? get _bmi {
    final w = _w, h = _h;
    if (w == null || h == null || h <= 0) return null;
    return w / ((h / 100) * (h / 100));
  }

  Future<void> _save(bool isEdit) async {
    if (!_form.currentState!.validate()) return;
    if (_splitId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick a workout split below.')),
      );
      return;
    }
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final uid = ref.read(currentUidProvider);
    if (uid != null && mounted) {
      final t = double.tryParse(_target.text.trim());
      ref
          .read(fakeDbProvider)
          .saveProfile(
            uid,
            name: _name.text.trim(),
            phone: _phone.text.trim(),
            weightKg: _w!,
            heightCm: _h!,
            goal: _goal,
            targetKg: _goal == 'maintain' ? null : t,
            splitId: _splitId,
          );
      syncAuthStatus(ref);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit ? 'Profile updated.' : 'Welcome to Total Fit Gym!',
            ),
          ),
        );
        if (isEdit) context.pop();
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(currentUserProvider);
    if (me == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    _prefill(me);
    final isEdit = me.hasProfile;
    final db = ref.watch(fakeDbProvider);
    final splits = db.activeSplits();
    final selected = splits.where((s) => s.id == _splitId).firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit profile' : 'Setup profile'),
        automaticallyImplyLeading: isEdit,
      ),
      body: MaxWidth(
        maxWidth: 560,
        child: Form(
          key: _form,
          child: ListView(
            padding: AppSpace.list,
            children: [
              FadeSlideIn(
                child: Text(
                  isEdit ? 'Keep your stats fresh.' : 'Tell us about yourself.',
                  style: AppText.display,
                ),
              ),
              const SizedBox(height: AppSpace.xs),
              FadeSlideIn(
                delay: const Duration(milliseconds: 60),
                child: Text(
                  'Training plans, BMI and rush insights use this.',
                  style: AppText.small,
                ),
              ),
              const SizedBox(height: AppSpace.sectionGap),
              FadeSlideIn(
                delay: const Duration(milliseconds: 100),
                child: const SectionHeader(title: 'Account'),
              ),
              const SizedBox(height: AppSpace.m),
              _field(
                controller: _name,
                label: 'Full name',
                hint: 'e.g. Rahul Sharma',
                icon: AppIcons.member,
                validator: (v) =>
                    (v ?? '').trim().length < 2 ? 'Enter your name' : null,
              ),
              const SizedBox(height: AppSpace.m),
              TextFormField(
                initialValue: me.email,
                enabled: false,
                style: const TextStyle(color: AppColors.grey),
                decoration: const InputDecoration(
                  labelText: 'Email (cannot be changed)',
                  prefixIcon: Icon(AppIcons.info),
                ),
              ),
              const SizedBox(height: AppSpace.m),
              _field(
                controller: _phone,
                label: 'Mobile number',
                hint: 'e.g. 98765 43210',
                icon: AppIcons.phoneAlt,
                keyboard: TextInputType.phone,
                maxLen: 10,
                prefix: '+91  ',
                validator: (v) {
                  final d = (v ?? '').replaceAll(RegExp(r'\D'), '');
                  return d.length != 10
                      ? 'Enter a valid 10-digit number'
                      : null;
                },
              ),
              const SizedBox(height: AppSpace.sectionGap),
              FadeSlideIn(child: const SectionHeader(title: 'Body stats')),
              const SizedBox(height: AppSpace.m),
              _field(
                controller: _weight,
                label: 'Weight (kg)',
                hint: 'e.g. 70',
                icon: AppIcons.weight,
                keyboard: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  return (n == null || n < 20 || n > 300) ? '20–300 kg' : null;
                },
              ),
              const SizedBox(height: AppSpace.m),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      controller: _ft,
                      label: 'Height (ft)',
                      hint: 'e.g. 5',
                      icon: AppIcons.height,
                      keyboard: TextInputType.number,
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        return (n == null || n < 3 || n > 8) ? '3–8 ft' : null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpace.m),
                  Expanded(
                    child: _field(
                      controller: _inch,
                      label: 'Inches',
                      hint: 'e.g. 9',
                      icon: AppIcons.height,
                      keyboard: TextInputType.number,
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        return (n == null || n < 0 || n > 11)
                            ? '0–11 in'
                            : null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.m),
              _BmiCard(bmi: _bmi),
              const SizedBox(height: AppSpace.sectionGap),
              const SectionHeader(title: 'Goal'),
              const SizedBox(height: AppSpace.m),
              Row(
                children: [
                  for (final g in ['gain', 'loss', 'maintain'])
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: g == 'maintain' ? 0 : AppSpace.s,
                        ),
                        child: _GoalChip(
                          goal: g,
                          selected: _goal == g,
                          onTap: () => setState(() => _goal = g),
                        ),
                      ),
                    ),
                ],
              ),
              if (_goal != 'maintain') ...[
                const SizedBox(height: AppSpace.m),
                _field(
                  controller: _target,
                  label: _goal == 'gain'
                      ? 'How many kg to gain?'
                      : 'How many kg to lose?',
                  hint: 'e.g. 5',
                  icon: AppIcons.goal,
                  keyboard: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) {
                    final n = double.tryParse(v ?? '');
                    return (n == null || n < 1 || n > 100)
                        ? 'Enter 1–100 kg'
                        : null;
                  },
                ),
              ],
              const SizedBox(height: AppSpace.sectionGap),
              SectionHeader(
                title: 'Workout split',
                action: 'View all',
                onAction: () => context.push('/splits'),
              ),
              const SizedBox(height: AppSpace.m),
              SizedBox(
                height: 56,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  children: [
                    for (final s in splits)
                      _SplitPick(
                        split: s,
                        selected: s.id == _splitId,
                        onTap: () => setState(() => _splitId = s.id),
                      ),
                  ],
                ),
              ),
              if (selected != null) ...[
                const SizedBox(height: AppSpace.m),
                WeekPreview(split: selected),
              ],
              const SizedBox(height: AppSpace.sectionGap),
              ElevatedButton.icon(
                onPressed: _saving ? null : () => _save(isEdit),
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.black,
                        ),
                      )
                    : const Icon(AppIcons.forward, size: AppIcon.btn),
                label: Text(
                  _saving
                      ? 'Saving…'
                      : isEdit
                      ? 'Save changes'
                      : 'Continue',
                ),
              ),
              if (!isEdit) ...[
                const SizedBox(height: AppSpace.s),
                TextButton(
                  onPressed: _saving ? null : () => logout(ref),
                  child: const Text('Use a different account'),
                ),
              ],
              const SizedBox(height: AppSpace.xxl),
            ],
          ),
        ),
      ),
    );
  }

  String _goalLabel(String g) => switch (g) {
    'gain' => 'Gain',
    'loss' => 'Lose',
    _ => 'Maintain',
  };

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboard,
    int? maxLen,
    String? prefix,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      maxLength: maxLen,
      style: const TextStyle(color: AppColors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        prefixText: prefix,
        counterText: '',
      ),
      validator: validator,
    );
  }
}

class _BmiCard extends StatelessWidget {
  final double? bmi;
  const _BmiCard({required this.bmi});

  @override
  Widget build(BuildContext context) {
    final color = bmi == null
        ? AppColors.faint
        : bmi! < 18.5
        ? AppColors.blue
        : bmi! < 25
        ? AppColors.green
        : bmi! < 30
        ? AppColors.yellow
        : AppColors.red;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: AppSpace.card,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.l),
        border: Border.all(
          color: (bmi == null ? AppColors.line : color).withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          IconTile(AppIcons.info, color: color, size: 46),
          const SizedBox(width: AppSpace.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your BMI', style: AppText.eyebrow),
                const SizedBox(height: AppSpace.xs),
                Text(
                  bmi == null
                      ? 'Enter weight + height'
                      : '${bmi!.toStringAsFixed(1)} · ${AppUser.bmiCategory(bmi!)}',
                  style: AppText.title.copyWith(
                    color: bmi == null ? AppColors.grey : color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalChip extends StatelessWidget {
  final String goal;
  final bool selected;
  final VoidCallback onTap;

  const _GoalChip({
    required this.goal,
    required this.selected,
    required this.onTap,
  });

  IconData get _icon => switch (goal) {
        'gain' => AppIcons.goalGain,
        'loss' => AppIcons.goalLoss,
        _ => AppIcons.goalMaintain,
      };

  String get _title => switch (goal) {
        'gain' => 'Gain',
        'loss' => 'Lose',
        _ => 'Maintain',
      };

  String get _subtitle => switch (goal) {
        'gain' => 'Muscle',
        'loss' => 'Fat burn',
        _ => 'Stay fit',
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.yellow : AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.l),
          border: Border.all(
            color: selected ? AppColors.yellow : AppColors.line,
            width: selected ? 1.5 : 1.0,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.yellow.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _icon,
              size: 20,
              color: selected ? AppColors.black : AppColors.yellow,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _title,
                      style: AppText.label.copyWith(
                        fontWeight: FontWeight.w700,
                        color: selected ? AppColors.black : AppColors.white,
                      ),
                    ),
                    Text(
                      _subtitle,
                      style: AppText.tiny.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? AppColors.black.withValues(alpha: 0.75)
                            : AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplitPick extends StatelessWidget {
  final WorkoutSplit split;
  final bool selected;
  final VoidCallback onTap;
  const _SplitPick({
    required this.split,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 142,
        height: 56,
        margin: const EdgeInsets.only(right: AppSpace.s),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.yellow : AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.l),
          border: Border.all(
            color: selected ? AppColors.yellow : AppColors.line,
            width: selected ? 1.5 : 1.0,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.yellow.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              AppIcons.splitIcon(split.id),
              size: 20,
              color: selected ? AppColors.black : AppColors.yellow,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    split.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.label.copyWith(
                      fontWeight: FontWeight.w700,
                      color: selected ? AppColors.black : AppColors.white,
                    ),
                  ),
                  Text(
                    '${split.level} · ${split.days.where((d) => !d.rest).length}d',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.tiny.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? AppColors.black.withValues(alpha: 0.75)
                          : AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 7-day chart preview for the selected split.
class WeekPreview extends StatelessWidget {
  final WorkoutSplit split;
  final bool highlightToday;
  const WeekPreview({
    super.key,
    required this.split,
    this.highlightToday = false,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().weekday - 1;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: AppSpace.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    split.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.title,
                  ),
                ),
                Text(split.level, style: AppText.tiny),
              ],
            ),
            const SizedBox(height: AppSpace.m),
            ...split.days.asMap().entries.map((e) {
              final d = e.value;
              final isToday = highlightToday && e.key == today;
              return Container(
                margin: const EdgeInsets.only(bottom: AppSpace.s),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.m,
                  vertical: AppSpace.s,
                ),
                decoration: BoxDecoration(
                  color: isToday
                      ? AppColors.yellow.withValues(alpha: 0.12)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.s),
                  border: Border.all(
                    color: isToday
                        ? AppColors.yellow.withValues(alpha: 0.5)
                        : AppColors.line,
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Text(
                        d.day,
                        style: AppText.label.copyWith(
                          color: isToday ? AppColors.yellow : AppColors.grey,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        d.rest ? 'Rest' : d.focus,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: (d.rest ? AppText.small : AppText.body).copyWith(
                          color: d.rest ? AppColors.faint : null,
                        ),
                      ),
                    ),
                    if (isToday)
                      Text(
                        'TODAY',
                        style: AppText.navLabel.copyWith(
                          color: AppColors.yellow,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
