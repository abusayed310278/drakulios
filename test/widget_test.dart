import 'package:flutter_test/flutter_test.dart';

import 'package:darkolious/main.dart';

void main() {
  testWidgets('Splash navigates to onboarding screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.textContaining('Welcome To'), findsNothing);

    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pumpAndSettle();

    expect(find.textContaining('Welcome To'), findsOneWidget);
    expect(find.textContaining('Get Started'), findsOneWidget);
  });
}
