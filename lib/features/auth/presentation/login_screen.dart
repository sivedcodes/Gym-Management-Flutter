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

/// Public login: brand hero + Google CTA + demo console.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.loginBg),
        child: MaxWidth(
          maxWidth: 480,
          child: SafeArea(
            child: ListView(
              padding: AppSpace.screen,
              children: [
                const SizedBox(height: AppSpace.m),
                const FadeSlideIn(child: GymLogo(size: 64)),
                const SizedBox(height: AppSpace.m),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 80),
                  child: Text(
                    'Your gym, professionally managed.',
                    textAlign: TextAlign.center,
                    style: AppText.body.copyWith(color: AppColors.grey),
                  ),
                ),
                const SizedBox(height: AppSpace.l),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 140),
                  child: const _FeatureRow(
                    icon: AppIcons.qrShow,
                    title: 'Scan & join',
                    subtitle: 'QR at the entrance, register in a minute',
                  ),
                ),
                const SizedBox(height: AppSpace.s),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 200),
                  child: const _FeatureRow(
                    icon: AppIcons.verified,
                    title: 'Owner-verified membership',
                    subtitle: 'Pay at gym, approval activates instantly',
                  ),
                ),
                const SizedBox(height: AppSpace.s),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 260),
                  child: const _FeatureRow(
                    icon: AppIcons.bellRing,
                    title: 'Never miss expiry',
                    subtitle: 'Smart reminders before your plan ends',
                  ),
                ),
                const SizedBox(height: AppSpace.l),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 320),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                      ),
                      onPressed: () => mockGoogleLogin(ref),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GoogleMark(),
                          SizedBox(width: AppSpace.m),
                          Text('Continue with Google'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpace.s),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 380),
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/join?gym=demo-gym'),
                    icon: const Icon(AppIcons.qrScan,
                        size: AppIcon.btn),
                    label: const Text('I have a QR / join link'),
                  ),
                ),
                const SizedBox(height: AppSpace.l),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 440),
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: ExpansionTile(
                      tilePadding: AppSpace.card,
                      childrenPadding: const EdgeInsets.only(
                          left: AppSpace.l,
                          right: AppSpace.l,
                          bottom: AppSpace.l),
                      leading: const Icon(AppIcons.demo,
                          size: AppIcon.btn,
                          color: AppColors.grey),
                      title: Text('DEMO CONSOLE',
                          style: AppText.eyebrow),
                      subtitle: Text(
                        'No backend needed yet — explore both roles:',
                        style: AppText.small,
                      ),
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    demoLogin(ref, 'u_active'),
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
                                onPressed: () =>
                                    demoLogin(ref, 'owner_1'),
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
              ],
            ),
          ),
        ),
      ),
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
      padding: const EdgeInsets.all(AppSpace.m),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.m),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          IconTile(icon, size: AppIcon.tile),
          const SizedBox(width: AppSpace.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.title),
                const SizedBox(height: AppSpace.xs),
                Text(subtitle, style: AppText.small),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
