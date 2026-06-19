// ignore_for_file: depend_on_referenced_packages

import 'package:english_drops_daily/domain/models/lesson_model.dart';
import 'package:english_drops_daily/domain/models/notification_settings_model.dart';
import 'package:english_drops_daily/features/word_of_day/screens/word_of_day_screen.dart';
import 'package:english_drops_daily/services/storage/lesson_history_storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

class NotificationService {
  factory NotificationService() => _instance;

  NotificationService._();

  static final NotificationService _instance = NotificationService._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final LessonHistoryStorageService _lessonHistoryStorage =
      const LessonHistoryStorageService();

  bool _shouldOpenWordOfDay = false;
  String? _pendingLessonId;
  bool _timeZonesInitialized = false;

  static const String _channelId = 'daily_word_channel';
  static const String _channelName = 'Daily word reminders';
  static const String _channelDescription =
      'Daily reminders to study English Drops Daily.';
  static const String _notificationTitle = 'English Drops Daily';
  static const String _notificationBody =
      'Tu gota de ingles del dia te espera.';
  static const String _wordOfDayPayload = 'word_of_day';
  static const int _scheduledNotificationStartId = 1000;

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
      );

  static const NotificationDetails _notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  Future<void> init() async {
    if (!_isAndroid) {
      return;
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );
    await _createAndroidNotificationChannel();
    await _handleLaunchFromNotification();
  }

  void openPendingNotificationRoute() {
    if (!_shouldOpenWordOfDay) {
      return;
    }

    _shouldOpenWordOfDay = false;
    _openWordOfDay(_pendingLessonId);
    _pendingLessonId = null;
  }

  Future<bool> requestPermissions() async {
    if (!_isAndroid) {
      return false;
    }

    final androidImplementation = _androidImplementation;
    final granted = await androidImplementation
        ?.requestNotificationsPermission();

    return granted ?? false;
  }

  Future<void> showTestNotification() async {
    if (!_isAndroid) {
      return;
    }

    await _notifications.show(
      id: 1,
      title: _notificationTitle,
      body: _notificationBody,
      notificationDetails: _notificationDetails,
      payload: _wordOfDayPayload,
    );
  }

  Future<void> showLessonNotification(LessonModel lesson) async {
    if (!_isAndroid) {
      return;
    }

    final content = _buildLessonNotificationContent(lesson);

    await _notifications.show(
      id: 1,
      title: content.title,
      body: content.body,
      notificationDetails: _notificationDetails,
      payload: _payloadForLesson(lesson),
    );
    await _lessonHistoryStorage.markLessonAsShown(lesson.id);
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAllPendingNotifications();
      await _notifications.cancelAll();
    } on Object {
      return;
    }
  }

  Future<void> scheduleNotificationsBySettings(
    NotificationSettingsModel settings,
    List<LessonModel> lessons,
  ) async {
    if (!_isAndroid || !settings.enabled || lessons.isEmpty) {
      return;
    }

    await scheduleMultipleDailyLessonNotifications(settings, lessons);
  }

  Future<void> scheduleMultipleDailyLessonNotifications(
    NotificationSettingsModel settings,
    List<LessonModel> lessons,
  ) async {
    if (!_isAndroid || lessons.isEmpty) {
      return;
    }

    _initializeTimeZones();

    final hours = _hoursForSettings(settings);
    final notificationLessons = await _selectLessonsForNotifications(
      lessons,
      hours.length,
    );

    for (var index = 0; index < hours.length; index++) {
      final lesson = notificationLessons[index % notificationLessons.length];
      final content = _buildLessonNotificationContent(lesson);

      await _notifications.zonedSchedule(
        id: _scheduledNotificationStartId + index,
        title: content.title,
        body: content.body,
        scheduledDate: _nextAllowedTimeAtHour(hours[index], settings),
        notificationDetails: _notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: _payloadForLesson(lesson),
      );
    }
  }

  bool isInsideQuietHours(DateTime date, NotificationSettingsModel settings) {
    if (!settings.quietHoursEnabled) {
      return false;
    }

    final startHour = settings.quietStartHour;
    final endHour = settings.quietEndHour;

    if (startHour == endHour) {
      return false;
    }

    if (startHour < endHour) {
      return date.hour >= startHour && date.hour < endHour;
    }

    return date.hour >= startHour || date.hour < endHour;
  }

  DateTime moveOutsideQuietHours(
    DateTime date,
    NotificationSettingsModel settings,
  ) {
    if (!isInsideQuietHours(date, settings)) {
      return date;
    }

    final endHour = settings.quietEndHour;
    final startHour = settings.quietStartHour;
    var allowedDate = DateTime(date.year, date.month, date.day, endHour);

    if (startHour > endHour && date.hour >= startHour) {
      allowedDate = allowedDate.add(const Duration(days: 1));
    }

    return allowedDate;
  }

  Future<List<LessonModel>> _selectLessonsForNotifications(
    List<LessonModel> lessons,
    int count,
  ) async {
    final freeLessons = lessons.where((lesson) => !lesson.isPremium).toList();
    final availableLessons = freeLessons.isNotEmpty ? freeLessons : lessons;
    final shownLessonIds = await _lessonHistoryStorage.getShownLessonIds();
    final unseenLessons = availableLessons.where((lesson) {
      return !shownLessonIds.contains(lesson.id);
    }).toList();

    if (unseenLessons.isEmpty) {
      return availableLessons;
    }

    final selectedLessons = unseenLessons.take(count).toList();
    if (selectedLessons.length == count) {
      return selectedLessons;
    }

    final selectedIds = selectedLessons.map((lesson) => lesson.id).toSet();
    selectedLessons.addAll(
      availableLessons.where((lesson) => !selectedIds.contains(lesson.id)),
    );

    return selectedLessons;
  }

  _NotificationContent _buildLessonNotificationContent(LessonModel lesson) {
    return _NotificationContent(
      title: '${lesson.word} - ${lesson.meaningEs}',
      body: lesson.shortNotificationText ?? _buildFallbackBody(lesson),
    );
  }

  String _buildFallbackBody(LessonModel lesson) {
    return 'Example: ${lesson.exampleEn}';
  }

  List<int> _hoursForSettings(NotificationSettingsModel settings) {
    if (settings.frequencyType == 'hourly') {
      return [
        for (var hour = settings.startHour; hour <= settings.endHour; hour++)
          hour,
      ];
    }

    return switch (settings.notificationsPerDay) {
      3 => const [8, 14, 20],
      5 => const [8, 11, 14, 17, 20],
      10 => const [8, 9, 10, 11, 12, 14, 15, 16, 18, 20],
      _ => const [8],
    };
  }

  timezone.TZDateTime _nextTimeAtHour(int hour) {
    final now = timezone.TZDateTime.now(timezone.local);
    var scheduledDate = timezone.TZDateTime(
      timezone.local,
      now.year,
      now.month,
      now.day,
      hour,
    );

    if (!scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  timezone.TZDateTime _nextAllowedTimeAtHour(
    int hour,
    NotificationSettingsModel settings,
  ) {
    final scheduledDate = _nextTimeAtHour(hour);
    final allowedDate = moveOutsideQuietHours(scheduledDate, settings);

    return timezone.TZDateTime.from(allowedDate, timezone.local);
  }

  void _initializeTimeZones() {
    if (_timeZonesInitialized) {
      return;
    }

    timezone_data.initializeTimeZones();
    _timeZonesInitialized = true;
  }

  String _payloadForLesson(LessonModel lesson) {
    return '$_wordOfDayPayload:${lesson.id}';
  }

  String? _lessonIdFromPayload(String? payload) {
    if (payload == null) {
      return null;
    }

    if (!payload.startsWith(_wordOfDayPayload)) {
      return null;
    }

    final parts = payload.split(':');
    return parts.length > 1 ? parts[1] : null;
  }

  Future<void> _handleLaunchFromNotification() async {
    final details = await _notifications.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      _openWordOfDay(
        _lessonIdFromPayload(details?.notificationResponse?.payload),
      );
    }
  }

  void _handleNotificationTap(NotificationResponse response) {
    final lessonId = _lessonIdFromPayload(response.payload);
    if (response.payload?.startsWith(_wordOfDayPayload) ?? false) {
      _openWordOfDay(lessonId);
    }
  }

  void _openWordOfDay(String? lessonId) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      _shouldOpenWordOfDay = true;
      _pendingLessonId = lessonId;
      return;
    }

    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => WordOfDayScreen(initialLessonId: lessonId),
      ),
    );
  }

  Future<void> _createAndroidNotificationChannel() async {
    await _androidImplementation?.createNotificationChannel(_androidChannel);
  }

  AndroidFlutterLocalNotificationsPlugin? get _androidImplementation =>
      _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
}

class _NotificationContent {
  const _NotificationContent({required this.title, required this.body});

  final String title;
  final String body;
}
