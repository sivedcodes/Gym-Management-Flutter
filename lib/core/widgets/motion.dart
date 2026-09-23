import 'package:flutter/material.dart';

/// Staggered entrance: fade + 16px rise. Wrap list items with
/// increasing [delay] for a modern cascade effect.
class FadeSlideIn extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 350),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration + delay,
      builder: (context, t, child) {
        final e = Curves.easeOutCubic.transform(
          ((t * (duration.inMilliseconds + delay.inMilliseconds) -
                      delay.inMilliseconds) /
                  duration.inMilliseconds)
              .clamp(0.0, 1.0),
        );
        return Opacity(
          opacity: e,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - e)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Lightweight skeleton block for loading states.
class Skeleton extends StatefulWidget {
  final double height;
  final double width;
  final double radius;
  const Skeleton({
    super.key,
    this.height = 16,
    this.width = double.infinity,
    this.radius = 8,
  });
  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) => Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: Color.lerp(
            const Color(0xFF1A1A20),
            const Color(0xFF26262E),
            _c.value,
          ),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}
