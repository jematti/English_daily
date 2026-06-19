import 'package:english_drops_daily/core/theme/app_theme.dart';
import 'package:english_drops_daily/domain/models/app_settings_model.dart';
import 'package:english_drops_daily/domain/models/exercise_model.dart';
import 'package:english_drops_daily/domain/models/lesson_model.dart';
import 'package:english_drops_daily/domain/models/notification_settings_model.dart';
import 'package:english_drops_daily/domain/models/user_access_model.dart';
import 'package:english_drops_daily/features/exercises/widgets/exercise_card.dart';
import 'package:english_drops_daily/features/word_of_day/widgets/animated_swipe_card.dart';
import 'package:english_drops_daily/services/access/access_service.dart';
import 'package:english_drops_daily/services/content/content_pack_service.dart';
import 'package:english_drops_daily/services/notifications/notification_service.dart';
import 'package:english_drops_daily/services/storage/app_settings_storage_service.dart';
import 'package:english_drops_daily/services/storage/favorites_storage_service.dart';
import 'package:english_drops_daily/services/storage/lesson_history_storage_service.dart';
import 'package:english_drops_daily/services/storage/user_access_storage_service.dart';
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

  test('free access only allows free basic A1 and A2 lessons', () async {
    const accessService = AccessService();
    const accessStorage = UserAccessStorageService();
    const freeLesson = LessonModel(
      id: 'lesson_free',
      word: 'usually',
      meaningEs: 'normalmente',
      pronunciation: 'Yu-zhu-a-li',
      exampleEn: 'I usually study.',
      exampleEs: 'Normalmente estudio.',
      usage: 'Hablar de habitos.',
      grammar: 'Adverb.',
      level: 'A2',
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
    );
    const lockedLevelLesson = LessonModel(
      id: 'lesson_b1',
      word: 'advice',
      meaningEs: 'consejo',
      pronunciation: 'Ad-vais',
      exampleEn: 'Can you give me advice?',
      exampleEs: 'Puedes darme un consejo?',
      usage: 'Pedir sugerencias.',
      grammar: 'Uncountable noun.',
      level: 'B1',
      isPremium: false,
      category: 'common_nouns',
      packId: 'free_basic_1000',
      partOfSpeech: 'noun',
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
    );
    const premiumLesson = LessonModel(
      id: 'lesson_premium',
      word: 'break down',
      meaningEs: 'descomponer / averiarse',
      pronunciation: 'Breik daun',
      exampleEn: 'The car broke down.',
      exampleEs: 'El auto se averio.',
      usage: 'Phrasal verb.',
      grammar: 'Irregular phrasal verb.',
      level: 'B2',
      isPremium: true,
      category: 'phrasal_verbs',
      packId: 'phrasal_verbs',
      partOfSpeech: 'verb',
      isVerb: true,
      verbType: 'irregular',
      baseForm: 'break down',
      pastSimple: 'broke down',
      pastParticiple: 'broken down',
      shortNotificationText: null,
      commonMistakes: [],
      dailyUse: [],
      exercises: [],
      links: [],
    );

    expect(await accessService.canAccessLesson(freeLesson), isTrue);
    expect(await accessService.canAccessLesson(lockedLevelLesson), isFalse);
    expect(await accessService.canAccessLesson(premiumLesson), isFalse);
    expect(await accessService.canAccessPack('premium_5000'), isFalse);
    expect(await accessService.canAccessLevel('B1'), isFalse);

    final accessibleLessons = await accessService.filterAccessibleLessons([
      freeLesson,
      lockedLevelLesson,
      premiumLesson,
    ]);
    expect(accessibleLessons, [freeLesson]);

    await accessStorage.saveUserAccess(
      const UserAccessModel(
        isPremium: true,
        unlockedPackIds: [],
        unlockedLevels: [],
      ),
    );

    expect(await accessService.canAccessLesson(premiumLesson), isTrue);
    expect(await accessService.canAccessPack('premium_10000'), isTrue);
    expect(await accessService.canAccessLevel('C1'), isTrue);
  });

  test(
    'content packs load free lessons and premium preview from assets',
    () async {
      const contentPackService = ContentPackService();

      final packs = await contentPackService.getAvailablePacks();
      final freeLessons = await contentPackService.loadFreeBasicLessons();
      final previewLessons = await contentPackService.loadLessonsByPack(
        'premium_preview',
      );
      final accessibleLessons = await contentPackService
          .loadAllAccessibleLessons();

      expect(packs.length, 3);
      expect(freeLessons.length, 15);
      expect(previewLessons.length, 3);
      expect(previewLessons.every((lesson) => lesson.isPremium), isTrue);
      expect(accessibleLessons.length, 15);
      expect(
        accessibleLessons.every((lesson) => lesson.packId == 'free_basic_1000'),
        isTrue,
      );
      expect(
        accessibleLessons.every(
          (lesson) => lesson.level == 'A1' || lesson.level == 'A2',
        ),
        isTrue,
      );
    },
  );

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

  testWidgets('starts in microlesson home and keeps secondary flows', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await _pumpUntilFound(tester, find.text('Aprende ahora'));

    expect(find.text('actually'), findsWidgets);
    expect(find.text('en realidad / de hecho'), findsWidgets);
    expect(find.text('Bonus diario'), findsOneWidget);
    expect(find.text('Anterior'), findsWidgets);
    expect(find.text('Pasar'), findsWidgets);
    expect(find.text('Guardar'), findsWidgets);
    expect(find.text('Relacionada'), findsWidgets);

    await tester.scrollUntilVisible(
      find.text('Ajustes'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ajustes'));
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

    await _pumpUntilFound(tester, find.text('Aprende ahora'));
    await tester.scrollUntilVisible(
      find.text('actually').last,
      -500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(AnimatedSwipeCard), const Offset(-140, 0));
    await tester.pumpAndSettle();
    expect(find.text('usually'), findsOneWidget);

    await tester.drag(find.byType(AnimatedSwipeCard), const Offset(0, 140));
    await tester.pumpAndSettle();
    expect(find.text('actually'), findsWidgets);

    await tester.drag(find.byType(AnimatedSwipeCard), const Offset(0, -140));
    await tester.pumpAndSettle();
    expect(find.text('usually'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Guardar').first,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Guardar').first);
    await tester.pumpAndSettle();
    expect(find.text('Guardar'), findsWidgets);
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
