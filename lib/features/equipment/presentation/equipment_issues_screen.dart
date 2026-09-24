import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/auth/session.dart';
import '../../../core/models/app_models.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/brand.dart';
import '../../../core/widgets/chips.dart';
import '../../../core/widgets/motion.dart';
import '../../../core/widgets/state_views.dart';

/// Equipment breakdown reporting & maintenance status screen.
class EquipmentIssuesScreen extends ConsumerStatefulWidget {
  const EquipmentIssuesScreen({super.key});

  @override
  ConsumerState<EquipmentIssuesScreen> createState() =>
      _EquipmentIssuesScreenState();
}

class _EquipmentIssuesScreenState extends ConsumerState<EquipmentIssuesScreen> {
  String _filter = 'all'; // all | pending | in_progress | resolved

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(fakeDbProvider);
    final me = ref.watch(currentUserProvider);
    if (me == null) {
      return const Scaffold(body: LoadingView(message: 'Loading…'));
    }

    final isOwner = me.role == 'owner';
    final issues = db.issuesList(status: _filter);
    final activeCount = db.activeIssueCount();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipment & Repairs'),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.add),
            tooltip: 'Report Issue',
            onPressed: () => _openReportDialog(context, me),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openReportDialog(context, me),
        backgroundColor: AppColors.yellow,
        foregroundColor: AppColors.black,
        icon: const Icon(AppIcons.report, size: 20),
        label: const Text(
          'Report Issue',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: MaxWidth(
        child: ListView(
          padding: AppSpace.list,
          children: [
            FadeSlideIn(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gym maintenance log',
                    style: AppText.display,
                  ),
                  const SizedBox(height: AppSpace.xs),
                  Text(
                    'Report broken or malfunctioning machines to keep the gym in top shape.',
                    style: AppText.small,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.m),

            // ── Health overview bar ──
            Container(
              padding: AppSpace.card,
              decoration: BoxDecoration(
                color: activeCount > 0
                    ? AppColors.yellow.withValues(alpha: 0.1)
                    : AppColors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.m),
                border: Border.all(
                  color: (activeCount > 0 ? AppColors.yellow : AppColors.green)
                      .withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  IconTile(
                    activeCount > 0 ? AppIcons.maintenance : AppIcons.approved,
                    color: activeCount > 0 ? AppColors.yellow : AppColors.green,
                    size: 38,
                  ),
                  const SizedBox(width: AppSpace.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activeCount > 0
                              ? '$activeCount Active Maintenance Item${activeCount > 1 ? 's' : ''}'
                              : 'All Gym Equipment Operational',
                          style: AppText.title,
                        ),
                        Text(
                          activeCount > 0
                              ? 'Repairs are tracked and resolved by gym staff.'
                              : 'Zero reported breakdowns right now. Have a great workout!',
                          style: AppText.tiny,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.m),

            // ── Filter tabs ──
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final f in [
                    ('all', 'All'),
                    ('pending', 'Pending'),
                    ('in_progress', 'In Progress'),
                    ('resolved', 'Resolved'),
                  ])
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpace.s),
                      child: AppChoice(
                        f.$2,
                        _filter == f.$1,
                        () => setState(() => _filter = f.$1),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.sectionGap),

            // ── Issues list ──
            if (issues.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpace.xl),
                child: EmptyView(
                  icon: AppIcons.check,
                  title: 'No issues in this filter',
                  subtitle: 'Machines in this category are working smoothly.',
                ),
              )
            else
              ...issues.map(
                (issue) => _EquipmentIssueCard(
                  issue: issue,
                  isOwner: isOwner,
                  onUpdateStatus: (status, note) => ref
                      .read(fakeDbProvider)
                      .updateIssueStatus(issue.id, status, resolutionNote: note),
                  onDelete: () =>
                      ref.read(fakeDbProvider).deleteIssue(issue.id),
                ),
              ),

            const SizedBox(height: 80), // spacing for FAB
          ],
        ),
      ),
    );
  }

  void _openReportDialog(BuildContext context, AppUser me) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    var category = 'Cardio';
    var severity = 'medium';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: const Text('Report Equipment Issue'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: titleCtrl,
                    style: const TextStyle(color: AppColors.white),
                    decoration: const InputDecoration(
                      labelText: 'Machine / Equipment',
                      hintText: 'e.g. Treadmill #2, Lat Pulldown cable',
                      prefixIcon: Icon(AppIcons.equipment),
                    ),
                    validator: (v) => (v ?? '').trim().length < 3
                        ? 'Enter machine name'
                        : null,
                  ),
                  const SizedBox(height: AppSpace.m),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    dropdownColor: AppColors.card,
                    style: const TextStyle(color: AppColors.white),
                    decoration: const InputDecoration(
                      labelText: 'Category / Area',
                      prefixIcon: Icon(AppIcons.category),
                    ),
                    items: const [
                      'Cardio',
                      'Strength',
                      'Free Weights',
                      'Amenities',
                    ]
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c,
                                  style:
                                      const TextStyle(color: AppColors.white)),
                            ))
                        .toList(),
                    onChanged: (v) => setD(() => category = v ?? category),
                  ),
                  const SizedBox(height: AppSpace.m),
                  DropdownButtonFormField<String>(
                    initialValue: severity,
                    dropdownColor: AppColors.card,
                    style: const TextStyle(color: AppColors.white),
                    decoration: const InputDecoration(
                      labelText: 'Severity',
                      prefixIcon: Icon(AppIcons.report),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'low',
                        child: Text('Low (Cosmetic / minor sound)',
                            style: TextStyle(color: AppColors.blue)),
                      ),
                      DropdownMenuItem(
                        value: 'medium',
                        child: Text('Medium (Partially functional)',
                            style: TextStyle(color: AppColors.yellow)),
                      ),
                      DropdownMenuItem(
                        value: 'urgent',
                        child: Text('Urgent (Unusable / safety hazard)',
                            style: TextStyle(color: AppColors.red)),
                      ),
                    ],
                    onChanged: (v) => setD(() => severity = v ?? severity),
                  ),
                  const SizedBox(height: AppSpace.m),
                  TextFormField(
                    controller: descCtrl,
                    maxLines: 3,
                    style: const TextStyle(color: AppColors.white),
                    decoration: const InputDecoration(
                      labelText: 'Problem description',
                      hintText: 'Describe what happened or what needs fixing…',
                    ),
                    validator: (v) => (v ?? '').trim().length < 5
                        ? 'Please describe problem'
                        : null,
                  ),
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
                if (!formKey.currentState!.validate()) return;
                final id = 'eq_${DateTime.now().millisecondsSinceEpoch}';
                final issue = EquipmentIssue(
                  id: id,
                  title: titleCtrl.text.trim(),
                  category: category,
                  severity: severity,
                  reportedByUid: me.uid,
                  reportedByName: me.name,
                  description: descCtrl.text.trim(),
                  reportedAt: DateTime.now(),
                );
                ref.read(fakeDbProvider).reportIssue(issue);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Issue reported. Thank you for helping keep the gym safe!',
                    ),
                  ),
                );
              },
              child: const Text('Submit Report'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EquipmentIssueCard extends StatelessWidget {
  final EquipmentIssue issue;
  final bool isOwner;
  final void Function(String status, String? note) onUpdateStatus;
  final VoidCallback onDelete;

  const _EquipmentIssueCard({
    required this.issue,
    required this.isOwner,
    required this.onUpdateStatus,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final reportedDate =
        DateFormat('dd MMM, hh:mm a').format(issue.reportedAt);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpace.cardGap),
      child: Padding(
        padding: AppSpace.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconTile(
                  switch (issue.category) {
                    'Cardio' => AppIcons.cardio,
                    'Strength' => AppIcons.training,
                    'Free Weights' => AppIcons.equipment,
                    _ => AppIcons.maintenance,
                  },
                  size: AppIcon.tile,
                ),
                const SizedBox(width: AppSpace.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        issue.title,
                        style: AppText.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            '${issue.category} · Reported by ${issue.reportedByName}',
                            style: AppText.tiny,
                          ),
                        ],
                      ),
                      Text(reportedDate, style: AppText.tiny.copyWith(color: AppColors.faint)),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpace.xs),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    StatusChip(issue.status),
                    const SizedBox(height: 4),
                    StatusChip(issue.severity),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpace.s),
            Text(issue.description, style: AppText.body),

            // ── Resolution note (if resolved) ──
            if (issue.status == 'resolved' && (issue.resolutionNote ?? '').isNotEmpty) ...[
              const SizedBox(height: AppSpace.s),
              Container(
                padding: const EdgeInsets.all(AppSpace.s),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.s),
                  border: Border.all(color: AppColors.green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(AppIcons.check, size: 16, color: AppColors.green),
                    const SizedBox(width: AppSpace.s),
                    Expanded(
                      child: Text(
                        'Resolution: ${issue.resolutionNote!}',
                        style: AppText.tiny.copyWith(color: AppColors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ── Owner controls ──
            if (isOwner) ...[
              const Divider(height: AppSpace.m),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(AppIcons.close, color: AppColors.grey, size: 18),
                    tooltip: 'Delete Log',
                    onPressed: onDelete,
                  ),
                  const SizedBox(width: AppSpace.s),
                  PopupMenuButton<String>(
                    icon: const Icon(AppIcons.tune, color: AppColors.yellow, size: 20),
                    color: AppColors.cardHi,
                    tooltip: 'Change Status',
                    onSelected: (val) {
                      if (val == 'resolved') {
                        _showResolveDialog(context);
                      } else {
                        onUpdateStatus(val, null);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'pending',
                        child: Text('Mark Pending', style: TextStyle(color: AppColors.yellow)),
                      ),
                      PopupMenuItem(
                        value: 'in_progress',
                        child: Text('Mark In Progress', style: TextStyle(color: AppColors.yellow)),
                      ),
                      PopupMenuItem(
                        value: 'resolved',
                        child: Text('Mark Resolved…', style: TextStyle(color: AppColors.green)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showResolveDialog(BuildContext context) {
    final noteCtrl = TextEditingController(text: 'Inspected and repaired by technician.');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mark Issue as Resolved'),
        content: TextField(
          controller: noteCtrl,
          style: const TextStyle(color: AppColors.white),
          decoration: const InputDecoration(
            labelText: 'Resolution note (optional)',
            hintText: 'e.g. Technician replaced belt & tested',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              onUpdateStatus('resolved', noteCtrl.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
  }
}
