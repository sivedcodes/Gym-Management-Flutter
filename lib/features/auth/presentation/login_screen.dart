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

/// Spacious athletic login screen with ambient animations,
/// official vector Google sign-in mark, and balanced visual hierarchy.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.55),
            radius: 1.25,
            colors: [
              Color(0xFF241E08),
              Color(0xFF101014),
              Color(0xFF08080A),
            ],
            stops: [0.0, 0.48, 1.0],
          ),
        ),
        child: MaxWidth(
          maxWidth: 480,
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.l,
                AppSpace.xl,
                AppSpace.l,
                AppSpace.xxl,
              ),
              children: [
                // ── Hero Section with Spring Ambient Glow ──
                const FadeSlideIn(
                  duration: Duration(milliseconds: 500),
                  child: Center(
                    child: _AmbientPulse(
                      child: GymLogo(size: 80),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpace.l),

                // ── Athletic Badge & Headline ──
                FadeSlideIn(
                  delay: const Duration(milliseconds: 80),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
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
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: AppColors.yellow,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'ATHLETIC CLUB & FITNESS SUITE',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppText.navLabel.copyWith(
                                  color: AppColors.yellow,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpace.s),
                      Text(
                        'Your gym, professionally managed.\nTrack splits, renew passes & train smarter.',
                        textAlign: TextAlign.center,
                        style: AppText.body.copyWith(
                          color: AppColors.grey,
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpace.xl),

                // ── Unified Value Highlights Showcase ──
                FadeSlideIn(
                  delay: const Duration(milliseconds: 140),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.l,
                      vertical: AppSpace.m,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Column(
                      children: [
                        const _SpaciousFeatureItem(
                          icon: AppIcons.splitPpl,
                          title: 'Smart Workout Splits',
                          subtitle:
                              'Push Pull Legs, Bro split & personalized tracking',
                        ),
                        Divider(
                          color: AppColors.line.withValues(alpha: 0.8),
                          height: 22,
                          thickness: 1,
                        ),
                        const _SpaciousFeatureItem(
                          icon: AppIcons.trainer,
                          title: 'Certified Trainers & PT',
                          subtitle:
                              'Dedicated coaches, morning & evening batches',
                        ),
                        Divider(
                          color: AppColors.line.withValues(alpha: 0.8),
                          height: 22,
                          thickness: 1,
                        ),
                        const _SpaciousFeatureItem(
                          icon: AppIcons.verified,
                          title: 'Digital Membership Pass',
                          subtitle:
                              'Live validity countdown, renewal alerts & entry pass',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpace.xl),

                // ── Professional Google Sign-In Button (Primary & Exclusive) ──
                FadeSlideIn(
                  delay: const Duration(milliseconds: 220),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1F1F1F),
                        elevation: 3,
                        shadowColor: AppColors.yellow.withValues(alpha: 0.25),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
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
                          const GoogleMark(size: 24),
                          const SizedBox(width: AppSpace.m),
                          Flexible(
                            child: Text(
                              'Continue with Google',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.title.copyWith(
                                color: const Color(0xFF1F1F1F),
                                fontSize: 16,
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
                  delay: const Duration(milliseconds: 260),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            size: 14,
                            color: AppColors.faint,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Official Google Sign-In · Instant profile sync',
                            style: AppText.tiny.copyWith(
                              color: AppColors.faint,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpace.l),

                // ── About Gym / Intro Tour (Prominent Secondary CTA) ──
                FadeSlideIn(
                  delay: const Duration(milliseconds: 300),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        backgroundColor:
                            AppColors.yellow.withValues(alpha: 0.07),
                        foregroundColor: AppColors.yellow,
                        side: BorderSide(
                          color: AppColors.yellow.withValues(alpha: 0.38),
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.l),
                        ),
                      ),
                      onPressed: () => context.push('/intro'),
                      icon: const Icon(
                        AppIcons.gym,
                        size: 18,
                        color: AppColors.yellow,
                      ),
                      label: Text(
                        'Explore Gym & Facilities Tour →',
                        style: AppText.label.copyWith(
                          color: AppColors.yellow,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpace.xl),

                // ── Demo Exploration Console ──
                FadeSlideIn(
                  delay: const Duration(milliseconds: 340),
                  child: Card(
                    margin: EdgeInsets.zero,
                    color: AppColors.card,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.l),
                      side: const BorderSide(color: AppColors.line),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpace.l),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                AppIcons.demo,
                                size: 16,
                                color: AppColors.yellow,
                              ),
                              const SizedBox(width: AppSpace.s),
                              Text(
                                'DEMO EXPLORATION CONSOLE',
                                style: AppText.eyebrow.copyWith(
                                  color: AppColors.yellow,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpace.xs),
                          Text(
                            'Instant 1-tap preview without Google sign-in:',
                            style: AppText.small.copyWith(
                              color: AppColors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: AppSpace.m),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    side: const BorderSide(
                                      color: AppColors.line,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.m,
                                      ),
                                    ),
                                  ),
                                  onPressed: () => demoLogin(ref, 'u_active'),
                                  icon: const Icon(
                                    AppIcons.profile,
                                    size: 16,
                                  ),
                                  label: const Text('Member Role'),
                                ),
                              ),
                              const SizedBox(width: AppSpace.m),
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    side: BorderSide(
                                      color: AppColors.yellow.withValues(
                                        alpha: 0.45,
                                      ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.m,
                                      ),
                                    ),
                                  ),
                                  onPressed: () => demoLogin(ref, 'owner_1'),
                                  icon: const Icon(
                                    AppIcons.gym,
                                    size: 16,
                                    color: AppColors.yellow,
                                  ),
                                  label: const Text(
                                    'Owner Role',
                                    style: TextStyle(
                                      color: AppColors.yellow,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpace.xl),
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
              width: 110 + 45 * val,
              height: 110 + 45 * val,
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

class _SpaciousFeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SpaciousFeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.yellow.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.m),
              border: Border.all(
                color: AppColors.yellow.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(
              icon,
              size: 22,
              color: AppColors.yellow,
            ),
          ),
          const SizedBox(width: AppSpace.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppText.title.copyWith(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: AppText.small.copyWith(
                    color: AppColors.grey,
                    fontSize: 12,
                    height: 1.35,
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
