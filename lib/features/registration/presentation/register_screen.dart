import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/auth/session.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/brand.dart';
import '../../../core/widgets/motion.dart';
import '../../../core/widgets/state_views.dart';

/// Confirm plan → creates a `pending` registration (one at a time).
class RegisterScreen extends ConsumerStatefulWidget {
  final String? planId;
  const RegisterScreen({super.key, this.planId});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  bool _busy = false;

  Future<void> _submit() async {
    final db = ref.read(fakeDbProvider);
    final me = ref.read(currentUserProvider);
    final plan = db.plans[widget.planId];
    if (me == null || plan == null) return;
    if (db.hasPending(me.uid)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('You already have a pending request. Please wait.')),
      );
      return;
    }
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    db.createRegistration(me, plan);
    setState(() => _busy = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Registered! Owner will approve payment.')),
      );
      context.go(me.role == 'owner' ? '/owner' : '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(fakeDbProvider);
    final me = ref.watch(currentUserProvider);
    final plan = widget.planId == null ? null : db.plans[widget.planId];

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm registration')),
      body: MaxWidth(
        maxWidth: 520,
        child: Padding(
          padding: AppSpace.card,
          child: (me == null || plan == null)
              ? ErrorView(
                  message: 'Plan not found. It may have been removed.',
                  onRetry: () => context.go('/plans'),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FadeSlideIn(
                      child: Container(
                        padding: AppSpace.card,
                        decoration: BoxDecoration(
                          gradient: AppGradients.yellowCard,
                          borderRadius:
                              BorderRadius.circular(AppRadius.l),
                          border: Border.all(
                              color:
                                  AppColors.yellow.withValues(alpha: 0.4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const IconTile(AppIcons.bolt,
                                    size: AppIcon.tile),
                                const SizedBox(width: AppSpace.m),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(plan.name,
                                          style: AppText.displaySm),
                                      Text(
                                        '₹${NumberFormat.decimalPattern('en_IN').format(plan.price)} · ${plan.durationDays} days',
                                        style: AppText.price,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: AppSpace.xxl),
                            _UserRow(
                                icon: AppIcons.profile,
                                text: me.name),
                            const SizedBox(height: AppSpace.xxs),
                            _UserRow(
                                icon: AppIcons.phoneAlt,
                                text: '+91 ${me.phone ?? '—'}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpace.m),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 100),
                      child: Container(
                        padding: AppSpace.card,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius:
                              BorderRadius.circular(AppRadius.m),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(AppIcons.payments,
                                color: AppColors.green,
                                size: AppIcon.list),
                            const SizedBox(width: AppSpace.s),
                            Expanded(
                              child: Text(
                                'Pay at the gym (cash/UPI). Owner verifies '
                                'and taps Approve — membership starts instantly.',
                                style: AppText.small,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 160),
                      child: ElevatedButton.icon(
                        onPressed: _busy ? null : _submit,
                        icon: _busy
                            ? const SizedBox(
                                width: AppIcon.sm,
                                height: AppIcon.sm,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.black),
                              )
                            : const Icon(AppIcons.register,
                                size: AppIcon.btn),
                        label: Text(
                          _busy
                              ? 'Submitting…'
                              : 'Register · ₹${NumberFormat.decimalPattern('en_IN').format(plan.price)}',
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _UserRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: AppIcon.sm, color: AppColors.grey),
        const SizedBox(width: AppSpace.s),
        Text(text, style: AppText.body),
      ],
    );
  }
}
