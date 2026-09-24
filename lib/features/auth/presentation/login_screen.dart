import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/session.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/brand.dart';
import '../../../core/widgets/motion.dart';

/// Redesigned premium login screen with athletic ambient animations,
/// official vector Google sign-in mark, and exclusive Google authentication.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.55),
            radius: 1.2,
            colors: [
              Color(0xFF221E0A),
              Color(0xFF0F0F12),
              Color(0xFF08080A),
            ],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: MaxWidth(
          maxWidth: 480,
          child: SafeArea(
            child: ListView(
              padding: AppSpace.screen,
              children: [
                const SizedBox(height: AppSpace.s),

                // ── Hero Section with Spring Ambient Glow ──
                const FadeSlideIn(
                  duration: Duration(milliseconds: 500),
                  child: Center(
                    child: _AmbientPulse(
                      child: GymLogo(size: 64),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpace.s),

                // ── Athletic Badge & Headline ──
                FadeSlideIn(
                  delay: const Duration(milliseconds: 80),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.yellow.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.yellow.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.yellow,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'ATHLETIC CLUB & FITNESS SUITE',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppText.navLabel.copyWith(
                                  color: AppColors.yellow,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpace.xs),
                      Text(
                        'Your gym, professionally managed.',
                        textAlign: TextAlign.center,
                        style: AppText.body.copyWith(
                          color: AppColors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpace.m),

                // ── Value Pillars (Workout Splits, Trainers, Digital Passes) ──
                FadeSlideIn(
                  delay: const Duration(milliseconds: 140),
                  child: const _FeatureRow(
                    icon: AppIcons.splitPpl,
                    title: 'Smart Workout Splits',
                    subtitle: 'Push Pull Legs, Bro split, Arnold & weekly schedule',
                  ),
                ),
                const SizedBox(height: AppSpace.s),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 200),
                  child: const _FeatureRow(
                    icon: AppIcons.trainer,
                    title: 'Certified Trainers & PT',
                    subtitle: 'Coaches, morning/evening shifts & expert guidance',
                  ),
                ),
                const SizedBox(height: AppSpace.s),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 260),
                  child: const _FeatureRow(
                    icon: AppIcons.verified,
                    title: 'Instant Membership Pass',
                    subtitle: 'Live validity, renewal alerts & gym access',
                  ),
                ),

                const SizedBox(height: AppSpace.m),

                // ── Professional Google Sign-In Button (Primary & Exclusive) ──
                FadeSlideIn(
                  delay: const Duration(milliseconds: 320),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1F1F1F),
                        elevation: 4,
                        shadowColor: AppColors.yellow.withValues(alpha: 0.35),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.l),
                          side: const BorderSide(
                            color: Color(0xFFE2E4E8),
                            width: 1.2,
                          ),
                        ),
                      ),
                      onPressed: () => mockGoogleLogin(ref),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const GoogleMark(size: 22),
                          const SizedBox(width: AppSpace.m),
                          Flexible(
                            child: Text(
                              'Continue with Google',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.title.copyWith(
                                color: const Color(0xFF1F1F1F),
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpace.s),

                // ── Security & Privacy Note ──
                FadeSlideIn(
                  delay: const Duration(milliseconds: 360),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            size: 13,
                            color: AppColors.faint,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Secure Google Sign-In · Instant profile sync',
                            style: AppText.tiny.copyWith(
                              color: AppColors.faint,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpace.m),

                // ── Demo Console for Instant Exploration ──
                FadeSlideIn(
                  delay: const Duration(milliseconds: 400),
                  child: Card(
                    margin: EdgeInsets.zero,
                    color: AppColors.cardHi,
                    child: ExpansionTile(
                      tilePadding: AppSpace.card,
                      childrenPadding: const EdgeInsets.only(
                        left: AppSpace.l,
                        right: AppSpace.l,
                        bottom: AppSpace.l,
                      ),
                      leading: const Icon(
                        AppIcons.demo,
                        size: AppIcon.btn,
                        color: AppColors.yellow,
                      ),
                      title: Text('DEMO CONSOLE', style: AppText.eyebrow),
                      subtitle: Text(
                        'Explore member & owner roles in 1-tap:',
                        style: AppText.small,
                      ),
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => demoLogin(ref, 'u_active'),
                                icon: const Icon(
                                  AppIcons.profile,
                                  size: AppIcon.btn,
                                ),
                                label: const Text('Member'),
                              ),
                            ),
                            const SizedBox(width: AppSpace.m),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => demoLogin(ref, 'owner_1'),
                                icon: const Icon(
                                  AppIcons.gym,
                                  size: AppIcon.btn,
                                ),
                                label: const Text('Owner'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpace.l),
                const DeveloperCredit(),
                const SizedBox(height: AppSpace.m),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Spring ambient glow animation behind the hero logo.
class _AmbientPulse extends StatelessWidget {
  final Widget child;
  const _AmbientPulse({required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutBack,
      builder: (context, val, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 90 + 35 * val,
              height: 90 + 35 * val,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.yellow.withValues(alpha: 0.22 * val),
                    AppColors.yellow.withValues(alpha: 0.05 * val),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Transform.scale(
              scale: 0.88 + 0.12 * val,
              child: child,
            ),
          ],
        );
      },
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.m,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.l),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.yellow.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.m),
              border: Border.all(
                color: AppColors.yellow.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.yellow,
            ),
          ),
          const SizedBox(width: AppSpace.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppText.title.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.small.copyWith(
                    color: AppColors.grey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
