import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../utils/haptics.dart';

/// Bottom nav item spec.
class GlowNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int badge;
  const GlowNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badge = 0,
  });
}

/// Floating bottom nav: selected icon sits in a glowing yellow pill.
/// One widget powers member + owner navs — identical feel everywhere.
class GlowNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  final List<GlowNavItem> items;
  const GlowNav({
    super.key,
    required this.index,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: AppSpace.navBar,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.line),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.55),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (var i = 0; i < items.length; i++)
              _Btn(item: items[i], selected: i == index, onTap: () => onTap(i)),
          ],
        ),
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final GlowNavItem item;
  final bool selected;
  final VoidCallback onTap;
  const _Btn({required this.item, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // Subtle premium tick on every tab switch.
          softTick();
          onTap();
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Badge(
              label: Text('${item.badge}'),
              isLabelVisible: item.badge > 0,
              backgroundColor: AppColors.red,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                scale: selected ? 1.12 : 1.0,
                child: Icon(
                  selected ? item.activeIcon : item.icon,
                  size: AppIcon.nav,
                  color: selected ? AppColors.yellow : AppColors.faint,
                  shadows: selected
                      ? [
                          Shadow(
                            color: AppColors.yellow.withValues(alpha: 0.9),
                            blurRadius: 14,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
            const SizedBox(height: AppSpace.xs),
            Text(
              item.label,
              maxLines: 1,
              style: AppText.navLabel.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppColors.yellow : AppColors.faint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
