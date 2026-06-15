import 'package:english_drops_daily/domain/models/app_settings_model.dart';
import 'package:english_drops_daily/services/storage/app_settings_storage_service.dart';
import 'package:english_drops_daily/services/storage/favorites_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:english_drops_daily/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppSettingsStorageService.settingsNotifier.value = AppSettingsModel.initial;
  });

  test('stores app settings and clears local user data', () async {
    const settingsStorage = AppSettingsStorageService();
    const favoritesStorage = FavoritesStorageService();
    const settings = AppSettingsModel(
      pronunciationSpeed: PronunciationSpeed.fast,
      themePreference: AppThemePreference.dark,
      showSwipeHints: false,
    );

    await settingsStorage.saveSettings(settings);
    await favoritesStorage.addFavorite('lesson_001');
    await favoritesStorage.saveNote('lesson_001', 'Mi nota');

    final storedSettings = await settingsStorage.loadSettings();
    expect(storedSettings.pronunciationSpeed, PronunciationSpeed.fast);
    expect(storedSettings.themePreference, AppThemePreference.dark);
    expect(storedSettings.showSwipeHints, isFalse);

    await favoritesStorage.clearAll();
    expect(await favoritesStorage.getFavoriteLessonIds(), isEmpty);
    expect(await favoritesStorage.getNotes(), isEmpty);
  });

  testWidgets('opens settings and navigates the offline lessons', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await _pumpUntilFound(tester, find.text('Configuracion'));

    await tester.scrollUntilVisible(
      find.text('Configuracion'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Configuracion'));
    await _pumpUntilFound(tester, find.text('Velocidad de pronunciacion'));

    expect(find.text('Tema visual'), findsOneWidget);
    expect(find.text('Mostrar ayuda de gestos'), findsOneWidget);
    expect(find.text('Reiniciar progreso'), findsOneWidget);
    expect(find.text('Reiniciar favoritos y notas'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Configurar notificaciones'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Configurar notificaciones'));
    await _pumpUntilFound(tester, find.text('Frecuencia de aprendizaje'));
    expect(find.text('Notificaciones'), findsOneWidget);

    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Ver microleccion'));
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
  for (var attempt = 0; attempt < 100 && finder.evaluate().isEmpty; attempt++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
  }
}
