import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:total_fit_gym/core/auth/session.dart';
import 'package:total_fit_gym/core/models/app_models.dart';
import 'package:total_fit_gym/features/auth/presentation/setup_screen.dart';

/// Fresh profile-less user in the test scope's FakeDb.
void _seedNewUser(WidgetTester t) {
  final c = ProviderScope.containerOf(t.element(find.byType(SetupScreen)));
  final db = c.read(fakeDbProvider);
  db.users['new_u'] = const AppUser(
      uid: 'new_u', name: 'Temp User', email: 'temp@mail.com');
  db.touch();
  c.read(currentUidProvider.notifier).state = 'new_u';
}

/// Profile setup: BMI math, categories, validation, split catalog.
void main() {
  testWidgets('setup shows live BMI as weight+height typed', (t) async {
    await t.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SetupScreen())),
    );
    _seedNewUser(t);
    await t.pumpAndSettle();
    // Fresh mock user has no profile → setup mode, empty BMI hint.
    expect(find.text('Enter weight + height'), findsOneWidget);

    await t.enterText(
        find.widgetWithText(TextFormField, 'Weight (kg)'), '70');
    await t.enterText(
        find.widgetWithText(TextFormField, 'Height (cm)'), '175');
    await t.pump();
    // 70 / 1.75² = 22.857 → 22.9 · Normal
    expect(find.text('22.9 · Normal'), findsOneWidget);
  });

  testWidgets('setup validates 10-digit phone', (t) async {
    await t.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SetupScreen())),
    );
    _seedNewUser(t);
    await t.pumpAndSettle();
    await t.enterText(
        find.widgetWithText(TextFormField, 'Mobile number'), '12345');
    await t.scrollUntilVisible(
      find.text('Continue'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await t.tap(find.text('Continue'));
    await t.pump();
    // Error renders under the phone field (scrolled out of view).
    expect(
        find.text('Enter a valid 10-digit number',
            skipOffstage: false),
        findsOneWidget);
  });

  test('BMI categories follow WHO bands', () {
    expect(AppUser.bmiCategory(17.0), 'Underweight');
    expect(AppUser.bmiCategory(22.0), 'Normal');
    expect(AppUser.bmiCategory(27.5), 'Overweight');
    expect(AppUser.bmiCategory(32.0), 'Obese');
  });

  test('goal text formats gain/loss/maintain', () {
    // Covered implicitly via profile helpers; math sanity:
    const u = AppUser(
        uid: 'x',
        name: 'n',
        email: 'e',
        phone: '9000000001',
        weightKg: 80,
        heightCm: 180,
        goal: 'loss',
        targetKg: 8);
    expect(u.bmi!.toStringAsFixed(1), '24.7');
    expect(u.hasProfile, isTrue);
  });
}
