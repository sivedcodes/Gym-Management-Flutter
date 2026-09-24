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
import '../../../core/widgets/state_views.dart';

/// Trainers & Personal Training Batches screen for both members and owner.
class TrainersScreen extends ConsumerStatefulWidget {
  const TrainersScreen({super.key});

  @override
  ConsumerState<TrainersScreen> createState() => _TrainersScreenState();
}

class _TrainersScreenState extends ConsumerState<TrainersScreen> {
  @override
  Widget build(BuildContext context) {
    final db = ref.watch(fakeDbProvider);
    final me = ref.watch(currentUserProvider);
    if (me == null) {
      return const Scaffold(body: LoadingView(message: 'Loading…'));
    }

    final isOwner = me.role == 'owner';
    final trainers = db.trainersList(activeOnly: !isOwner);
    final myTrainer = db.trainerOf(me.uid);
    final totalPtClients = db.trainers.values
        .fold<int>(0, (prev, t) => prev + t.clientUids.length);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainers & PT'),
        actions: [
          if (isOwner)
            TextButton.icon(
              onPressed: () => _openTrainerDialog(context, null),
              icon: const Icon(AppIcons.add, size: AppIcon.sm),
              label: const Text('Add Trainer'),
            ),
        ],
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
                    isOwner ? 'Trainer management' : 'Certified coaches',
                    style: AppText.display,
                  ),
                  const SizedBox(height: AppSpace.xs),
                  Text(
                    isOwner
                        ? 'Manage gym coaches and assign personal training batches.'
                        : 'Get expert guidance tailored to your fitness goals.',
                    style: AppText.small,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.m),

            // ── Owner stats ──
            if (isOwner) ...[
              Row(
                children: [
                  Expanded(
                    child: _TrainerStatCard(
                      label: 'Total Trainers',
                      value: '${trainers.length}',
                      icon: AppIcons.trainer,
                      color: AppColors.yellow,
                    ),
                  ),
                  const SizedBox(width: AppSpace.m),
                  Expanded(
                    child: _TrainerStatCard(
                      label: 'Active PT Clients',
                      value: '$totalPtClients',
                      icon: AppIcons.members,
                      color: AppColors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.sectionGap),
            ],

            // ── Member personal trainer callout ──
            if (!isOwner && myTrainer != null) ...[
              FadeSlideIn(
                child: Container(
                  padding: AppSpace.card,
                  decoration: BoxDecoration(
                    gradient: AppGradients.yellowCard,
                    borderRadius: BorderRadius.circular(AppRadius.l),
                    border: Border.all(
                      color: AppColors.yellow.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      InitialAvatar(myTrainer.name, radius: 26),
                      const SizedBox(width: AppSpace.m),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.yellow.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'YOUR PERSONAL COACH',
                                style: AppText.label.copyWith(
                                  color: AppColors.yellow,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpace.xs),
                            Text(myTrainer.name, style: AppText.title),
                            Text(
                              '${myTrainer.specialization} · ${myTrainer.shift}',
                              style: AppText.tiny,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(AppIcons.phoneAlt, color: AppColors.yellow),
                        tooltip: 'Call Coach',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Calling ${myTrainer.name} (+91 ${myTrainer.phone})…'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpace.sectionGap),
            ],

            // ── Trainer list ──
            const SectionHeader(title: 'Gym coaches'),
            const SizedBox(height: AppSpace.sectionHeaderGap),
            if (trainers.isEmpty)
              const EmptyView(
                icon: AppIcons.trainer,
                title: 'No trainers listed',
                subtitle: 'Gym trainers will be displayed here soon.',
              )
            else
              ...trainers.map(
                (t) => _TrainerCard(
                  trainer: t,
                  isOwner: isOwner,
                  isMyTrainer: !isOwner && myTrainer?.id == t.id,
                  onEdit: () => _openTrainerDialog(context, t),
                  onDelete: () => _confirmDelete(context, t),
                  onAssign: () => _openAssignDialog(context, t),
                  onUnassign: (uid) =>
                      ref.read(fakeDbProvider).removeMemberFromTrainer(t.id, uid),
                ),
              ),

            const SizedBox(height: AppSpace.xl),
          ],
        ),
      ),
    );
  }

  void _openTrainerDialog(BuildContext context, GymTrainer? existing) {
    final isEdit = existing != null;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final specCtrl = TextEditingController(text: existing?.specialization ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    final expCtrl = TextEditingController(
      text: existing != null ? '${existing.experienceYears}' : '3',
    );
    final bioCtrl = TextEditingController(text: existing?.bio ?? '');
    var shift = existing?.shift ?? 'Morning (6 AM – 11 AM)';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text(isEdit ? 'Edit Trainer' : 'Add New Trainer'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    style: const TextStyle(color: AppColors.white),
                    decoration: const InputDecoration(
                      labelText: 'Trainer Name',
                      hintText: 'e.g. Vikram Rathore',
                      prefixIcon: Icon(AppIcons.member),
                    ),
                    validator: (v) =>
                        (v ?? '').trim().length < 2 ? 'Enter valid name' : null,
                  ),
                  const SizedBox(height: AppSpace.m),
                  TextFormField(
                    controller: specCtrl,
                    style: const TextStyle(color: AppColors.white),
                    decoration: const InputDecoration(
                      labelText: 'Specialization',
                      hintText: 'e.g. Strength & Conditioning',
                      prefixIcon: Icon(AppIcons.goal),
                    ),
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpace.m),
                  DropdownButtonFormField<String>(
                    initialValue: shift,
                    dropdownColor: AppColors.card,
                    style: const TextStyle(color: AppColors.white),
                    decoration: const InputDecoration(
                      labelText: 'Shift Timing',
                      prefixIcon: Icon(AppIcons.calendar),
                    ),
                    items: const [
                      'Morning (6 AM – 11 AM)',
                      'Evening (5 PM – 10 PM)',
                      'Full Day',
                    ]
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s, style: const TextStyle(color: AppColors.white)),
                            ))
                        .toList(),
                    onChanged: (v) => setD(() => shift = v ?? shift),
                  ),
                  const SizedBox(height: AppSpace.m),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: phoneCtrl,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          style: const TextStyle(color: AppColors.white),
                          decoration: const InputDecoration(
                            labelText: 'Phone',
                            prefixText: '+91 ',
                            counterText: '',
                          ),
                          validator: (v) => (v ?? '').trim().length != 10
                              ? '10 digits'
                              : null,
                        ),
                      ),
                      const SizedBox(width: AppSpace.s),
                      Expanded(
                        child: TextFormField(
                          controller: expCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: AppColors.white),
                          decoration: const InputDecoration(
                            labelText: 'Exp (yrs)',
                          ),
                          validator: (v) =>
                              int.tryParse(v ?? '') == null ? 'Number' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.m),
                  TextFormField(
                    controller: bioCtrl,
                    maxLines: 2,
                    style: const TextStyle(color: AppColors.white),
                    decoration: const InputDecoration(
                      labelText: 'Certifications & Bio',
                      hintText: 'e.g. Certified ISSA Trainer…',
                    ),
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
                final id = existing?.id ?? 'trainer_${DateTime.now().millisecondsSinceEpoch}';
                final t = GymTrainer(
                  id: id,
                  name: nameCtrl.text.trim(),
                  specialization: specCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  shift: shift,
                  experienceYears: int.tryParse(expCtrl.text.trim()) ?? 3,
                  bio: bioCtrl.text.trim(),
                  clientUids: existing?.clientUids ?? [],
                  active: existing?.active ?? true,
                );
                ref.read(fakeDbProvider).saveTrainer(t);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isEdit ? 'Trainer updated.' : 'New trainer added.',
                    ),
                  ),
                );
              },
              child: Text(isEdit ? 'Save Changes' : 'Add Trainer'),
            ),
          ],
        ),
      ),
    );
  }

  void _openAssignDialog(BuildContext context, GymTrainer trainer) {
    final db = ref.read(fakeDbProvider);
    final allMembers = db.users.values
        .where((u) => u.role == 'member' && !trainer.clientUids.contains(u.uid))
        .toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Assign Client to ${trainer.name}'),
        content: SizedBox(
          width: 340,
          child: allMembers.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpace.m),
                  child: Text(
                    'All active members are already enrolled with this trainer.',
                    style: AppText.body.copyWith(color: AppColors.grey),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: allMembers.length,
                  itemBuilder: (_, i) {
                    final m = allMembers[i];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: InitialAvatar(m.name, radius: 18),
                      title: Text(m.name, style: AppText.title),
                      subtitle: Text('+91 ${m.phone ?? '—'}', style: AppText.tiny),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(60, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onPressed: () {
                          db.assignMemberToTrainer(trainer.id, m.uid);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${m.name} assigned to ${trainer.name}.'),
                            ),
                          );
                        },
                        child: const Text('Assign'),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, GymTrainer trainer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove ${trainer.name}?'),
        content: const Text(
          'This trainer and their batch assignment will be removed from the catalog.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () {
              ref.read(fakeDbProvider).deleteTrainer(trainer.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Trainer removed.')),
              );
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

class _TrainerCard extends StatelessWidget {
  final GymTrainer trainer;
  final bool isOwner;
  final bool isMyTrainer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAssign;
  final ValueChanged<String> onUnassign;

  const _TrainerCard({
    required this.trainer,
    required this.isOwner,
    required this.isMyTrainer,
    required this.onEdit,
    required this.onDelete,
    required this.onAssign,
    required this.onUnassign,
  });

  @override
  Widget build(BuildContext context) {
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
                InitialAvatar(trainer.name, radius: 24),
                const SizedBox(width: AppSpace.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              trainer.name,
                              style: AppText.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isMyTrainer)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.green.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.green.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                'ASSIGNED',
                                style: AppText.label.copyWith(
                                  color: AppColors.green,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        trainer.specialization,
                        style: AppText.small.copyWith(color: AppColors.yellow),
                      ),
                      const SizedBox(height: AppSpace.xs),
                      Row(
                        children: [
                          const Icon(AppIcons.calendar, size: 13, color: AppColors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${trainer.shift} · ${trainer.experienceYears} yrs exp',
                              style: AppText.tiny,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isOwner)
                  PopupMenuButton<String>(
                    icon: const Icon(AppIcons.tune, color: AppColors.grey, size: 18),
                    color: AppColors.cardHi,
                    onSelected: (action) {
                      if (action == 'edit') onEdit();
                      if (action == 'delete') onDelete();
                      if (action == 'assign') onAssign();
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'assign',
                        child: Text('Assign Client', style: TextStyle(color: AppColors.white)),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit Trainer', style: TextStyle(color: AppColors.white)),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete Trainer', style: TextStyle(color: AppColors.red)),
                      ),
                    ],
                  ),
              ],
            ),
            if (trainer.bio.isNotEmpty) ...[
              const SizedBox(height: AppSpace.s),
              Text(trainer.bio, style: AppText.body),
            ],

            // ── Personal Training Batches (Owner only) ──
            if (isOwner) ...[
              const Divider(height: AppSpace.l),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PT Clients (${trainer.clientUids.length})',
                    style: AppText.label.copyWith(color: AppColors.grey),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(40, 28),
                    ),
                    onPressed: onAssign,
                    icon: const Icon(AppIcons.add, size: 14),
                    label: const Text('Add Client', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.xs),
              Consumer(
                builder: (context, ref, _) {
                  final db = ref.watch(fakeDbProvider);
                  if (trainer.clientUids.isEmpty) {
                    return Text(
                      'No members assigned to this trainer yet.',
                      style: AppText.tiny.copyWith(color: AppColors.faint),
                    );
                  }
                  return Wrap(
                    spacing: AppSpace.s,
                    runSpacing: AppSpace.xs,
                    children: trainer.clientUids.map((uid) {
                      final u = db.users[uid];
                      final name = u?.name ?? uid;
                      return Chip(
                        backgroundColor: AppColors.surface,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        label: Text(name, style: AppText.tiny),
                        deleteIcon: const Icon(AppIcons.close, size: 14, color: AppColors.grey),
                        onDeleted: () => onUnassign(uid),
                      );
                    }).toList(),
                  );
                },
              ),
            ],

            // ── Member contact CTA ──
            if (!isOwner) ...[
              const SizedBox(height: AppSpace.m),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(40, 40),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Contacting ${trainer.name} (+91 ${trainer.phone})…')),
                        );
                      },
                      icon: const Icon(AppIcons.phoneAlt, size: 15),
                      label: const Text('Call Coach', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: AppSpace.s),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(40, 40),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Enquiry sent for Personal Training with ${trainer.name}!',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(AppIcons.bolt, size: 15),
                      label: const Text('Enquire PT', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TrainerStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _TrainerStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpace.card,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.m),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppText.tiny),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: AppSpace.xs),
          Text(
            value,
            style: AppText.displaySm.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
