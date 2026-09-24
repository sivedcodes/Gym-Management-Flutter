import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/auth/session.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/brand.dart';
import '../../../core/widgets/chips.dart';
import '../../../core/widgets/motion.dart';
import '../../../core/widgets/state_views.dart';

/// Full history screen for membership registrations and program bookings.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

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
      appBar: AppBar(title: const Text('History')),
      body: MaxWidth(
        child: (regs.isEmpty && bookings.isEmpty)
            ? const EmptyView(
                icon: AppIcons.history,
                title: 'No requests yet',
                subtitle:
                    'Your membership and program history will appear here.',
              )
            : ListView(
                padding: AppSpace.list,
                children: [
                  FadeSlideIn(
                    child: Text(
                      'Your activity log',
                      style: AppText.display,
                    ),
                  ),
                  const SizedBox(height: AppSpace.xs),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 60),
                    child: Text(
                      'Track your membership and program approvals.',
                      style: AppText.small,
                    ),
                  ),
                  const SizedBox(height: AppSpace.sectionGap),

                  if (regs.isNotEmpty) ...[
                    const SectionHeader(title: 'Membership Registrations'),
                    const SizedBox(height: AppSpace.s),
                    ...regs.map(
                      (r) => Card(
                        margin: const EdgeInsets.only(bottom: AppSpace.s),
                        child: ListTile(
                          leading: IconTile(
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
                    const SizedBox(height: AppSpace.m),
                  ],

                  if (bookings.isNotEmpty) ...[
                    const SectionHeader(title: 'Program Enrolments'),
                    const SizedBox(height: AppSpace.s),
                    ...bookings.map(
                      (b) => Card(
                        margin: const EdgeInsets.only(bottom: AppSpace.s),
                        child: ListTile(
                          leading: IconTile(
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
                ],
              ),
      ),
    );
  }
}
