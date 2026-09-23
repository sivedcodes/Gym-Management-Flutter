import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_icons.dart';
import '../theme/tokens.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BRAND IDENTITY WIDGETS
// GymLogo · IconTile · InitialAvatar · GoogleMark
// All gradients resolved from AppGradients — one place to update branding.
// ─────────────────────────────────────────────────────────────────────────────

/// Brand logo: yellow gradient dumbbell tile + wordmark.
class GymLogo extends StatelessWidget {
  final double size;
  final bool showName;
  const GymLogo({super.key, this.size = 64, this.showName = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: AppGradients.logo,
            borderRadius: BorderRadius.circular(size * 0.28),
            boxShadow: [
              BoxShadow(
                color: AppColors.yellow.withValues(alpha: 0.35),
                blurRadius: size * 0.4,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Icon(
            AppIcons.training,
            size: size * 0.52,
            color: AppColors.black,
          ),
        ),
        if (showName) ...[
          SizedBox(height: size * 0.22),
          Text(
            'TOTAL FIT GYM',
            style: AppText.display.copyWith(fontSize: size * 0.34),
          ),
        ],
      ],
    );
  }
}

/// Small square tinted icon tile used across cards and lists.
/// The [size] drives both the container and the icon proportionally.
class IconTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  const IconTile(
    this.icon, {
    super.key,
    this.color = AppColors.yellow,
    this.size = AppIcon.tile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(size * 0.32),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}

/// Circular avatar displaying the first initial of [name].
class InitialAvatar extends StatelessWidget {
  final String name;
  final double radius;
  const InitialAvatar(this.name, {super.key, this.radius = 22});

  @override
  Widget build(BuildContext context) {
    final initial =
        name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppGradients.avatar,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppText.displaySm.copyWith(
          color: AppColors.black,
          fontSize: radius * 0.85,
        ),
      ),
    );
  }
}

/// Google "G" mark used inside the sign-in button.
class GoogleMark extends StatelessWidget {
  const GoogleMark({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.googleMark,
      height: AppSizes.googleMark,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        'G',
        style: AppText.title.copyWith(
          fontWeight: FontWeight.w800,
          color: const Color(0xFF4285F4),
        ),
      ),
    );
  }
}
