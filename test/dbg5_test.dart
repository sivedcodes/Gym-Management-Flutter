import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:total_fit_gym/main.dart';

void main() {
  testWidgets('google login lands on profile setup', (t) async {
    t.view.physicalSize = const Size(375, 667);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(const ProviderScope(child: TotalFitGymApp()));
    await t.pump(const Duration(milliseconds: 1500));
    await t.pumpAndSettle();
    await t.tap(find.text('Continue with Google'));
    await t.pumpAndSettle();
    final texts = t.allWidgets.whereType<Text>().map((w) => w.data).where((s) => s != null && s.isNotEmpty).take(25).toList();
    debugPrint('AFTER LOGIN: $texts');
  });
}
