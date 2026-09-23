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
import '../../../core/widgets/chips.dart';
import '../../../core/widgets/motion.dart';
import '../../../core/widgets/state_views.dart';

/// Book a service / enrol in a program. Members only.
class BookServiceScreen extends ConsumerStatefulWidget {
  final String? serviceId;
  const BookServiceScreen({super.key, this.serviceId});
  @override
  ConsumerState<BookServiceScreen> createState() =>
      _BookServiceScreenState();
}

class _BookServiceScreenState extends ConsumerState<BookServiceScreen> {
  bool _busy = false;

  Future<void> _book() async {
    final db = ref.read(fakeDbProvider);
    final me = ref.read(currentUserProvider);
    final item = db.services[widget.serviceId];
    if (me == null || item == null) return;
    if (db.hasPendingService(me.uid, item.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Already enrolled or pending for this program.')),
      );
      return;
    }
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    db.requestService(me, item);
    setState(() => _busy = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(item.isFree
              ? 'Enrolled! Check your programs on the home screen.'
              : 'Request sent. Owner will approve payment.'),
        ),
      );
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(fakeDbProvider);
    final me = ref.watch(currentUserProvider);
    final item = widget.serviceId == null ? null : db.services[widget.serviceId];

    return Scaffold(
      appBar: AppBar(title: const Text('Program details')),
      body: MaxWidth(
        maxWidth: 520,
        child: Padding(
          padding: AppSpace.card,
          child: (me == null || item == null)
              ? ErrorView(
                  message:
                      'Program not found. It may have been removed.',
                  onRetry: () => context.go('/services'),
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
                                IconTile(
                                  switch (item.kind) {
                                    'training' =>
                                      AppIcons.training,
                                    'diet' =>
                                      AppIcons.diet,
                                    'yoga' =>
                                      AppIcons.yoga,
                                    _ =>
                                      AppIcons.genericProgram,
                                  },
                                  size: AppIcon.tile,
                                ),
                                const SizedBox(width: AppSpace.m),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(item.title,
                                          style: AppText.displaySm),
                                      Text(
                                        item.isFree
                                            ? 'FREE'
                                            : '₹${NumberFormat.decimalPattern('en_IN').format(item.price)}',
                                        style: AppText.price,
                                      ),
                                    ],
                                  ),
                                ),
                                StatusChip(
                                    item.isFree ? 'approved' : 'pending'),
                              ],
                            ),
                            const Divider(height: AppSpace.sectionGap),
                            Wrap(
                              spacing: AppSpace.l,
                              runSpacing: AppSpace.xs,
                              children: [
                                _Detail(
                                    AppIcons.goal, item.goal),
                                _Detail(
                                    AppIcons.level,
                                    item.level),
                                _Detail(AppIcons.calendar,
                                    '${item.durationDays} days'),
                              ],
                            ),
                            if (item.desc.isNotEmpty) ...[
                              const SizedBox(height: AppSpace.s),
                              Text(item.desc, style: AppText.small),
                            ],
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
                            const Icon(AppIcons.info,
                                color: AppColors.blue,
                                size: AppIcon.list),
                            const SizedBox(width: AppSpace.m - 2),
                            Expanded(
                              child: Text(
                                item.isFree
                                    ? 'Free program — you\'ll be enrolled instantly. Start whenever you\'re ready!'
                                    : 'Pay at the gym. Owner verifies and activates your program within 24 hrs.',
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
                        onPressed: _busy ? null : _book,
                        icon: _busy
                            ? const SizedBox(
                                width: AppIcon.sm,
                                height: AppIcon.sm,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.black),
                              )
                            : Icon(
                                item.isFree
                                    ? AppIcons.check
                                    : AppIcons.send,
                                size: AppIcon.btn),
                        label: Text(
                          _busy
                              ? 'Processing…'
                              : item.isFree
                                  ? 'Enroll now — free'
                                  : 'Request · ₹${NumberFormat.decimalPattern('en_IN').format(item.price)}',
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

class _Detail extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Detail(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppIcon.xs, color: AppColors.yellow),
        const SizedBox(width: AppSpace.xs),
        Text(text, style: AppText.small.copyWith(color: AppColors.grey)),
      ],
    );
  }
}
