import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/brand.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Firebase initialisation + auth-state check plugs in here.
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted && ref.read(authStatusProvider) == AuthStatus.unknown) {
        ref.read(authStatusProvider.notifier).state = AuthStatus.signedOut;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.splashBg,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const GymLogo(size: 84),
              const SizedBox(height: AppSpace.m),
              Text(
                'Train. Track. Transform.',
                style: AppText.small.copyWith(color: AppColors.grey),
              ),
              const SizedBox(height: AppSpace.xxl),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  color: AppColors.yellow,
                  strokeWidth: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
