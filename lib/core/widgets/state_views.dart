import 'package:flutter/material.dart';
import 'brand.dart';
import '../theme/app_theme.dart';
import '../theme/app_icons.dart';
import '../theme/tokens.dart';
import 'motion.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SHARED STATE VIEWS
// LoadingView · EmptyView · ErrorView
// Every async screen reuses these — no blank white/black voids.
// ─────────────────────────────────────────────────────────────────────────────

/// Skeleton placeholder shown while data is loading.
class LoadingView extends StatelessWidget {
  final String? message;
  const LoadingView({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Skeleton(height: 120, width: 280, radius: 20),
          const SizedBox(height: AppSpace.m),
          const Skeleton(height: 14, width: 180),
          if (message != null) ...[
            const SizedBox(height: AppSpace.m),
            Text(message!, style: AppText.small),
          ],
        ],
      ),
    );
  }
}

/// Full-screen empty state: icon + title + subtitle + optional CTA.
class EmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  const EmptyView({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconTile(icon, color: AppColors.faint, size: AppIcon.hero),
            const SizedBox(height: AppSpace.l),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppText.head,
            ),
            const SizedBox(height: AppSpace.xs),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppText.small,
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: AppSpace.l),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Full-screen error state: icon + message + optional retry button.
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const ErrorView({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const IconTile(
              AppIcons.error,
              color: AppColors.red,
              size: AppIcon.hero,
            ),
            const SizedBox(height: AppSpace.l),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppText.body,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpace.l),
              OutlinedButton(
                onPressed: onRetry,
                child: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
