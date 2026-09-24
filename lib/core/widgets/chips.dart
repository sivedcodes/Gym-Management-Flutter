import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';

// ─────────────────────────────────────────────────────────────────────────────
// STATUS CHIP
// Soft-tinted pill: dot + coloured label. Used on every list and card.
// ─────────────────────────────────────────────────────────────────────────────

/// Modern soft status pill: tinted bg + dot + colored label.
class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip(this.status, {super.key});

  Color get _color => switch (status) {
        'active' || 'approved' || 'resolved' => AppColors.green,
        'expiring_soon' || 'pending' || 'in_progress' || 'medium' => AppColors.yellow,
        'expired' || 'denied' || 'urgent' || 'high' => AppColors.red,
        'low' => AppColors.blue,
        _ => AppColors.grey,
      };

  String get _label => switch (status) {
        'expiring_soon' => 'Expiring soon',
        'in_progress' => 'In Progress',
        _ => status.isEmpty ? '' : status[0].toUpperCase() + status.substring(1),
      };

  @override
  Widget build(BuildContext context) {
    final c = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppSizes.dot,
            height: AppSizes.dot,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpace.s / 1.33), // 6px gap
          Text(
            _label,
            style: AppText.label.copyWith(
              color: c,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION HEADER
// Title + optional action text button. Spacing below handled by caller using
// AppSpace.sectionHeaderGap (= AppSpace.xs = 4) for consistency.
// ─────────────────────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.head,
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.yellow,
              textStyle: AppText.label.copyWith(color: AppColors.yellow),
            ),
            child: Text(action!),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CHOICE CHIP (filter)
// Compact filter chip: identical padding, height and colours everywhere.
// ─────────────────────────────────────────────────────────────────────────────

/// Filter / choice chip used for category, price, and member status filters.
class AppChoice extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  const AppChoice(this.label, this.selected, this.onTap,
      {super.key, this.icon});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      avatar: icon == null
          ? null
          : Icon(icon,
              size: 18,
              color: selected
                  ? AppColors.black
                  : AppColors.grey),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.yellow,
      backgroundColor: AppColors.cardHi,
      visualDensity: VisualDensity.compact,
      labelPadding: const EdgeInsets.symmetric(horizontal: AppSpace.s),
      labelStyle: AppText.chip.copyWith(
        color: selected ? AppColors.black : AppColors.grey,
      ),
      side: BorderSide(
        color: selected ? AppColors.yellow : AppColors.line,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
