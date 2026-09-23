import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:total_fit_gym/core/auth/session.dart';
import 'package:total_fit_gym/core/routing/app_router.dart';
import 'package:total_fit_gym/main.dart';

/// Phase-15 responsive validation: pumps the REAL app at multiple
/// logical widths and walks owner + member flows. Any RenderFlex
/// overflow / clipping throws during pump and fails the test.
Future<void> _pumpApp(WidgetTester t, Size size) async {
  t.view.physicalSize = size;
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(const ProviderScope(child: TotalFitGymApp()));
  await t.pumpAndSettle();
}

ProviderContainer _container(WidgetTester t) =>
    ProviderScope.containerOf(t.element(find.byType(TotalFitGymApp)));

Future<void> _loginAs(
    WidgetTester t, String uid, AuthStatus status) async {
  final c = _container(t);
  c.read(currentUidProvider.notifier).state = uid;
  c.read(authStatusProvider.notifier).state = status;
  await t.pumpAndSettle();
}

Future<void> _tapTab(WidgetTester t, String label) async {
  await t.tap(find.text(label).first);
  await t.pumpAndSettle();
}

Future<void> _ownerFlow(WidgetTester t) async {
  await _loginAs(t, 'owner_1', AuthStatus.owner);
  expect(find.text('Dashboard'), findsWidgets);
  for (final tab in ['Pending', 'Members', 'Plans', 'Programs']) {
    await _tapTab(t, tab);
  }
  // Plans manager + services manager open from tabs.
  await _tapTab(t, 'Plans');
  await t.tap(find.text('Open plan manager').first);
  await t.pumpAndSettle();
  expect(find.text('Manage plans'), findsOneWidget);
  await t.tap(find.byType(BackButton));
  await t.pumpAndSettle();
}

Future<void> _memberFlow(WidgetTester t) async {
  await _loginAs(t, 'u_active', AuthStatus.member);
  expect(find.text('Home'), findsWidgets);
  // Rush is now the topmost section.
  expect(find.text('Gym rush hours'), findsOneWidget);
  await _tapTab(t, 'Programs');
  expect(find.text('Training & diet plans'), findsOneWidget);
  await _tapTab(t, 'Music');
  expect(find.text('Pump it up'), findsOneWidget);
  await _tapTab(t, 'Profile');
  expect(find.text('History'), findsOneWidget);
  await _tapTab(t, 'Home');
  // Renew CTA sits below the fold (lazy slivers) — scroll to it.
  // NOTE: target the Home CustomScrollView explicitly; IndexedStack
  // keeps offstage tabs (with their own Scrollables) in the tree.
  await t.scrollUntilVisible(
    find.text('Renew / switch'),
    300,
    scrollable: find
        .descendant(
          of: find.byType(CustomScrollView).first,
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await t.pumpAndSettle();
  await t.tap(find.text('Renew / switch'));
  await t.pumpAndSettle();
  expect(find.text('Choose your plan'), findsOneWidget);
  await t.tap(find.byType(BackButton));
  await t.pumpAndSettle();
}

void main() {
  const sizes = {
    'small-320': Size(320, 568),
    'base-375': Size(375, 667),
    'large-430': Size(430, 932),
    'tablet-768': Size(768, 1024),
  };
  for (final entry in sizes.entries) {
    testWidgets('no overflow at ${entry.key} (owner + member)',
        (t) async {
      await _pumpApp(t, entry.value);
      // Login screen itself.
      expect(find.text('TOTAL FIT GYM'), findsOneWidget);
      await _ownerFlow(t);
      await _memberFlow(t);
    });
  }
}
