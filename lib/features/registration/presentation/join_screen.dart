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

/// Public entry from gym QR. Signed-out → mock Google, signed-in → plans.
class JoinScreen extends ConsumerWidget {
  final String? gymId;
  const JoinScreen({super.key, this.gymId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(currentUserProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Join Total Fit Gym')),
      body: MaxWidth(
        maxWidth: 480,
        child: Padding(
          padding: AppSpace.screen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpace.l),
              const FadeSlideIn(
                child: Center(
                    child: IconTile(AppIcons.qrShow,
                        size: AppSizes.heroTile)),
              ),
              const SizedBox(height: AppSpace.l),
              FadeSlideIn(
                delay: const Duration(milliseconds: 80),
                child: Text(
                  'You\'re one step away',
                  textAlign: TextAlign.center,
                  style: AppText.displaySm,
                ),
              ),
              const SizedBox(height: AppSpace.s),
              if (gymId != null)
                FadeSlideIn(
                  delay: const Duration(milliseconds: 140),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpace.l, vertical: AppSpace.xxs),
                      decoration: BoxDecoration(
                        color: AppColors.yellow.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.yellow.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(AppIcons.gym,
                              size: AppIcon.xs,
                              color: AppColors.yellow),
                          const SizedBox(width: AppSpace.xxs),
                          Text(
                            'Gym code: $gymId',
                            style: AppText.label.copyWith(
                              color: AppColors.yellow,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: AppSpace.l),
              const FadeSlideIn(
                delay: Duration(milliseconds: 200),
                child: _Step(text: 'Sign in with Google'),
              ),
              const FadeSlideIn(
                delay: Duration(milliseconds: 260),
                child: _Step(text: 'Add mobile number'),
              ),
              const FadeSlideIn(
                delay: Duration(milliseconds: 320),
                child: _Step(
                    text: 'Pick a plan, owner approves', last: true),
              ),
              const Spacer(),
              if (me == null)
                FadeSlideIn(
                  delay: const Duration(milliseconds: 380),
                  child: ElevatedButton.icon(
                    onPressed: () => mockGoogleLogin(ref),
                    icon: const GoogleMark(),
                    label: const Text('Continue with Google'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                    ),
                  ),
                )
              else
                FadeSlideIn(
                  delay: const Duration(milliseconds: 380),
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/plans'),
                    icon: const Icon(AppIcons.forward),
                    label: const Text('View plans'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String text;
  final bool last;
  const _Step({required this.text, this.last = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: AppSizes.stepDot,
              height: AppSizes.stepDot,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.yellow.withValues(alpha: 0.5)),
              ),
              alignment: Alignment.center,
              child: const Icon(AppIcons.check,
                  size: AppIcon.xs, color: AppColors.yellow),
            ),
            if (!last)
              Container(
                  width: 1.5, height: 14, color: AppColors.line),
          ],
        ),
        const SizedBox(width: AppSpace.m),
        Text(text, style: AppText.body),
      ],
    );
  }
}
