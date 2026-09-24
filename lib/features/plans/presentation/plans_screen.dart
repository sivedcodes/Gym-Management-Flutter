import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/auth/session.dart';
import '../../../core/models/app_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/brand.dart';
import '../../../core/widgets/motion.dart';
import '../../../core/widgets/state_views.dart';

/// Member: pick a plan. Owner: full CRUD + show/hide.
class PlansScreen extends ConsumerWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(fakeDbProvider);
    final me = ref.watch(currentUserProvider);
    final isOwner = me?.role == 'owner';
    final plans = isOwner
        ? (db.plans.values.toList()
          ..sort((a, b) => a.price.compareTo(b.price)))
        : (db.activePlans()..sort((a, b) => a.price.compareTo(b.price)));

    return Scaffold(
      appBar: AppBar(
        title: Text(isOwner ? 'Manage plans' : 'Choose your plan'),
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(AppIcons.add),
              tooltip: 'New plan',
              onPressed: () => _planDialog(context, ref, null),
            ),
        ],
      ),
      body: MaxWidth(
        child: plans.isEmpty
            ? EmptyView(
                icon: isOwner
                    ? AppIcons.addCard
                    : AppIcons.membershipOut,
                title: isOwner
                    ? 'No plans created yet'
                    : 'No plans available',
                subtitle: isOwner
                    ? 'Tap + to add your first membership plan.'
                    : 'Ask the gym owner to add plans.',
                actionLabel: isOwner ? 'Add first plan' : null,
                onAction:
                    isOwner ? () => _planDialog(context, ref, null) : null,
              )
            : ListView.builder(
                padding: AppSpace.list,
                itemCount: plans.length,
                itemBuilder: (_, i) => FadeSlideIn(
                  delay: Duration(milliseconds: i * 70),
                  child: _PlanCard(
                    plan: plans[i],
                    popular: plans[i]
                        .name
                        .toLowerCase()
                        .contains('quarter'),
                    isOwner: isOwner,
                    onSelect: () =>
                        context.push('/register?plan=${plans[i].id}'),
                    onEdit: () => _planDialog(context, ref, plans[i]),
                    onToggle: () => db.upsertPlan(
                      plans[i].copyWith(active: !plans[i].active),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  void _planDialog(BuildContext context, WidgetRef ref, GymPlan? existing) {
    final name = TextEditingController(text: existing?.name ?? '');
    final price = TextEditingController(
        text: existing == null ? '' : existing.price.toString());
    final days = TextEditingController(
        text: existing == null ? '30' : existing.durationDays.toString());
    final desc = TextEditingController(text: existing?.desc ?? '');
    final form = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existing == null ? 'New plan' : 'Edit plan'),
        content: Form(
          key: form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: name,
                  style: const TextStyle(color: AppColors.white),
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(AppIcons.label),
                  ),
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: AppSpace.m),
                TextFormField(
                  controller: price,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.white),
                  decoration: const InputDecoration(
                    labelText: 'Price (₹)',
                    prefixIcon: Icon(AppIcons.rupee),
                  ),
                  validator: (v) =>
                      (int.tryParse(v ?? '') ?? 0) <= 0
                          ? 'Invalid price'
                          : null,
                ),
                const SizedBox(height: AppSpace.m),
                TextFormField(
                  controller: days,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.white),
                  decoration: const InputDecoration(
                    labelText: 'Duration (days)',
                    prefixIcon: Icon(AppIcons.calendar),
                  ),
                  validator: (v) {
                    final n = int.tryParse(v ?? '') ?? 0;
                    return (n < 1 || n > 1825) ? '1–1825 days' : null;
                  },
                ),
                const SizedBox(height: AppSpace.m),
                TextFormField(
                  controller: desc,
                  style: const TextStyle(color: AppColors.white),
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(AppIcons.desc),
                  ),
                ),
              ],
            ),
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
              final db = ref.read(fakeDbProvider);
              if (existing == null) {
                db.createPlan(
                  name.text.trim(),
                  int.parse(price.text),
                  int.parse(days.text),
                  desc.text.trim(),
                );
              } else {
                db.upsertPlan(existing.copyWith(
                  name: name.text.trim(),
                  price: int.parse(price.text),
                  durationDays: int.parse(days.text),
                  desc: desc.text.trim(),
                ));
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

class _PlanCard extends StatelessWidget {
  final GymPlan plan;
  final bool popular;
  final bool isOwner;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  const _PlanCard({
    required this.plan,
    required this.popular,
    required this.isOwner,
    required this.onSelect,
    required this.onEdit,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final price = NumberFormat.decimalPattern('en_IN').format(plan.price);
    final perDay = (plan.price / plan.durationDays).round();
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpace.m),
      decoration: BoxDecoration(
        gradient: popular ? AppGradients.yellowCard : null,
        color: popular ? null : AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.l),
        border: Border.all(
          color: popular
              ? AppColors.yellow.withValues(alpha: 0.5)
              : AppColors.line,
        ),
      ),
      child: Padding(
        padding: AppSpace.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconTile(
                  AppIcons.bolt,
                  color: popular ? AppColors.yellow : AppColors.grey,
                  size: AppIcon.tile,
                ),
                const SizedBox(width: AppSpace.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plan.name, style: AppText.head),
                      Text('₹$perDay / day', style: AppText.tiny),
                    ],
                  ),
                ),
                if (popular && !isOwner)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpace.s, vertical: AppSpace.xs),
                    decoration: BoxDecoration(
                      color: AppColors.yellow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'POPULAR',
                      style: AppText.eyebrow.copyWith(
                        color: AppColors.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                if (!plan.active && isOwner)
                  Text(
                    'HIDDEN',
                    style: AppText.label.copyWith(color: AppColors.red),
                  ),
              ],
            ),
            const SizedBox(height: AppSpace.l),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: AppSpace.s,
              children: [
                Text('₹$price', style: AppText.display),
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpace.xxs),
                  child: Text(
                    '/ ${plan.durationDays} days',
                    style: AppText.small,
                  ),
                ),
              ],
            ),
            if (plan.desc.isNotEmpty) ...[
              const SizedBox(height: AppSpace.m),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(AppIcons.enrolled,
                      size: AppIcon.sm, color: AppColors.green),
                  const SizedBox(width: AppSpace.s),
                  Expanded(
                    child: Text(plan.desc, style: AppText.small),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSpace.l),
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
                              const Size(48, AppSizes.btnSecondary)),
                    ),
                  ),
                  const SizedBox(width: AppSpace.s),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onToggle,
                      icon: Icon(
                          plan.active
                              ? AppIcons.hide
                              : AppIcons.show,
                          size: AppIcon.sm),
                      label: Text(plan.active ? 'Hide' : 'Show'),
                      style: OutlinedButton.styleFrom(
                          minimumSize:
                              const Size(48, AppSizes.btnSecondary)),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: onSelect,
                    child: const Text('Select this plan')),
              ),
          ],
        ),
      ),
    );
  }
}
