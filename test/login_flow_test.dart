import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:total_fit_gym/main.dart';

/// Full Google-login flow: splash → login → setup profile screen
/// (name, phone, weight, height, goal, BMI, splits). Guards the
/// exact complaint "details not asked after login".
void main() {
  testWidgets('google login lands on profile setup', (t) async {
    t.view.physicalSize = const Size(375, 667);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(const ProviderScope(child: TotalFitGymApp()));
    await t.pumpAndSettle();
    expect(find.text('TOTAL FIT GYM'), findsOneWidget);
    await t.scrollUntilVisible(
      find.text('Continue with Google'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await t.tap(find.text('Continue with Google'));
    await t.pumpAndSettle();
    // Setup screen: identity, body stats, goal, BMI, splits.
    expect(find.text('Setup profile'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Full name'),
        findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Mobile number'),
        findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Weight (kg)'),
        findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Height (cm)'),
        findsOneWidget);
    expect(find.text('Your BMI'), findsOneWidget);
    // Lower sections sit below the fold — scroll, then verify.
    Future<void> scrollTo(String s) => t.scrollUntilVisible(
          find.text(s),
          300,
          scrollable: find.byType(Scrollable).first,
        );
    await scrollTo('Goal');
    expect(find.text('Goal'), findsOneWidget);
    await scrollTo('Workout split');
    expect(find.text('Workout split'), findsOneWidget);
    await scrollTo('Continue');
    expect(find.text('Continue'), findsOneWidget);
  });
}
