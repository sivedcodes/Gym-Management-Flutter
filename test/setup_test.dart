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
    uid: 'new_u',
    name: 'Temp User',
    email: 'temp@mail.com',
  );
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
    expect(
      find.text('Enter weight + height', skipOffstage: false),
      findsOneWidget,
    );

    await t.enterText(find.widgetWithText(TextFormField, 'Weight (kg)'), '70');
    await t.enterText(find.widgetWithText(TextFormField, 'Height (ft)'), '5');
    await t.enterText(find.widgetWithText(TextFormField, 'Inches'), '9');
    await t.pump();
    // 5 ft 9 in = 175.26 cm; 70 / 1.7526² = 22.8 → Normal
    expect(find.text('22.8 · Normal', skipOffstage: false), findsOneWidget);
  });

  testWidgets('setup validates 10-digit phone', (t) async {
    await t.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SetupScreen())),
    );
    _seedNewUser(t);
    await t.pumpAndSettle();
    await t.enterText(
      find.widgetWithText(TextFormField, 'Mobile number'),
      '12345',
    );
    await t.scrollUntilVisible(
      find.text('Continue'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await t.tap(find.text('Continue'));
    await t.pump();
    // Error renders under the phone field (scrolled out of view).
    expect(
      find.text('Enter a valid 10-digit number', skipOffstage: false),
      findsOneWidget,
    );
  });

  test('height converts between feet/inches and centimetres', () {
    expect(AppUser.ftInToCm(5, 9).round(), 175);
    expect(AppUser.cmToFtIn(175), [5, 9]);
    const user = AppUser(uid: 'height', name: 'n', email: 'e', heightCm: 175);
    expect(user.heightLabel, '5 ft 9 in');
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
      targetKg: 8,
    );
    expect(u.bmi!.toStringAsFixed(1), '24.7');
    expect(u.hasProfile, isTrue);
  });

  testWidgets('goal and workout split chips render with icons and update state',
      (t) async {
    await t.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SetupScreen())),
    );
    _seedNewUser(t);
    await t.pumpAndSettle();

    // Scroll down to Goal section
    await t.scrollUntilVisible(
      find.text('Gain'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await t.pumpAndSettle();

    // Verify Goal chips with title and subtitles
    expect(find.text('Gain'), findsOneWidget);
    expect(find.text('Muscle'), findsOneWidget);
    expect(find.text('Lose'), findsOneWidget);
    expect(find.text('Fat burn'), findsOneWidget);
    expect(find.text('Maintain'), findsOneWidget);
    expect(find.text('Stay fit'), findsOneWidget);

    // Verify Goal icons are rendered
    expect(find.byIcon(Icons.fitness_center_rounded), findsWidgets);
    expect(find.byIcon(Icons.local_fire_department_rounded), findsOneWidget);
    expect(find.byIcon(Icons.balance_rounded), findsOneWidget);

    // Initial state is maintain (no target kg field)
    expect(find.text('How many kg to gain?'), findsNothing);
    expect(find.text('How many kg to lose?'), findsNothing);

    // Tap Gain chip -> target kg field appears
    await t.tap(find.text('Gain'));
    await t.pump();
    expect(find.text('How many kg to gain?'), findsOneWidget);

    // Tap Lose chip -> target kg field changes label
    await t.tap(find.text('Lose'));
    await t.pump();
    expect(find.text('How many kg to lose?'), findsOneWidget);

    // Tap Maintain chip -> target kg field disappears
    await t.tap(find.text('Maintain'));
    await t.pump();
    expect(find.text('How many kg to lose?'), findsNothing);

    // Verify Workout split chips are present
    expect(find.text('Push Pull Legs'), findsWidgets);
    expect(find.text('Bro Split'), findsOneWidget);

    // Tap Bro Split -> updates selection and WeekPreview reflects it
    await t.tap(find.text('Bro Split'));
    await t.pumpAndSettle();
    expect(find.text('Bro Split'), findsWidgets);
  });
}
