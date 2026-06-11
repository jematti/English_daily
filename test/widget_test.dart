import 'package:flutter_test/flutter_test.dart';

import 'package:english_drops_daily/main.dart';

void main() {
  testWidgets('shows the first offline lesson', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('actually'), findsOneWidget);
    expect(find.text('en realidad / de hecho'), findsOneWidget);
  });
}
