import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/auth/session.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/brand.dart';
import '../../../core/widgets/motion.dart';

/// Clean, focused, cardless athletic login screen.
/// Features a commanding brand hero, official Google sign-in CTA,
/// facilities tour navigation, and discreet demo access without visual clutter.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.5),
            radius: 1.3,
            colors: [
              Color(0xFF261E08),
              Color(0xFF0F0F12),
              Color(0xFF08080A),
            ],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: MaxWidth(
          maxWidth: 440,
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.xl,
                vertical: AppSpace.xl,
              ),
              children: [
                const SizedBox(height: AppSpace.m),

                // ── Hero Section with Spring Ambient Glow ──
                const FadeSlideIn(
                  duration: Duration(milliseconds: 500),
                  child: Center(
                    child: _AmbientPulse(
                      child: GymLogo(size: 84),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpace.l),

                // ── Athletic Badge ──
                FadeSlideIn(
                  delay: const Duration(milliseconds: 70),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 5,
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
                          const SizedBox(width: 7),
                          Flexible(
                            child: Text(
                              'ATHLETIC CLUB & FITNESS SUITE',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.navLabel.copyWith(
                                color: AppColors.yellow,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                                fontSize: 10.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpace.m),

                // ── Headline & Subtitle ──
                FadeSlideIn(
                  delay: const Duration(milliseconds: 120),
                  child: Column(
                    children: [
                      Text(
                        'Elevate Your Discipline',
                        textAlign: TextAlign.center,
                        style: AppText.displaySm.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Smart workout splits, verified trainers & instant digital passes.',
                        textAlign: TextAlign.center,
                        style: AppText.body.copyWith(
                          color: AppColors.grey,
                          fontSize: 13.5,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpace.xl),

                // ── Cardless Feature Badges (Pills) ──
                FadeSlideIn(
                  delay: const Duration(milliseconds: 160),
                  child: Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        _FeaturePill(
                          icon: AppIcons.splitPpl,
                          label: 'Smart Splits',
                        ),
                        _FeaturePill(
                          icon: AppIcons.trainer,
                          label: 'Certified Coaches',
                        ),
                        _FeaturePill(
                          icon: AppIcons.verified,
                          label: 'Digital Passes',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpace.xxxl),

                // ── Single Primary Google Button ──
                FadeSlideIn(
                  delay: const Duration(milliseconds: 210),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1B1B1B),
                        elevation: 3,
                        shadowColor: AppColors.yellow.withValues(alpha: 0.3),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.l),
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
                                color: const Color(0xFF1B1B1B),
                                fontSize: 15.5,
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

                // ── Security Trust Caption ──
                FadeSlideIn(
                  delay: const Duration(milliseconds: 240),
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
                            'Official Google Sign-In · Instant profile sync',
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

                const SizedBox(height: AppSpace.l),

                // ── Secondary Action: Gym Facilities Tour ──
                FadeSlideIn(
                  delay: const Duration(milliseconds: 280),
                  child: Center(
                    child: TextButton(
                      onPressed: () => context.push('/intro'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.yellow,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              AppIcons.gym,
                              size: 16,
                              color: AppColors.yellow,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Explore Gym & Facilities Tour →',
                              style: AppText.body.copyWith(
                                color: AppColors.yellow,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpace.m),

                // ── Discreet Demo Access (Cardless & Minimal) ──
                FadeSlideIn(
                  delay: const Duration(milliseconds: 320),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              AppIcons.demo,
                              size: 13,
                              color: AppColors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Demo: ',
                              style: AppText.tiny.copyWith(
                                color: AppColors.grey,
                                fontSize: 11,
                              ),
                            ),
                            InkWell(
                              onTap: () => demoLogin(ref, 'u_active'),
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                child: Text(
                                  'Member',
                                  style: AppText.tiny.copyWith(
                                    color: AppColors.yellow,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              '·',
                              style: TextStyle(
                                color: AppColors.faint,
                                fontSize: 12,
                              ),
                            ),
                            InkWell(
                              onTap: () => demoLogin(ref, 'owner_1'),
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                child: Text(
                                  'Owner',
                                  style: AppText.tiny.copyWith(
                                    color: AppColors.yellow,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpace.xxl),
                const DeveloperCredit(),
                const SizedBox(height: AppSpace.l),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Lightweight floating feature pill badge (cardless).
class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeaturePill({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.09),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: AppColors.yellow,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppText.tiny.copyWith(
              color: AppColors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
              fontSize: 11.5,
            ),
          ),
        ],
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
              width: 120 + 45 * val,
              height: 120 + 45 * val,
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
              scale: 0.9 + 0.1 * val,
              child: child,
            ),
          ],
        );
      },
    );
  }
}
