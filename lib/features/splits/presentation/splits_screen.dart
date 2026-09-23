import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/session.dart';
import '../../../core/models/app_models.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/brand.dart';
import '../../../core/widgets/chips.dart';
import '../../../core/widgets/motion.dart';
import '../auth/presentation/setup_screen.dart' show WeekPreview;

/// Workout splits catalog. Members pick one and follow the weekly
/// chart; owners manage the catalog (add/edit/show-hide, incl. days).
class SplitsScreen extends ConsumerWidget {
  const SplitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(fakeDbProvider);
    final me = ref.watch(currentUserProvider);
    final isOwner = me?.role == 'owner';
    final items = isOwner
        ? (db.splits.values.toList()
          ..sort((a, b) => a.name.compareTo(b.name)))
        : db.activeSplits();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout splits'),
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(AppIcons.add),
              tooltip: 'New split',
              onPressed: () => _splitDialog(context, ref, null),
            ),
        ],
      ),
      body: MaxWidth(
        child: items.isEmpty
            ? const Center(
                child: Text('No splits yet.',
                    style: AppText.small))
            : ListView.builder(
                padding: AppSpace.list,
                itemCount: items.length,
                itemBuilder: (_, i) => FadeSlideIn(
                  delay: Duration(milliseconds: i * 60),
                  child: _SplitCard(
                    split: items[i],
                    mine: me?.splitId == items[i].id,
                    isOwner: isOwner,
                    onOpen: () =>
                        _detailSheet(context, ref, items[i]),
                    onEdit: () => _splitDialog(
                        context, ref, items[i]),
                    onToggle: () => db.upsertSplit(
                      items[i]
                          .copyWith(active: !items[i].active),
                    ),
                    onPick: () {
                      final uid =
                          ref.read(currentUidProvider);
                      if (uid != null) {
                        db.pickSplit(uid, items[i].id);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          SnackBar(
                              content: Text(
                                  '${items[i].name} selected.')),
                        );
                      }
                    },
                  ),
                ),
              ),
      ),
    );
  }

  void _detailSheet(
      BuildContext context, WidgetRef ref, WorkoutSplit split) {
    final me = ref.read(currentUserProvider);
    final isOwner = me?.role == 'owner';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: AppSpace.m),
              Text(split.desc, style: AppText.small),
              const SizedBox(height: AppSpace.m),
              WeekPreview(
                  split: split, highlightToday: true),
              const SizedBox(height: AppSpace.m),
              if (!isOwner)
                ElevatedButton(
                  onPressed: () {
                    final uid =
                        ref.read(currentUidProvider);
                    if (uid != null) {
                      ref
                          .read(fakeDbProvider)
                          .pickSplit(uid, split.id);
                    }
                    Navigator.pop(context);
                  },
                  child: Text(me?.splitId == split.id
                      ? 'Current split'
                      : 'Follow this split'),
                )
              else
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _splitDialog(context, ref, split);
                  },
                  icon: const Icon(AppIcons.edit,
                      size: AppIcon.sm),
                  label: const Text('Edit split'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _splitDialog(
      BuildContext context, WidgetRef ref, WorkoutSplit? e) {
    final name = TextEditingController(text: e?.name ?? '');
    final desc = TextEditingController(text: e?.desc ?? '');
    var level = e?.level ?? 'Intermediate';
    final dayCtrls = List.generate(
      7,
      (i) => TextEditingController(
          text: e?.days[i].focus ?? ''),
    );
    final rest =
        List.generate(7, (i) => e?.days[i].rest ?? (i == 6));
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final form = GlobalKey<FormState>();

    WorkoutSplit build() => WorkoutSplit(
          id: e?.id ?? 'split_${DateTime.now().millisecondsSinceEpoch}',
          name: name.text.trim(),
          desc: desc.text.trim(),
          level: level,
          active: e?.active ?? true,
          days: [
            for (var i = 0; i < 7; i++)
              SplitDay(
                  day: days[i],
                  focus: rest[i]
                      ? 'Rest & recovery'
                      : dayCtrls[i].text.trim().isEmpty
                          ? 'Training'
                          : dayCtrls[i].text.trim(),
                  rest: rest[i]),
          ],
        );

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title:
              Text(e == null ? 'New split' : 'Edit split'),
          content: Form(
            key: form,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: name,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      prefixIcon:
                          Icon(AppIcons.label),
                    ),
                    validator: (v) =>
                        (v ?? '').trim().isEmpty
                            ? 'Required'
                            : null,
                  ),
                  const SizedBox(height: AppSpace.s),
                  TextFormField(
                    controller: desc,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      prefixIcon:
                          Icon(AppIcons.desc),
                    ),
                  ),
                  const SizedBox(height: AppSpace.s),
                  DropdownButtonFormField<String>(
                    initialValue: level,
                    decoration: const InputDecoration(
                        labelText: 'Level'),
                    items: const [
                      'All',
                      'Beginner',
                      'Intermediate',
                      'Advanced'
                    ]
                        .map((l) => DropdownMenuItem(
                            value: l,
                            child: Text(l)))
                        .toList(),
                    onChanged: (v) =>
                        setD(() => level = v ?? level),
                  ),
                  const SizedBox(height: AppSpace.m),
                  ...List.generate(7, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(
                          bottom: AppSpace.s),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 44,
                            child: Text(days[i],
                                style: AppText.label),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: dayCtrls[i],
                              enabled: !rest[i],
                              decoration: InputDecoration(
                                labelText: rest[i]
                                    ? 'Rest'
                                    : 'Focus',
                                isDense: true,
                              ),
                            ),
                          ),
                          Checkbox(
                            value: rest[i],
                            activeColor:
                                AppColors.yellow,
                            onChanged: (v) => setD(
                                () => rest[i] = v ?? false),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!form.currentState!.validate()) {
                  return;
                }
                ref
                    .read(fakeDbProvider)
                    .upsertSplit(build());
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplitCard extends StatelessWidget {
  final WorkoutSplit split;
  final bool mine;
  final bool isOwner;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onPick;
  const _SplitCard({
    required this.split,
    required this.mine,
    required this.isOwner,
    required this.onOpen,
    required this.onEdit,
    required this.onToggle,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin:
          const EdgeInsets.only(bottom: AppSpace.cardGap),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.l),
        onTap: onOpen,
        child: Padding(
          padding: AppSpace.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const IconTile(AppIcons.training,
                      size: AppIcon.tile),
                  const SizedBox(width: AppSpace.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(split.name,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: AppText.title),
                        Text(
                          '${split.level} · ${split.days.where((d) => !d.rest).length} training days',
                          style: AppText.tiny,
                        ),
                      ],
                    ),
                  ),
                  if (mine && !isOwner)
                    const StatusChip('active'),
                  if (!split.active && isOwner)
                    Text('HIDDEN',
                        style: AppText.label.copyWith(
                            color: AppColors.red)),
                ],
              ),
              if (split.desc.isNotEmpty) ...[
                const SizedBox(height: AppSpace.s),
                Text(split.desc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.small),
              ],
              const SizedBox(height: AppSpace.m),
              if (isOwner)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(AppIcons.edit,
                            size: AppIcon.sm),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                            minimumSize:
                                const Size(48, 44)),
                      ),
                    ),
                    const SizedBox(width: AppSpace.s),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onToggle,
                        icon: Icon(
                            split.active
                                ? AppIcons.hide
                                : AppIcons.show,
                            size: AppIcon.sm),
                        label: Text(split.active
                            ? 'Hide'
                            : 'Show'),
                        style: OutlinedButton.styleFrom(
                            minimumSize:
                                const Size(48, 44)),
                      ),
                    ),
                  ],
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: mine
                      ? OutlinedButton.icon(
                          onPressed: onOpen,
                          icon: const Icon(
                              AppIcons.forward,
                              size: AppIcon.sm),
                          label: const Text(
                              'View weekly chart'),
                          style:
                              OutlinedButton.styleFrom(
                                  minimumSize:
                                      const Size(48, 46)),
                        )
                      : ElevatedButton(
                          onPressed: onPick,
                          style:
                              ElevatedButton.styleFrom(
                                  minimumSize:
                                      const Size(48, 46)),
                          child:
                              const Text('Follow split'),
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
