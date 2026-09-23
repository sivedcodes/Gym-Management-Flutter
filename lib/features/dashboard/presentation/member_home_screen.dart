import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/auth/session.dart';
import '../../../core/data/fake_db.dart';
import '../../../core/models/app_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/brand.dart';
import '../../../core/widgets/chips.dart';
import '../../../core/widgets/motion.dart';
import '../../../core/widgets/rush_chart.dart';
import '../../../core/widgets/state_views.dart';
import '../../member/presentation/member_shell.dart';

/// Top active programs for the home carousel.
List<ServiceItem> _featured(FakeDb db) => db.servicesList().take(5).toList();

/// Member home: greeting header, membership hero, quick actions, requests.
class MemberHomeScreen extends ConsumerWidget {
  const MemberHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(fakeDbProvider);
    final me = ref.watch(currentUserProvider);
    if (me == null) {
      return const Scaffold(body: LoadingView(message: 'Loading…'));
    }
    final mem = db.memberships[me.uid];
    final myRegs = db.registrations.values
        .where((r) => r.uid == me.uid)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final pending = myRegs.where((r) => r.status == 'pending').firstOrNull;
    final programs = db.myActivePrograms(me.uid);
    final pendingPrograms = db
        .myBookings(me.uid)
        .where((b) => b.status == 'pending')
        .toList();

    return Scaffold(
      body: MaxWidth(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              title: Row(
                children: [
                  InitialAvatar(me.name, radius: 18),
                  const SizedBox(width: AppSpace.s),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome back', style: AppText.eyebrow),
                      Text(
                        me.name.split(' ').first,
                        style: AppText.title,
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(AppIcons.bell),
                  tooltip: 'Notifications',
                  onPressed: () => context.push('/notices'),
                ),
              ],
            ),
            SliverPadding(
              padding: AppSpace.list,
              sliver: SliverList.list(
                children: [
                  FadeSlideIn(
                    child: _RushSection(
                      me: me,
                      onEditTiming: () => showSlotDialog(
                        context,
                        ref,
                        initialSession: me.slotSession,
                        initialFrom: me.slotFrom,
                        initialTo: me.slotTo,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpace.sectionGap),
                  if (pending != null)
                    FadeSlideIn(
                      delay:
                          const Duration(milliseconds: 80),
                      child: _PendingBanner(
                        planName: pending.planName,
                        price: pending.price,
                        at: pending.createdAt,
                      ),
                    ),
                  if (mem != null)
                    FadeSlideIn(
                      delay:
                          const Duration(milliseconds: 120),
                      child: _MembershipHero(
                        planName: mem.planName,
                        endAt: mem.endAt,
                        startAt: mem.startAt,
                        status: mem.status,
                        daysLeft: mem.daysLeft,
                      ),
                    )
                  else if (pending == null)
                    const FadeSlideIn(
                      child: EmptyView(
                        icon: AppIcons.membershipOut,
                        title: 'No active plan yet',
                        subtitle:
                            'Choose a plan to register. The owner approves payment.',
                      ),
                    ),
                  const SizedBox(height: AppSpace.sectionGap),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 140),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => context.push('/plans'),
                            icon: Icon(
                              mem == null
                                  ? AppIcons.addCard
                                  : AppIcons.renew,
                              size: AppIcon.btn,
                            ),
                            label: Text(mem == null
                                ? 'Choose plan'
                                : 'Renew / switch'),
                          ),
                        ),
                        const SizedBox(width: AppSpace.m),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                context.push('/join?gym=demo-gym'),
                            icon: const Icon(AppIcons.qrShow,
                                size: AppIcon.btn),
                            label: const Text('Gym QR'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpace.sectionGap),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 170),
                    child: const SectionHeader(title: 'Explore'),
                  ),
                  const SizedBox(height: AppSpace.sectionHeaderGap),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 200),
                    child: GridView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            Responsive.isDesktop(context) ? 4 : 2,
                        crossAxisSpacing: AppSpace.m,
                        mainAxisSpacing: AppSpace.m,
                        // Fixed height: never overflows, compact on all screens.
                        mainAxisExtent: 152,
                      ),
                      children: [
                        _ExploreTile(
                          icon: AppIcons.membership,
                          color: AppColors.yellow,
                          title: 'All plans',
                          subtitle: 'Membership',
                          onTap: () => context.push('/plans'),
                        ),
                        _ExploreTile(
                          icon: AppIcons.training,
                          color: AppColors.green,
                          title: 'Training',
                          subtitle: 'Personal coaching',
                          onTap: () =>
                              context.push('/services?kind=training'),
                        ),
                        _ExploreTile(
                          icon: AppIcons.diet,
                          color: AppColors.blue,
                          title: 'Diet plans',
                          subtitle: 'Free & paid',
                          onTap: () =>
                              context.push('/services?kind=diet'),
                        ),
                        _ExploreTile(
                          icon: AppIcons.headphones,
                          color: AppColors.yellow,
                          title: 'Gym music',
                          subtitle: 'Workout mixes',
                          onTap: () => ref
                              .read(memberTabProvider.notifier)
                              .state = 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpace.sectionGap),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 240),
                    child: SectionHeader(
                      title: 'Featured programs',
                      action: 'See all',
                      onAction: () => context.push('/services'),
                    ),
                  ),
                  const SizedBox(height: AppSpace.sectionHeaderGap),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 260),
                    child: SizedBox(
                      height: 148,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.zero,
                        children: [
                          for (var i = 0;
                              i < _featured(db).length;
                              i++)
                            _FeaturedCard(
                              item: _featured(db)[i],
                              first: i == 0,
                              onTap: () => context.push(
                                  '/services/book?id=${_featured(db)[i].id}'),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (programs.isNotEmpty) ...[
                    const SizedBox(height: AppSpace.sectionGap),
                    const SectionHeader(title: 'My programs'),
                    const SizedBox(height: AppSpace.sectionHeaderGap),
                    ...programs.mapIndexed((i, b) => FadeSlideIn(
                          delay: Duration(milliseconds: 200 + i * 60),
                          child: Card(
                            margin: const EdgeInsets.only(
                                top: AppSpace.cardGap),
                            child: ListTile(
                              leading: const IconTile(
                                AppIcons.activeDot,
                                color: AppColors.green,
                                size: AppIcon.tile,
                              ),
                              title: Text(b.title,
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style: AppText.title),
                              subtitle: Text(
                                '${b.kind[0].toUpperCase()}${b.kind.substring(1)} · till ${b.endAt == null ? '—' : DateFormat('dd MMM yyyy').format(b.endAt!)}',
                                style: AppText.tiny,
                              ),
                              trailing: const StatusChip('active'),
                            ),
                          ),
                        )),
                  ],
                  if (pendingPrograms.isNotEmpty) ...[
                    const SizedBox(height: AppSpace.xs),
                    ...pendingPrograms.map((b) => Card(
                          margin: const EdgeInsets.only(
                              top: AppSpace.cardGap),
                          color:
                              AppColors.yellow.withValues(alpha: 0.06),
                          child: ListTile(
                            leading: const IconTile(
                              AppIcons.pending,
                              size: AppIcon.tile,
                            ),
                            title: Text(b.title,
                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis,
                                style: AppText.title),
                            subtitle: Text(
                              'Program request pending',
                              style: AppText.tiny,
                            ),
                            trailing: const StatusChip('pending'),
                          ),
                        )),
                  ],
                  const SizedBox(height: AppSpace.s),
                  Center(
                    child: TextButton.icon(
                      onPressed: () => context.push('/notices'),
                      icon: const Icon(AppIcons.history,
                          size: AppIcon.sm),
                      label: const Text('Full history in Profile →'),
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

// ─────────────────────────────────────────────────────────────────────────────
// _PendingBanner
// ─────────────────────────────────────────────────────────────────────────────
class _PendingBanner extends StatelessWidget {
  final String planName;
  final int price;
  final DateTime at;
  const _PendingBanner({
    required this.planName,
    required this.price,
    required this.at,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpace.m),
      padding: AppSpace.card,
      decoration: BoxDecoration(
        color: AppColors.yellow.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.l),
        border: Border.all(color: AppColors.yellow.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const IconTile(AppIcons.pending, size: AppIcon.tile),
          const SizedBox(width: AppSpace.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pending approval', style: AppText.title),
                const SizedBox(height: AppSpace.xs),
                Text(
                  '$planName · ₹$price — owner will verify payment.',
                  style: AppText.small,
                ),
                Text(
                  'Requested ${DateFormat('dd MMM, hh:mm a').format(at)}',
                  style: AppText.tiny,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _MembershipHero
// ─────────────────────────────────────────────────────────────────────────────
class _MembershipHero extends StatelessWidget {
  final String planName;
  final DateTime startAt;
  final DateTime endAt;
  final String status;
  final int daysLeft;
  const _MembershipHero({
    required this.planName,
    required this.startAt,
    required this.endAt,
    required this.status,
    required this.daysLeft,
  });

  @override
  Widget build(BuildContext context) {
    final color = status == 'active'
        ? AppColors.green
        : status == 'expiring_soon'
            ? AppColors.yellow
            : AppColors.red;
    final total = endAt.difference(startAt).inDays.clamp(1, 10000);
    final left = daysLeft.clamp(0, total);
    final progress = left / total;
    final label = status == 'active'
        ? '$daysLeft days remaining'
        : status == 'expiring_soon'
            ? 'Expires in $daysLeft day(s) — renew soon'
            : 'Expired — renew to reactivate';
    return Container(
      padding: AppSpace.card,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1E26), Color(0xFF2A2304)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.l),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 32,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusChip(status),
                const SizedBox(height: AppSpace.s),
                Text(planName, style: AppText.display),
                const SizedBox(height: AppSpace.xs),
                Text(
                  'Valid till ${DateFormat('dd MMM yyyy').format(endAt)}',
                  style: AppText.small,
                ),
                const SizedBox(height: AppSpace.s),
                Text(
                  label,
                  style: AppText.label.copyWith(color: color),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpace.m),
          _ProgressRing(progress: progress, color: color, label: '$left'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ProgressRing
// ─────────────────────────────────────────────────────────────────────────────
class _ProgressRing extends StatelessWidget {
  final double progress;
  final Color color;
  final String label;
  const _ProgressRing({
    required this.progress,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      height: 84,
      child: CustomPaint(
        painter: _RingPainter(progress: progress, color: color),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: AppText.head),
              Text('days', style: AppText.tiny),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 6;
    final bg = Paint()
      ..color = AppColors.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    final fg = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(c, r, bg);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2,
      math.pi * 2 * progress.clamp(0.0, 1.0),
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// _RushSection — "when is the gym busiest?" + my timing row.
// ─────────────────────────────────────────────────────────────────────────────
class _RushSection extends ConsumerWidget {
  final AppUser me;
  final VoidCallback onEditTiming;
  const _RushSection({required this.me, required this.onEditTiming});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(fakeDbProvider);
    final counts = db.rushByHour();
    final peak = db.peakHour();
    final total = db.membersWithSlot().length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Gym rush hours'),
        const SizedBox(height: AppSpace.xs),
        RushSummary(
          peakHour: peak?.hour,
          peakCount: peak?.count ?? 0,
          total: total,
        ),
        const SizedBox(height: AppSpace.m),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpace.m),
            child: RushChart(counts: counts, peak: peak?.hour),
          ),
        ),
        const SizedBox(height: AppSpace.m),
        if (!me.hasSlot)
          Card(
            color: AppColors.yellow.withValues(alpha: 0.08),
            child: ListTile(
              leading: const IconTile(AppIcons.calendar,
                  size: AppIcon.tile),
              title: Text('Set your gym timing',
                  style: AppText.title),
              subtitle: Text(
                'Morning or evening? Helps everyone dodge the rush.',
                style: AppText.small,
              ),
              trailing: ElevatedButton(
                onPressed: onEditTiming,
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(48, 44)),
                child: const Text('Set'),
              ),
            ),
          )
        else
          Card(
            child: ListTile(
              leading: const IconTile(AppIcons.calendar,
                  size: AppIcon.tile),
              title: Text('My timing', style: AppText.title),
              subtitle: Text(me.slotLabel, style: AppText.small),
              trailing: TextButton(
                onPressed: onEditTiming,
                child: const Text('Edit'),
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ExploreTile
// ─────────────────────────────────────────────────────────────────────────────
class _ExploreTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ExploreTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.l),
        onTap: onTap,
        child: Padding(
          padding: AppSpace.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconTile(icon, color: color, size: AppIcon.tile),
              const SizedBox(height: AppSpace.s),
              Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.title),
              Text(subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.tiny),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _FeaturedCard
// Responsive width: ~45% of screen width, capped between 180–240 px.
// ─────────────────────────────────────────────────────────────────────────────
class _FeaturedCard extends StatelessWidget {
  final ServiceItem item;
  final bool first;
  final VoidCallback onTap;
  const _FeaturedCard({
    required this.item,
    required this.first,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    final cardW = (screenW * 0.48).clamp(180.0, 240.0);
    return SizedBox(
      width: cardW,
      child: Padding(
        padding: EdgeInsets.only(left: first ? 0 : AppSpace.m),
        child: Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.l),
            onTap: onTap,
            child: Padding(
              padding: AppSpace.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.title,
                        ),
                      ),
                      const SizedBox(width: AppSpace.xs),
                      Text(
                        item.isFree ? 'FREE' : '₹${item.price}',
                        style: AppText.label.copyWith(
                          color: item.isFree
                              ? AppColors.green
                              : AppColors.yellow,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.xs),
                  Text(
                    '${item.goal} · ${item.durationDays} days',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.tiny,
                  ),
                  const SizedBox(height: AppSpace.s),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          'View details',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.small.copyWith(
                            color: AppColors.yellow,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpace.xs),
                      const Icon(AppIcons.forward,
                          size: AppIcon.xs, color: AppColors.yellow),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
