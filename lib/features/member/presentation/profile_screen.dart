import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/auth/session.dart';
import '../../../core/models/app_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/tokens.dart';
import '../../music/state/gym_player.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/brand.dart';
import '../../../core/widgets/chips.dart';
import '../../../core/widgets/rush_chart.dart';
import '../../../core/widgets/motion.dart';
import '../../../core/widgets/state_views.dart';

/// Member profile: identity, phone edit, full request history, logout.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(fakeDbProvider);
    final me = ref.watch(currentUserProvider);
    if (me == null) {
      return const Scaffold(body: LoadingView(message: 'Loading…'));
    }
    final regs = db.registrations.values.where((r) => r.uid == me.uid).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final bookings = db.myBookings(me.uid);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: MaxWidth(
        child: ListView(
          padding: AppSpace.list,
          children: [
            // ── Identity card ──
            FadeSlideIn(
              child: Container(
                padding: AppSpace.card,
                decoration: BoxDecoration(
                  gradient: AppGradients.yellowCard,
                  borderRadius: BorderRadius.circular(AppRadius.l),
                  border: Border.all(
                    color: AppColors.yellow.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    InitialAvatar(me.name, radius: 30),
                    const SizedBox(width: AppSpace.l),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            me.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.displaySm,
                          ),
                          Text(
                            me.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.small,
                          ),
                          const SizedBox(height: AppSpace.xs),
                          Row(
                            children: [
                              const Icon(
                                AppIcons.phoneAlt,
                                size: AppIcon.xs,
                                color: AppColors.yellow,
                              ),
                              const SizedBox(width: AppSpace.xs),
                              Flexible(
                                child: Text(
                                  '+91 ${me.phone ?? '—'}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppText.label.copyWith(
                                    color: AppColors.yellow,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(AppIcons.edit, color: AppColors.grey),
                      tooltip: 'Edit phone',
                      onPressed: () => _editPhone(context, ref, me.phone ?? ''),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpace.l),

            // ── Body stats & goal ──
            Card(
              child: Padding(
                padding: AppSpace.card,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('Body stats', style: AppText.title),
                        ),
                        TextButton(
                          onPressed: () => context.push('/setup'),
                          child: const Text('Edit'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpace.s),
                    Row(
                      children: [
                        _StatMini(
                          label: 'Weight',
                          value: me.weightKg == null
                              ? '—'
                              : '${_num(me.weightKg!)} kg',
                        ),
                        const SizedBox(width: AppSpace.s),
                        _StatMini(label: 'Height', value: me.heightLabel),
                        const SizedBox(width: AppSpace.s),
                        _StatMini(
                          label: 'BMI',
                          value: me.bmi == null
                              ? '—'
                              : me.bmi!.toStringAsFixed(1),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpace.s),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpace.m,
                        vertical: AppSpace.s,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.s),
                      ),
                      child: Row(
                        children: [
                          const IconTile(AppIcons.goal, size: 36),
                          const SizedBox(width: AppSpace.s),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _goalText(me),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppText.title,
                                ),
                                if (me.bmi != null)
                                  Text(
                                    'BMI: ${AppUser.bmiCategory(me.bmi!)}',
                                    style: AppText.small,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpace.l),

            // ── Settings card ──
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const IconTile(AppIcons.bell, size: AppIcon.tile),
                    title: Text('Notifications', style: AppText.title),
                    trailing: const Icon(AppIcons.next, color: AppColors.grey),
                    onTap: () => context.push('/notices'),
                  ),
                  const Divider(
                    height: 1,
                    indent: AppSpace.l,
                    endIndent: AppSpace.l,
                  ),
                  ListTile(
                    leading: const IconTile(
                      AppIcons.qrShow,
                      size: AppIcon.tile,
                    ),
                    title: Text('Gym QR', style: AppText.title),
                    subtitle: Text('Share with friends', style: AppText.small),
                    trailing: const Icon(AppIcons.next, color: AppColors.grey),
                    onTap: () => context.push('/join?gym=demo-gym'),
                  ),
                  const Divider(
                    height: 1,
                    indent: AppSpace.l,
                    endIndent: AppSpace.l,
                  ),
                  ListTile(
                    leading: const IconTile(
                      AppIcons.training,
                      size: AppIcon.tile,
                    ),
                    title: Text('Workout split', style: AppText.title),
                    subtitle: Text(
                      db.splitOf(me)?.name ?? 'Not selected',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.small,
                    ),
                    trailing: const Icon(AppIcons.next, color: AppColors.grey),
                    onTap: () => context.push('/splits'),
                  ),
                  const Divider(
                    height: 1,
                    indent: AppSpace.l,
                    endIndent: AppSpace.l,
                  ),
                  ListTile(
                    leading: const IconTile(
                      AppIcons.calendar,
                      size: AppIcon.tile,
                    ),
                    title: Text('My gym timing', style: AppText.title),
                    subtitle: Text(
                      me.slotLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.small,
                    ),
                    trailing: const Icon(AppIcons.edit, color: AppColors.grey),
                    onTap: () => showSlotDialog(
                      context,
                      ref,
                      initialSession: me.slotSession,
                      initialFrom: me.slotFrom,
                      initialTo: me.slotTo,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.l),

            // ── History ──
            const SectionHeader(title: 'History'),
            const SizedBox(height: AppSpace.sectionHeaderGap),
            if (regs.isEmpty && bookings.isEmpty)
              const EmptyView(
                icon: AppIcons.history,
                title: 'No requests yet',
                subtitle:
                    'Your membership and program history will appear here.',
              )
            else ...[
              ...regs.map(
                (r) => Card(
                  margin: const EdgeInsets.only(top: AppSpace.s),
                  child: ListTile(
                    leading: const IconTile(
                      AppIcons.membershipOut,
                      size: AppIcon.tile,
                    ),
                    title: Text(
                      'Membership · ${r.planName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.title,
                    ),
                    subtitle: Text(
                      '₹${r.price} · ${DateFormat('dd MMM yyyy').format(r.createdAt)}'
                      '${r.status == 'denied' && (r.reason ?? '').isNotEmpty ? ' · ${r.reason}' : ''}',
                      style: AppText.tiny,
                    ),
                    trailing: StatusChip(r.status),
                  ),
                ),
              ),
              ...bookings.map(
                (b) => Card(
                  margin: const EdgeInsets.only(top: AppSpace.s),
                  child: ListTile(
                    leading: const IconTile(
                      AppIcons.programs,
                      size: AppIcon.tile,
                    ),
                    title: Text(
                      'Program · ${b.title}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.title,
                    ),
                    subtitle: Text(
                      '${b.kind} · ${DateFormat('dd MMM yyyy').format(b.createdAt)}',
                      style: AppText.tiny,
                    ),
                    trailing: StatusChip(b.status),
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpace.xl),

            // ── Logout ──
            OutlinedButton.icon(
              onPressed: () async {
                await ref.read(gymPlayerProvider).stop();
                logout(ref);
              },
              icon: const Icon(AppIcons.logout, size: AppIcon.btn),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.red,
                side: const BorderSide(color: Color(0x66FF6B6B)),
              ),
            ),
            const SizedBox(height: AppSpace.m),
            const Center(child: DeveloperCredit()),
            const SizedBox(height: AppSpace.xs),
            Center(child: Text('Total Fit Gym · v1.0.0', style: AppText.tiny)),
          ],
        ),
      ),
    );
  }

  void _editPhone(BuildContext context, WidgetRef ref, String current) {
    final ctrl = TextEditingController(text: current);
    final form = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit mobile number'),
        content: Form(
          key: form,
          child: TextFormField(
            controller: ctrl,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            decoration: const InputDecoration(
              prefixText: '+91  ',
              counterText: '',
            ),
            validator: (v) {
              final d = (v ?? '').replaceAll(RegExp(r'\D'), '');
              return d.length != 10 ? 'Enter a valid 10-digit number' : null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (!form.currentState!.validate()) return;
              final uid = ref.read(currentUidProvider);
              if (uid != null) {
                ref.read(fakeDbProvider).savePhone(uid, ctrl.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

String _num(double v) => v == v.roundToDouble() ? '${v.toInt()}' : '$v';

String _goalText(AppUser u) => switch (u.goal) {
  'gain' => 'Goal: Gain ${u.targetKg == null ? '' : '${_num(u.targetKg!)} kg'}',
  'loss' => 'Goal: Lose ${u.targetKg == null ? '' : '${_num(u.targetKg!)} kg'}',
  'maintain' => 'Goal: Maintain',
  _ => 'Goal not set',
};

class _StatMini extends StatelessWidget {
  final String label;
  final String value;
  const _StatMini({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.m,
          vertical: AppSpace.s,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.s),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppText.tiny),
            const SizedBox(height: AppSpace.xs),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.title,
            ),
          ],
        ),
      ),
    );
  }
}
