import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
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
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
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

/// Small, consistent app credit shown on the public entry screen and profile.
class DeveloperCredit extends StatelessWidget {
  const DeveloperCredit({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Developed by ${AppConstants.developerName}, ${AppConstants.developerUrl}',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Developed by '),
                TextSpan(
                  text: AppConstants.developerName,
                  style: AppText.label.copyWith(color: AppColors.yellow),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            style: AppText.tiny,
          ),
          const SizedBox(height: AppSpace.xs / 2),
          Text(
            AppConstants.developerUrl,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.tiny.copyWith(
              color: AppColors.grey,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.faint,
            ),
          ),
        ],
      ),
    );
  }
}

/// Official 4-color vector Google "G" logo painter adhering to Google Brand Guidelines.
class GoogleLogoPainter extends CustomPainter {
  const GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // 1. Blue segment (#4285F4)
    paint.color = const Color(0xFF4285F4);
    final blue = Path()
      ..moveTo(22.56, 12.25)
      ..cubicTo(22.56, 11.47, 22.49, 10.72, 22.36, 10.0)
      ..lineTo(12.0, 10.0)
      ..lineTo(12.0, 14.26)
      ..lineTo(17.92, 14.26)
      ..cubicTo(17.66, 15.63, 16.88, 16.79, 15.71, 17.57)
      ..lineTo(15.71, 20.34)
      ..lineTo(19.28, 20.34)
      ..cubicTo(21.36, 18.42, 22.56, 15.6, 22.56, 12.25)
      ..close();
    canvas.drawPath(blue, paint);

    // 2. Green segment (#34A853)
    paint.color = const Color(0xFF34A853);
    final green = Path()
      ..moveTo(12.0, 23.0)
      ..cubicTo(14.97, 23.0, 17.46, 22.02, 19.28, 20.34)
      ..lineTo(15.71, 17.57)
      ..cubicTo(14.73, 18.23, 13.48, 18.63, 12.0, 18.63)
      ..cubicTo(9.14, 18.63, 6.71, 16.7, 5.84, 14.1)
      ..lineTo(2.18, 14.1)
      ..lineTo(2.18, 16.94)
      ..cubicTo(3.99, 20.53, 7.7, 23.0, 12.0, 23.0)
      ..close();
    canvas.drawPath(green, paint);

    // 3. Yellow segment (#FBBC05)
    paint.color = const Color(0xFFFBBC05);
    final yellow = Path()
      ..moveTo(5.84, 14.1)
      ..cubicTo(5.62, 13.44, 5.49, 12.74, 5.49, 12.0)
      ..cubicTo(5.49, 11.26, 5.62, 10.56, 5.84, 9.9)
      ..lineTo(5.84, 7.06)
      ..lineTo(2.18, 7.06)
      ..cubicTo(1.43, 8.55, 1.0, 10.22, 1.0, 12.0)
      ..cubicTo(1.0, 13.78, 1.43, 15.45, 2.18, 16.94)
      ..lineTo(5.03, 14.72)
      ..lineTo(5.84, 14.1)
      ..close();
    canvas.drawPath(yellow, paint);

    // 4. Red segment (#EA4335)
    paint.color = const Color(0xFFEA4335);
    final red = Path()
      ..moveTo(12.0, 5.38)
      ..cubicTo(13.62, 5.38, 15.06, 5.94, 16.21, 7.02)
      ..lineTo(19.36, 3.87)
      ..cubicTo(17.45, 2.09, 14.97, 1.0, 12.0, 1.0)
      ..cubicTo(7.7, 1.0, 3.99, 3.47, 2.18, 7.06)
      ..lineTo(5.84, 9.9)
      ..cubicTo(6.71, 7.3, 9.14, 5.38, 12.0, 5.38)
      ..close();
    canvas.drawPath(red, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Official Google "G" vector mark used inside Google sign-in buttons.
class GoogleMark extends StatelessWidget {
  final double size;
  const GoogleMark({super.key, this.size = 22.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + 6,
      height: size + 6,
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: CustomPaint(
        size: Size(size, size),
        painter: const GoogleLogoPainter(),
      ),
    );
  }
}
