import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/auth/session.dart';
import '../../../core/models/app_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/tokens.dart';
import '../../music/state/gym_player.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/brand.dart';
import '../../../core/widgets/chips.dart';
import '../../../core/widgets/rush_chart.dart';
import '../../../core/widgets/glow_nav.dart';
import '../../../core/widgets/motion.dart';
import '../../../core/widgets/search_filter_bar.dart';
import '../../../core/widgets/state_views.dart';

/// Owner console: stats + approvals + members + plans.
/// Bottom nav on phones, segmented control on desktop — same content, responsive.
class OwnerDashboardScreen extends ConsumerStatefulWidget {
  const OwnerDashboardScreen({super.key});
  @override
  ConsumerState<OwnerDashboardScreen> createState() =>
      _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState
    extends ConsumerState<OwnerDashboardScreen> {
  int _tab = 0;
  String _query = '';
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(fakeDbProvider);
    final pending = db.pendingRegs();
    final members = db.membershipsSorted();
    final wide = Responsive.isDesktop(context);
    final totalBadge = pending.length + db.pendingServiceReqs().length;

    final pages = [
      _HomeTab(
        pendingCount: pending.length + db.pendingServiceReqs().length,
        expiringCount: members.where((m) => m.status != 'active').length,
        memberCount: members.length,
        attention:
            members.where((m) => m.status != 'active').take(5).toList(),
        rush: db.rushByHour(),
        peak: db.peakHour(),
        rushTotal: db.membersWithSlot().length,
        onTab: (i) => setState(() => _tab = i),
        onQr: () => _showQr(context),
      ),
      _PendingTab(
        onApprove: (id) => db.approve(id),
        onDeny: (id) => _denyDialog(context, ref, id),
        onSvcApprove: (id) => db.approveService(id),
        onSvcDeny: (id) => _denyServiceDialog(context, ref, id),
      ),
      _MembersTab(
        query: _query,
        filter: _filter,
        members: _filteredMembers(members),
        onQuery: (v) => setState(() => _query = v),
        onFilter: (v) => setState(() => _filter = v),
      ),
      _PlansTab(onPlans: () => context.push('/plans')),
      _ServicesTab(onManage: () => context.push('/services')),
    ];
    const titles = [
      'Dashboard',
      'Approvals',
      'Members',
      'Plans',
      'Programs',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: AppSizes.brandMark,
              height: AppSizes.brandMark,
              decoration: BoxDecoration(
                gradient: AppGradients.logo,
                borderRadius: BorderRadius.circular(AppRadius.s),
              ),
              child: const Icon(AppIcons.training,
                  size: AppIcon.sm, color: AppColors.black),
            ),
            const SizedBox(width: AppSpace.s),
            Flexible(
              child: Text(
                titles[_tab],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.qrShow),
            tooltip: 'Join QR',
            onPressed: () => _showQr(context),
          ),
          IconButton(
            icon: const Icon(AppIcons.bell),
            tooltip: 'Notifications',
            onPressed: () => context.push('/notices'),
          ),
          IconButton(
            icon: const Icon(AppIcons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await ref.read(gymPlayerProvider).stop();
              logout(ref);
            },
          ),
        ],
      ),
      body: MaxWidth(
        child: Column(
          children: [
            if (wide)
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(AppSpace.l, AppSpace.s, AppSpace.l, 0),
                child: SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(
                        value: 0,
                        icon: Icon(AppIcons.dashboard),
                        label: Text('Home')),
                    ButtonSegment(
                        value: 1,
                        icon: Icon(AppIcons.pendingNav),
                        label: Text('Pending')),
                    ButtonSegment(
                        value: 2,
                        icon: Icon(AppIcons.members),
                        label: Text('Members')),
                    ButtonSegment(
                        value: 3,
                        icon: Icon(AppIcons.membershipOut),
                        label: Text('Plans')),
                    ButtonSegment(
                        value: 4,
                        icon: Icon(AppIcons.programs),
                        label: Text('Programs')),
                  ],
                  selected: {_tab},
                  onSelectionChanged: (s) =>
                      setState(() => _tab = s.first),
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor:
                        AppColors.yellow.withValues(alpha: 0.15),
                    selectedForegroundColor: AppColors.yellow,
                  ),
                ),
              ),
            Expanded(child: pages[_tab]),
          ],
        ),
      ),
      bottomNavigationBar: wide
          ? null
          : GlowNav(
              index: _tab,
              onTap: (i) => setState(() => _tab = i),
              items: [
                const GlowNavItem(
                    icon: AppIcons.dashboard,
                    activeIcon: AppIcons.dashboardActive,
                    label: 'Home'),
                GlowNavItem(
                  icon: AppIcons.pendingNav,
                  activeIcon: AppIcons.pendingNavActive,
                  label: 'Pending',
                  badge: totalBadge,
                ),
                const GlowNavItem(
                    icon: AppIcons.members,
                    activeIcon: AppIcons.membersActive,
                    label: 'Members'),
                const GlowNavItem(
                    icon: AppIcons.membershipOut,
                    activeIcon: AppIcons.membership,
                    label: 'Plans'),
                const GlowNavItem(
                    icon: AppIcons.programs,
                    activeIcon: AppIcons.training,
                    label: 'Programs'),
              ],
            ),
    );
  }

  List<Membership> _filteredMembers(List<Membership> members) {
    final q = _query.toLowerCase();
    return members.where((m) {
      final okQ = m.userName.toLowerCase().contains(q) ||
          m.phone.contains(q) ||
          m.planName.toLowerCase().contains(q);
      final okF = _filter == 'all' ||
          (_filter == 'attention' && m.status != 'active') ||
          (_filter == m.status);
      return okQ && okF;
    }).toList();
  }

  void _showQr(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Registration QR'),
        content: SizedBox(
          width: 240,
          height: 310,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpace.m),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.m),
                ),
                child: QrImageView(
                  data: 'https://totalfitgym.web.app/join?gym=demo-gym',
                  size: 200,
                ),
              ),
              const SizedBox(height: AppSpace.m),
              Text(
                'Stick this at the gym entrance. Works on Android, iPhone & desktop.',
                textAlign: TextAlign.center,
                style: AppText.small,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _denyDialog(BuildContext context, WidgetRef ref, String regId) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Deny request?'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            labelText: 'Reason (shown to member)',
            hintText: 'e.g. Payment not received',
            prefixIcon: Icon(AppIcons.note),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              ref.read(fakeDbProvider).deny(regId, ctrl.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Deny'),
          ),
        ],
      ),
    );
  }

  void _denyServiceDialog(
      BuildContext context, WidgetRef ref, String bookingId) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Deny program request?'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            labelText: 'Reason (shown to member)',
            hintText: 'e.g. Batch full, try next month',
            prefixIcon: Icon(AppIcons.note),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              ref
                  .read(fakeDbProvider)
                  .denyService(bookingId, ctrl.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Deny'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _HomeTab
// ─────────────────────────────────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  final int pendingCount;
  final int expiringCount;
  final int memberCount;
  final List<Membership> attention;
  final List<int> rush;
  final ({int hour, int count})? peak;
  final int rushTotal;
  final void Function(int) onTab;
  final VoidCallback onQr;
  const _HomeTab({
    required this.pendingCount,
    required this.expiringCount,
    required this.memberCount,
    required this.attention,
    required this.rush,
    required this.peak,
    required this.rushTotal,
    required this.onTab,
    required this.onQr,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateFormat('EEEE, dd MMM').format(DateTime.now());
    return ListView(
      padding: AppSpace.list,
      children: [
        FadeSlideIn(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Namaste, Owner', style: AppText.display),
              const SizedBox(height: AppSpace.xs),
              Text(now, style: AppText.small),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.sectionGap),
        FadeSlideIn(
          delay: const Duration(milliseconds: 60),
          child: const SectionHeader(title: 'Rush hours'),
        ),
        const SizedBox(height: AppSpace.xs),
        FadeSlideIn(
          delay: const Duration(milliseconds: 80),
          child: RushSummary(
            peakHour: peak?.hour,
            peakCount: peak?.count ?? 0,
            total: rushTotal,
          ),
        ),
        const SizedBox(height: AppSpace.m),
        FadeSlideIn(
          delay: const Duration(milliseconds: 100),
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: AppSpace.m),
              child: RushChart(counts: rush, peak: peak?.hour),
            ),
          ),
        ),
        const SizedBox(height: AppSpace.sectionGap),
        Row(
          children: [
            Expanded(
              child: FadeSlideIn(
                delay: const Duration(milliseconds: 140),
                child: _Stat('Pending', '$pendingCount',
                    AppColors.yellow, AppIcons.pendingNavActive,
                    () => onTab(1)),
              ),
            ),
            const SizedBox(width: AppSpace.cardGap),
            Expanded(
              child: FadeSlideIn(
                delay: const Duration(milliseconds: 180),
                child: _Stat('Expiring', '$expiringCount', AppColors.red,
                    AppIcons.expired, () => onTab(2)),
              ),
            ),
            const SizedBox(width: AppSpace.cardGap),
            Expanded(
              child: FadeSlideIn(
                delay: const Duration(milliseconds: 220),
                child: _Stat('Members', '$memberCount', AppColors.green,
                    AppIcons.members, () => onTab(2)),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.sectionGap),
        FadeSlideIn(
          delay: const Duration(milliseconds: 260),
          child: Card(
            child: ListTile(
              leading: const IconTile(AppIcons.qrShow,
                  size: AppIcon.tile),
              title: Text('Registration QR', style: AppText.title),
              subtitle: Text('Show at entrance for new joiners',
                  style: AppText.small),
              trailing: const Icon(AppIcons.next,
                  color: AppColors.grey),
              onTap: onQr,
            ),
          ),
        ),
        const SizedBox(height: AppSpace.sectionGap),
        const SectionHeader(title: 'Needs attention'),
        const SizedBox(height: AppSpace.sectionHeaderGap),
        if (attention.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpace.l),
            child: EmptyView(
              icon: AppIcons.approved,
              title: 'All memberships healthy',
              subtitle: 'No expiring or expired plans. Keep it up!',
            ),
          )
        else
          ...attention.mapIndexed((i, m) => FadeSlideIn(
                delay: Duration(milliseconds: 240 + i * 60),
                child: Card(
                  margin: const EdgeInsets.only(top: AppSpace.cardGap),
                  child: ListTile(
                    leading: InitialAvatar(m.userName, radius: 21),
                    title: Text(m.userName, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.title),
                    subtitle: Text(
                      '${m.planName} · till ${DateFormat('dd MMM').format(m.endAt)}',
                      style: AppText.small,
                    ),
                    trailing: StatusChip(m.status),
                  ),
                ),
              )),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _Stat card
// ─────────────────────────────────────────────────────────────────────────────
class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  const _Stat(this.label, this.value, this.color, this.icon, this.onTap);

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
            children: [
              IconTile(icon, color: color, size: AppIcon.tile),
              const SizedBox(height: AppSpace.s),
              Text(value, style: AppText.display),
              Text(label, style: AppText.small),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PendingTab
// ─────────────────────────────────────────────────────────────────────────────
class _PendingTab extends ConsumerWidget {
  final void Function(String) onApprove;
  final void Function(String) onDeny;
  final void Function(String) onSvcApprove;
  final void Function(String) onSvcDeny;
  const _PendingTab({
    required this.onApprove,
    required this.onDeny,
    required this.onSvcApprove,
    required this.onSvcDeny,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(fakeDbProvider);
    final pending = db.pendingRegs();
    final svcPending = db.pendingServiceReqs();
    if (pending.isEmpty && svcPending.isEmpty) {
      return const EmptyView(
        icon: AppIcons.approvedFill,
        title: 'All clear',
        subtitle:
            'No pending payments or program requests. New ones appear here.',
      );
    }
    return ListView(
      padding: AppSpace.list,
      children: [
        if (pending.isNotEmpty) ...[
          const SectionHeader(title: 'Memberships'),
          const SizedBox(height: AppSpace.sectionHeaderGap),
          ...pending.mapIndexed((i, r) => FadeSlideIn(
                delay: Duration(milliseconds: i * 60),
                child: _RegCard(
                  title: r.userName,
                  subtitle:
                      '+91 ${r.phone} · ${DateFormat('dd MMM, hh:mm a').format(r.createdAt)}',
                  planLine: '${r.planName} · ₹${r.price}',
                  onApprove: () => onApprove(r.id),
                  onDeny: () => onDeny(r.id),
                ),
              )),
        ],
        if (svcPending.isNotEmpty) ...[
          const SizedBox(height: AppSpace.m),
          const SectionHeader(title: 'Programs & diets'),
          const SizedBox(height: AppSpace.sectionHeaderGap),
          ...svcPending.mapIndexed((i, b) => FadeSlideIn(
                delay: Duration(milliseconds: i * 60),
                child: _RegCard(
                  title: b.userName,
                  subtitle:
                      '+91 ${b.phone} · ${DateFormat('dd MMM, hh:mm a').format(b.createdAt)}',
                  planLine:
                      '${b.title} · ${b.kind} · ${b.price <= 0 ? 'FREE' : '₹${b.price}'}',
                  onApprove: () => onSvcApprove(b.id),
                  onDeny: () => onSvcDeny(b.id),
                ),
              )),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _RegCard
// ─────────────────────────────────────────────────────────────────────────────
class _RegCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String planLine;
  final VoidCallback onApprove;
  final VoidCallback onDeny;
  const _RegCard({
    required this.title,
    required this.subtitle,
    required this.planLine,
    required this.onApprove,
    required this.onDeny,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: AppSpace.cardGap),
      child: Padding(
        padding: AppSpace.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InitialAvatar(title, radius: 21),
                const SizedBox(width: AppSpace.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.title),
                      Text(subtitle, style: AppText.tiny),
                    ],
                  ),
                ),
                const StatusChip('pending'),
              ],
            ),
            const SizedBox(height: AppSpace.m),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.m, vertical: AppSpace.s),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.s),
              ),
              child: Row(
                children: [
                  const Icon(AppIcons.ticket,
                      size: AppIcon.sm, color: AppColors.yellow),
                  const SizedBox(width: AppSpace.s),
                  Expanded(
                    child: Text(planLine,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.title),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.m),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDeny,
                    icon: const Icon(AppIcons.close,
                        size: AppIcon.sm),
                    label: const Text('Deny'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.red,
                      side: const BorderSide(color: Color(0x66FF6B6B)),
                      minimumSize:
                          const Size(48, AppSizes.btnSecondary),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpace.s),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(AppIcons.check,
                        size: AppIcon.sm),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                        minimumSize:
                            const Size(48, AppSizes.btnSecondary)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _MembersTab — now uses SearchFilterBar
// ─────────────────────────────────────────────────────────────────────────────
class _MembersTab extends StatelessWidget {
  final String query;
  final String filter;
  final List<Membership> members;
  final ValueChanged<String> onQuery;
  final ValueChanged<String> onFilter;
  const _MembersTab({
    required this.query,
    required this.filter,
    required this.members,
    required this.onQuery,
    required this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    const filters = {
      'all': 'All',
      'active': 'Active',
      'expiring_soon': 'Expiring',
      'expired': 'Expired',
    };
    return Column(
      children: [
        SearchFilterBar(
          hint: 'Search name, phone, plan…',
          onQuery: onQuery,
          chips: filters.entries
              .map((e) => (
                    label: e.value,
                    selected: filter == e.key,
                    onTap: () => onFilter(e.key),
                  ))
              .toList(),
        ),
        Expanded(
          child: members.isEmpty
              ? EmptyView(
                  icon: AppIcons.searchOff,
                  title: filter == 'all'
                      ? 'No members found'
                      : 'Nothing here',
                  subtitle: 'Try a different search or filter.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpace.l, AppSpace.xs, AppSpace.l, AppSpace.l),
                  itemCount: members.length,
                  itemBuilder: (_, i) {
                    final m = members[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppSpace.s),
                      child: ListTile(
                        leading: InitialAvatar(m.userName, radius: 21),
                        title: Text(m.userName, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.title),
                        subtitle: Text(
                          '${m.planName} · till ${DateFormat('dd MMM yyyy').format(m.endAt)}',
                          style: AppText.small,
                        ),
                        trailing: StatusChip(m.status),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PlansTab
// ─────────────────────────────────────────────────────────────────────────────
class _PlansTab extends ConsumerWidget {
  final VoidCallback onPlans;
  const _PlansTab({required this.onPlans});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(fakeDbProvider).plans.values.toList();
    return ListView(
      padding: AppSpace.list,
      children: [
        ElevatedButton.icon(
          onPressed: onPlans,
          icon: const Icon(AppIcons.tune, size: AppIcon.btn),
          label: const Text('Open plan manager'),
        ),
        const SizedBox(height: AppSpace.s),
        ...plans.mapIndexed((i, p) => FadeSlideIn(
              delay: Duration(milliseconds: i * 60),
              child: Card(
                margin: const EdgeInsets.only(top: AppSpace.cardGap),
                child: ListTile(
                  leading: IconTile(
                    AppIcons.membership,
                    color: p.active ? AppColors.yellow : AppColors.faint,
                    size: AppIcon.tile,
                  ),
                  title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.title),
                  subtitle: Text(
                    '₹${p.price} · ${p.durationDays} days · ${p.active ? 'Visible' : 'Hidden'}',
                    style: AppText.small,
                  ),
                  trailing: const Icon(AppIcons.next,
                      color: AppColors.grey),
                  onTap: onPlans,
                ),
              ),
            )),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ServicesTab
// ─────────────────────────────────────────────────────────────────────────────
class _ServicesTab extends ConsumerWidget {
  final VoidCallback onManage;
  const _ServicesTab({required this.onManage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(fakeDbProvider);
    final kinds = db.serviceKinds(activeOnly: false);
    final totalPending = db.pendingServiceReqs().length;
    return ListView(
      padding: AppSpace.list,
      children: [
        ElevatedButton.icon(
          onPressed: onManage,
          icon: const Icon(AppIcons.tune, size: AppIcon.btn),
          label: const Text('Manage programs'),
        ),
        if (totalPending > 0) ...[
          const SizedBox(height: AppSpace.s),
          Text(
            '$totalPending program request(s) waiting in Approvals.',
            style: AppText.small.copyWith(color: AppColors.yellow),
          ),
        ],
        const SizedBox(height: AppSpace.s),
        ...kinds.map((k) {
          final items = db.servicesList(kind: k, activeOnly: false);
          final active = items.where((s) => s.active).length;
          return Card(
            margin: const EdgeInsets.only(top: AppSpace.cardGap),
            child: ListTile(
              leading: IconTile(
                AppIcons.kindIcon(k),
                size: AppIcon.tile,
              ),
              title: Text(
                k.isEmpty ? k : k[0].toUpperCase() + k.substring(1),
                style: AppText.title,
              ),
              subtitle: Text(
                '${items.length} program(s) · $active visible',
                style: AppText.small,
              ),
              trailing: const Icon(AppIcons.next,
                  color: AppColors.grey),
              onTap: onManage,
            ),
          );
        }),
        const SizedBox(height: AppSpace.m),
        Text(
          'Tip: add any new category (cardio, physio, supplements…) from the + button — no app update needed.',
          style: AppText.tiny,
        ),
      ],
    );
  }
}
