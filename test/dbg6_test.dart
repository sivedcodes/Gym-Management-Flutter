import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:total_fit_gym/main.dart';

void main() {
  testWidgets('dbg nav overflow', (t) async {
    t.view.physicalSize = const Size(375, 667);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    FlutterError.onError = (d) {
      final s = d.stack.toString().split('\n')
          .where((l) => l.contains('total_fit_gym'))
          .take(6).join('\n');
      debugPrint('STACK:\n$s');
    };
    await t.pumpWidget(const ProviderScope(child: TotalFitGymApp()));
    await t.pumpAndSettle();
    await t.scrollUntilVisible(find.text('Continue with Google'), 300,
        scrollable: find.byType(Scrollable).first);
    await t.tap(find.text('Continue with Google'));
    await t.pump();
  });
}
