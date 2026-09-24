import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:total_fit_gym/core/auth/session.dart';
import 'package:total_fit_gym/core/data/fake_db.dart';
import 'package:total_fit_gym/core/models/app_models.dart';
import 'package:total_fit_gym/features/intro/presentation/intro_screen.dart';

void main() {
  testWidgets('IntroScreen renders gym info and navigates unauthenticated',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: IntroScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify brand hero and headline
    expect(find.text('Total Fit Gym'), findsWidgets);
    expect(find.text('Elevate Your Strength & Athletic Potential'),
        findsOneWidget);
    expect(find.text('4.9 Rated · 500+ Active Athletes'), findsOneWidget);

    // Verify unauthenticated user sees Continue to Login button
    expect(find.text('Continue to Login'), findsOneWidget);

    // Scroll to Gym Timings & Shifts section
    await tester.scrollUntilVisible(
      find.text('Gym Timings & Shifts'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    // Verify shifts & timings
    expect(find.text('Gym Timings & Shifts'), findsOneWidget);
    expect(find.text('Morning'), findsOneWidget);
    expect(find.text('Evening'), findsOneWidget);
    expect(find.text('06:00 AM – 11:30 AM'), findsOneWidget);
    expect(find.text('05:00 PM – 10:30 PM'), findsOneWidget);

    // Scroll to contact & location
    await tester.scrollUntilVisible(
      find.text('9876543210'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('9876543210'), findsOneWidget);
    expect(
      find.text(
          'Plot 42, Sector 18, Commercial Belt, Near Metro Station, New Delhi'),
      findsOneWidget,
    );
  });

  testWidgets('Owner can open edit sheet and update gym info', (tester) async {
    final container = ProviderContainer();
    final db = container.read(fakeDbProvider);
    container.read(currentUidProvider.notifier).state = 'owner_1';

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: IntroScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Owner sees Edit info button in AppBar
    expect(find.text('Edit info'), findsOneWidget);

    // Tap Edit info to open bottom sheet
    await tester.tap(find.text('Edit info'));
    await tester.pumpAndSettle();

    expect(find.text('Manage Gym Info'), findsOneWidget);

    // Edit phone number
    final phoneFinder = find.widgetWithText(TextFormField, 'Phone Number');
    expect(phoneFinder, findsOneWidget);
    await tester.enterText(phoneFinder, '9999888877');

    // Scroll inside bottom sheet to Save Changes button
    await tester.scrollUntilVisible(
      find.text('Save Changes'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();

    // Tap Save Changes
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    // Verify updated phone in db
    expect(db.gymInfo.phone, '9999888877');
  });
}
