import 'package:flutter/material.dart';
import '../theme/app_icons.dart';
import '../theme/tokens.dart';
import 'chips.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SEARCH + FILTER BAR
// Reusable column: TextField search + horizontal scrolling chip row.
// Previously duplicated verbatim in services_screen.dart and
// owner_dashboard_screen.dart (_MembersTab). One widget now.
// ─────────────────────────────────────────────────────────────────────────────

/// A chip descriptor for the [SearchFilterBar].
class FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const FilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => AppChoice(label, selected, onTap);
}

/// Full search + chips bar.
///
/// [hint]        — TextField placeholder text.
/// [chips]       — ordered list of (label, isSelected, onTap) tuples.
/// [onQuery]     — called on every keystroke.
class SearchFilterBar extends StatelessWidget {
  final String hint;
  final List<({String label, bool selected, VoidCallback onTap})> chips;
  final ValueChanged<String> onQuery;

  const SearchFilterBar({
    super.key,
    required this.hint,
    required this.chips,
    required this.onQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: AppSpace.filterRow,
          child: TextField(
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: const Icon(AppIcons.search),
            ),
            onChanged: onQuery,
          ),
        ),
        SizedBox(
          height: AppSizes.chipRowHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.l),
            itemCount: chips.length,
            separatorBuilder: (context, _) =>
                const SizedBox(width: AppSpace.s),
            itemBuilder: (context, i) {
              final c = chips[i];
              return AppChoice(c.label, c.selected, c.onTap);
            },
          ),
        ),
        const SizedBox(height: AppSpace.xs),
      ],
    );
  }
}
