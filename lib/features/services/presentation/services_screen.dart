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
import '../../../core/widgets/search_filter_bar.dart';

/// Browse dynamic programs: training, diet, yoga … any owner-added kind.
/// Kind + price filters are built from live data — never hardcoded.
class ServicesScreen extends ConsumerStatefulWidget {
  /// Optional deep-link filter, e.g. /services?kind=diet.
  final String? initialKind;
  const ServicesScreen({super.key, this.initialKind});
  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  late String _kind;
  String _price = 'all'; // all | free | paid
  String _query = '';
  bool _mine = false;

  @override
  void initState() {
    super.initState();
    _kind = widget.initialKind ?? 'all';
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(fakeDbProvider);
    final me = ref.watch(currentUserProvider);
    final isOwner = me?.role == 'owner';
    final kinds = db.serviceKinds(activeOnly: !isOwner);
    final myIds = me == null
        ? <String>{}
        : db.myBookings(me.uid).map((b) => b.serviceId).toSet();

    final items = db
        .servicesList(activeOnly: !isOwner)
        .where((s) {
          if (_kind != 'all' && s.kind != _kind) return false;
          if (_price == 'free' && !s.isFree) return false;
          if (_price == 'paid' && s.isFree) return false;
          if (_mine && !myIds.contains(s.id)) return false;
          final q = _query.toLowerCase();
          if (q.isNotEmpty &&
              !'${s.title} ${s.goal} ${s.kind}'.toLowerCase().contains(q)) {
            return false;
          }
          return true;
        })
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(isOwner ? 'Programs' : 'Training & diet plans'),
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(AppIcons.add),
              tooltip: 'New program',
              onPressed: () => _serviceDialog(context, ref, null, kinds),
            )
          else
            IconButton(
              icon: Icon(_mine
                  ? AppIcons.bookmarkActive
                  : AppIcons.bookmark),
              color:
                  _mine ? AppColors.yellow : AppColors.grey,
              tooltip: 'My enrollments',
              onPressed: () => setState(() => _mine = !_mine),
            ),
        ],
      ),
      body: MaxWidth(
        child: Column(
          children: [
            SearchFilterBar(
              hint: 'Search muscle gain, diet…',
              onQuery: (v) => setState(() => _query = v),
              chips: [
                (
                  label: 'All',
                  selected: _kind == 'all',
                  onTap: () => setState(() => _kind = 'all'),
                ),
                ...kinds.map((k) => (
                      label: _prettyKind(k),
                      selected: _kind == k,
                      onTap: () => setState(() => _kind = k),
                    )),
                (
                  label: 'Free',
                  selected: _price == 'free',
                  onTap: () => setState(
                      () => _price = _price == 'free' ? 'all' : 'free'),
                ),
                (
                  label: 'Paid',
                  selected: _price == 'paid',
                  onTap: () => setState(
                      () => _price = _price == 'paid' ? 'all' : 'paid'),
                ),
              ],
            ),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Padding(
                        padding: AppSpace.screen,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const IconTile(
                                AppIcons.searchOff,
                                color: AppColors.faint,
                                size: AppIcon.hero),
                            const SizedBox(height: AppSpace.s),
                            Text(
                              _mine
                                  ? 'No enrollments yet'
                                  : 'Nothing here',
                              style: AppText.title,
                            ),
                            const SizedBox(height: AppSpace.xs),
                            Text(
                              _mine
                                  ? 'Enroll in a program and it shows up here.'
                                  : 'Try a different search or filter.',
                              style: AppText.small,
                            ),
                            if (_mine) ...[
                              const SizedBox(height: AppSpace.m),
                              OutlinedButton(
                                onPressed: () =>
                                    setState(() => _mine = false),
                                child: const Text('Browse all'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpace.l, AppSpace.s, AppSpace.l, AppSpace.xl),
                      itemCount: items.length,
                      itemBuilder: (_, i) => FadeSlideIn(
                        delay: Duration(milliseconds: i * 50),
                        child: _ServiceCard(
                          item: items[i],
                          isOwner: isOwner,
                          enrolled: myIds.contains(items[i].id),
                          onBook: () => context
                              .push('/services/book?id=${items[i].id}'),
                          onEdit: () => _serviceDialog(
                              context, ref, items[i], kinds),
                          onToggle: () => db.updateService(items[i]
                              .copyWith(active: !items[i].active)),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _prettyKind(String k) =>
      k.isEmpty ? k : k[0].toUpperCase() + k.substring(1);

  void _serviceDialog(BuildContext context, WidgetRef ref, ServiceItem? e,
      List<String> kinds) {
    final title = TextEditingController(text: e?.title ?? '');
    final goal = TextEditingController(text: e?.goal ?? '');
    final price = TextEditingController(
        text: e == null ? '' : e.price.toString());
    final days = TextEditingController(
        text: e == null ? '30' : e.durationDays.toString());
    final desc = TextEditingController(text: e?.desc ?? '');
    var kind = e?.kind ?? (kinds.isNotEmpty ? kinds.first : 'training');
    var customKind = '';
    var level = e?.level ?? 'All';
    var isNewKind = false;
    final form = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text(e == null ? 'New program' : 'Edit program'),
          content: Form(
            key: form,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: kinds.contains(kind) ? kind : null,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon:
                          Icon(AppIcons.category),
                    ),
                    items: [
                      ...kinds.map((k) => DropdownMenuItem(
                          value: k, child: Text(_prettyKind(k)))),
                      const DropdownMenuItem(
                          value: '__new',
                          child: Text('+ New category…')),
                    ],
                    onChanged: (v) => setD(() {
                      isNewKind = v == '__new';
                      if (!isNewKind && v != null) kind = v;
                    }),
                  ),
                  if (isNewKind) ...[
                    const SizedBox(height: AppSpace.m),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'New category name',
                        hintText: 'e.g. cardio, physio',
                      ),
                      onChanged: (v) => customKind = v,
                      validator: (v) => isNewKind &&
                              (v ?? '').trim().isEmpty
                          ? 'Required'
                          : null,
                    ),
                  ],
                  const SizedBox(height: AppSpace.m),
                  TextFormField(
                    controller: title,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'e.g. Muscle Gain Pro',
                    ),
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpace.m),
                  TextFormField(
                    controller: goal,
                    decoration: const InputDecoration(
                      labelText: 'Goal',
                      hintText: 'e.g. Muscle Gain, Weight Loss',
                    ),
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpace.m),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: price,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Price ₹ (0 = free)'),
                          validator: (v) =>
                              (int.tryParse(v ?? '') ?? -1) < 0
                                  ? 'Invalid'
                                  : null,
                        ),
                      ),
                      const SizedBox(width: AppSpace.m),
                      Expanded(
                        child: TextFormField(
                          controller: days,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Days'),
                          validator: (v) {
                            final n = int.tryParse(v ?? '') ?? 0;
                            return (n < 1 || n > 1825)
                                ? '1–1825'
                                : null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.m),
                  DropdownButtonFormField<String>(
                    initialValue: level,
                    decoration: const InputDecoration(
                        labelText: 'Level'),
                    items: const ['All', 'Beginner', 'Intermediate', 'Advanced']
                        .map((l) => DropdownMenuItem(
                            value: l, child: Text(l)))
                        .toList(),
                    onChanged: (v) =>
                        setD(() => level = v ?? 'All'),
                  ),
                  const SizedBox(height: AppSpace.m),
                  TextFormField(
                    controller: desc,
                    maxLines: 2,
                    decoration: const InputDecoration(
                        labelText: 'Description'),
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
                if (!form.currentState!.validate()) return;
                final finalKind = isNewKind
                    ? customKind.trim().toLowerCase()
                    : kind;
                final db = ref.read(fakeDbProvider);
                if (e == null) {
                  db.createService(
                    kind: finalKind,
                    title: title.text,
                    goal: goal.text,
                    price: int.parse(price.text),
                    durationDays: int.parse(days.text),
                    level: level,
                    desc: desc.text,
                  );
                } else {
                  db.updateService(e.copyWith(
                    kind: finalKind,
                    title: title.text.trim(),
                    goal: goal.text.trim(),
                    price: int.parse(price.text),
                    durationDays: int.parse(days.text),
                    level: level,
                    desc: desc.text.trim(),
                  ));
                }
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

class _ServiceCard extends StatelessWidget {
  final ServiceItem item;
  final bool isOwner;
  final bool enrolled;
  final VoidCallback onBook;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  const _ServiceCard({
    required this.item,
    required this.isOwner,
    this.enrolled = false,
    required this.onBook,
    required this.onEdit,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final priceLabel =
        item.isFree ? 'FREE' : '₹${NumberFormat.decimalPattern('en_IN').format(item.price)}';
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpace.cardGap),
      child: Padding(
        padding: AppSpace.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconTile(AppIcons.kindIcon(item.kind),
                    size: AppIcon.tile,
                    color: enrolled
                        ? AppColors.green
                        : AppColors.yellow),
                const SizedBox(width: AppSpace.s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(item.title,
                                style: AppText.title),
                          ),
                          if (enrolled && !isOwner)
                            const Icon(
                                AppIcons.enrolled,
                                size: AppIcon.xs,
                                color: AppColors.green),
                        ],
                      ),
                      Text(
                        '${item.goal} · ${item.level} · ${item.durationDays} days',
                        style: AppText.tiny,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpace.s),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.isFree
                        ? AppColors.green.withValues(alpha: 0.13)
                        : AppColors.yellow.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: item.isFree
                          ? AppColors.green.withValues(alpha: 0.35)
                          : AppColors.yellow.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    priceLabel,
                    style: AppText.label.copyWith(
                      color: item.isFree
                          ? AppColors.green
                          : AppColors.yellow,
                    ),
                  ),
                ),
              ],
            ),
            if (item.desc.isNotEmpty) ...[
              const SizedBox(height: AppSpace.s),
              Text(item.desc, style: AppText.small),
            ],
            const SizedBox(height: AppSpace.s),
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
                          minimumSize: const Size(48, AppSizes.btnSecondary)),
                    ),
                  ),
                  const SizedBox(width: AppSpace.s),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onToggle,
                      icon: Icon(
                          item.active
                              ? AppIcons.hide
                              : AppIcons.show,
                          size: AppIcon.sm),
                      label: Text(item.active ? 'Hide' : 'Show'),
                      style: OutlinedButton.styleFrom(
                          minimumSize: const Size(48, AppSizes.btnSecondary)),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onBook,
                  child: Text(
                      item.isFree ? 'Enroll free' : 'Request · $priceLabel'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
