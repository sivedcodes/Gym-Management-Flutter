import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:total_fit_gym/main.dart';

void main() {
  testWidgets('Total Fit Gym boots to splash/login', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: TotalFitGymApp()));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(TotalFitGymApp), findsOneWidget);
    // Let Splash timer finish + router redirect settle.
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();
    expect(find.byType(TotalFitGymApp), findsOneWidget);
  });
}
