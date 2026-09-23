import 'package:flutter/widgets.dart';

/// Breakpoints for fully responsive layout (phone → tablet → desktop/web).
/// Usage: Responsive.isMobile(context), Responsive.maxWidth(context), etc.
abstract final class Responsive {
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;

  /// Max content width so web/desktop doesn't stretch edge-to-edge.
  static const double maxContentWidth = 1120;

  static bool isMobile(BuildContext c) =>
      MediaQuery.sizeOf(c).width < mobile;
  static bool isTablet(BuildContext c) {
    final w = MediaQuery.sizeOf(c).width;
    return w >= mobile && w < tablet;
  }

  static bool isDesktop(BuildContext c) =>
      MediaQuery.sizeOf(c).width >= tablet;

  /// 1 col on phones, 2 on large phone/tablet, 3-4 on desktop.
  static int gridColumns(BuildContext c, {int mobileCols = 1}) {
    final w = MediaQuery.sizeOf(c).width;
    if (w < 480) return mobileCols;
    if (w < tablet) return 2;
    if (w < desktop) return 3;
    return 4;
  }
}

/// Centers content with a max width — required for web/desktop screens.
class MaxWidth extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const MaxWidth({super.key, required this.child, this.maxWidth = Responsive.maxContentWidth});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
