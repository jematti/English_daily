import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:english_drops_daily/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows and navigates the offline lessons', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('actually'), findsOneWidget);
    expect(find.text('en realidad / de hecho'), findsOneWidget);

    await tester.tap(find.text('Ver microleccion'));
    await _pumpUntilFound(tester, find.text('Anterior'));

    expect(find.text('Anterior'), findsOneWidget);
    expect(find.text('Pasar'), findsOneWidget);
    expect(find.text('Guardar'), findsOneWidget);
    expect(find.text('Relacionada'), findsWidgets);

    await tester.drag(find.text('actually').last, const Offset(-120, 0));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('usually'), findsOneWidget);

    await tester.drag(find.text('usually'), const Offset(0, 120));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('actually'), findsWidgets);

    await tester.drag(find.text('actually').last, const Offset(0, -120));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('usually'), findsOneWidget);

    await tester.drag(find.text('usually'), const Offset(120, 0));
    await tester.pump(const Duration(milliseconds: 300));

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getStringList('favorite_lesson_ids'), ['lesson_002']);
    expect(find.text('Guardado en favoritos'), findsOneWidget);
  });
}

Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 20 && finder.evaluate().isEmpty; attempt++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
  }
}
