import 'package:english_drops_daily/core/theme/app_theme.dart';
import 'package:english_drops_daily/domain/models/app_settings_model.dart';
import 'package:english_drops_daily/domain/models/exercise_model.dart';
import 'package:english_drops_daily/domain/models/lesson_model.dart';
import 'package:english_drops_daily/domain/models/notification_settings_model.dart';
import 'package:english_drops_daily/features/exercises/widgets/exercise_card.dart';
import 'package:english_drops_daily/services/notifications/notification_service.dart';
import 'package:english_drops_daily/services/storage/app_settings_storage_service.dart';
import 'package:english_drops_daily/services/storage/favorites_storage_service.dart';
import 'package:english_drops_daily/services/storage/lesson_history_storage_service.dart';
import 'package:english_drops_daily/services/lesson_selection_service.dart';
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

  test('selects unseen lessons before repeating shown lessons', () async {
    const historyStorage = LessonHistoryStorageService();
    const selectionService = LessonSelectionService();
    const lessons = [
      LessonModel(
        id: 'lesson_001',
        word: 'actually',
        meaningEs: 'en realidad / de hecho',
        pronunciation: 'Ak-shu-a-li',
        exampleEn: 'Actually, I need help.',
        exampleEs: 'En realidad, necesito ayuda.',
        usage: 'Aclarar una idea.',
        grammar: 'Adverb.',
        level: 'A2',
        isPremium: false,
        category: 'common_adverbs',
        packId: 'free_basic_1000',
        partOfSpeech: 'adverb',
        isVerb: false,
        verbType: null,
        baseForm: null,
        pastSimple: null,
        pastParticiple: null,
        shortNotificationText: null,
        commonMistakes: [],
        dailyUse: [],
        exercises: [],
        links: [],
      ),
      LessonModel(
        id: 'lesson_002',
        word: 'usually',
        meaningEs: 'normalmente',
        pronunciation: 'Yu-zhu-a-li',
        exampleEn: 'I usually study.',
        exampleEs: 'Normalmente estudio.',
        usage: 'Hablar de habitos.',
        grammar: 'Adverb of frequency.',
        level: 'A1',
        isPremium: false,
        category: 'frequency_adverbs',
        packId: 'free_basic_1000',
        partOfSpeech: 'adverb',
        isVerb: false,
        verbType: null,
        baseForm: null,
        pastSimple: null,
        pastParticiple: null,
        shortNotificationText: null,
        commonMistakes: [],
        dailyUse: [],
        exercises: [],
        links: [],
      ),
    ];

    expect(await selectionService.getNextUnseenLesson(lessons), lessons.first);

    await historyStorage.markLessonAsShown('lesson_001');
    expect(await selectionService.getNextUnseenLesson(lessons), lessons.last);
    expect(
      await selectionService.getNextUnseenByLevel(lessons, 'A1'),
      lessons.last,
    );

    await historyStorage.markLessonAsShown('lesson_002');
    expect(await selectionService.getNextUnseenLesson(lessons), lessons.first);

    await historyStorage.resetShownLessons();
    expect(await historyStorage.getShownLessonIds(), isEmpty);
  });

  test('notification settings keep default quiet hours in storage json', () {
    final settings = NotificationSettingsModel.fromJson(const {
      'enabled': true,
      'frequencyType': 'daily',
      'notificationsPerDay': 3,
      'startHour': 8,
      'endHour': 20,
    });

    expect(settings.quietHoursEnabled, isTrue);
    expect(settings.quietStartHour, 22);
    expect(settings.quietEndHour, 7);

    final updated = settings.copyWith(
      quietHoursEnabled: false,
      quietStartHour: 21,
      quietEndHour: 6,
    );
    final json = updated.toJson();

    expect(json['quietHoursEnabled'], isFalse);
    expect(json['quietStartHour'], 21);
    expect(json['quietEndHour'], 6);
  });

  test('moves scheduled notifications outside quiet hours', () {
    final notificationService = NotificationService();
    final settings = NotificationSettingsModel.initial;
    final lateNight = DateTime(2026, 6, 19, 22, 30);
    final earlyMorning = DateTime(2026, 6, 19, 6, 30);
    final daytime = DateTime(2026, 6, 19, 8);

    expect(notificationService.isInsideQuietHours(lateNight, settings), isTrue);
    expect(
      notificationService.isInsideQuietHours(earlyMorning, settings),
      isTrue,
    );
    expect(notificationService.isInsideQuietHours(daytime, settings), isFalse);

    expect(
      notificationService.moveOutsideQuietHours(lateNight, settings),
      DateTime(2026, 6, 20, 7),
    );
    expect(
      notificationService.moveOutsideQuietHours(earlyMorning, settings),
      DateTime(2026, 6, 19, 7),
    );
    expect(
      notificationService.moveOutsideQuietHours(daytime, settings),
      daytime,
    );
  });

  testWidgets('exercise card shows clear answer feedback', (
    WidgetTester tester,
  ) async {
    const exercise = ExerciseModel(
      id: 'test_exercise',
      type: 'multiple_choice',
      question: 'Choose the correct answer',
      options: ['Correct answer', 'Wrong answer'],
      correctAnswer: 'Correct answer',
      explanation: 'This is the expected option.',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: ExerciseCard(exercise: exercise)),
      ),
    );

    await tester.tap(find.text('Correct answer'));
    await tester.pump();

    expect(find.text('Correcto'), findsOneWidget);
    expect(find.text('This is the expected option.'), findsOneWidget);
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

    await tester.scrollUntilVisible(
      find.text('Reiniciar favoritos y notas'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Reiniciar progreso'), findsOneWidget);
    expect(find.text('Reiniciar favoritos y notas'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Configurar notificaciones'),
      -250,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Configurar notificaciones'));
    await _pumpUntilFound(tester, find.text('Frecuencia de aprendizaje'));
    expect(find.text('Notificaciones'), findsWidgets);

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

    expect(find.text('Anterior'), findsWidgets);
    expect(find.text('Pasar'), findsWidgets);
    expect(find.text('Guardar'), findsWidgets);
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
