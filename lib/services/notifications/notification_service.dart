import 'package:english_drops_daily/data/datasources/lesson_local_datasource.dart';
import 'package:english_drops_daily/domain/models/lesson_model.dart';
import 'package:english_drops_daily/features/word_of_day/screens/word_of_day_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  factory NotificationService() => _instance;

  NotificationService._();

  static final NotificationService _instance = NotificationService._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _shouldOpenWordOfDay = false;

  static const String _channelId = 'daily_word_channel';
  static const String _channelName = 'Daily word reminders';
  static const String _channelDescription =
      'Daily reminders to study English Drops Daily.';
  static const String _notificationTitle = 'English Drops Daily';
  static const String _notificationBody =
      'Tu gota de ingles del dia te espera.';
  static const String _wordOfDayPayload = 'word_of_day';

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
    _openWordOfDay();
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

    final lesson = await _getWordOfDay();
    final content = lesson == null
        ? const _NotificationContent(
            title: _notificationTitle,
            body: _notificationBody,
          )
        : _buildLessonNotificationContent(lesson);

    await _notifications.show(
      id: 1,
      title: content.title,
      body: content.body,
      notificationDetails: _notificationDetails,
      payload: _wordOfDayPayload,
    );
  }

  Future<LessonModel?> _getWordOfDay() async {
    try {
      final lessons = await const LessonLocalDatasource().getLessons();
      return lessons.isEmpty ? null : lessons.first;
    } on Object {
      return null;
    }
  }

  _NotificationContent _buildLessonNotificationContent(LessonModel lesson) {
    return _NotificationContent(
      title: '${_capitalize(lesson.word)} - ${lesson.meaningEs}',
      body: lesson.shortNotificationText ?? _buildFallbackBody(lesson),
    );
  }

  String _buildFallbackBody(LessonModel lesson) {
    if (lesson.isVerb) {
      final verbType = lesson.verbType == null
          ? 'Verb'
          : _capitalize(lesson.verbType!);
      final forms = [
        lesson.baseForm ?? lesson.word,
        lesson.pastSimple,
        lesson.pastParticiple,
      ].whereType<String>().join(' / ');

      return '$verbType: $forms. Example: ${lesson.exampleEn}';
    }

    final usage = lesson.usage
        .replaceFirst('Se usa ', '')
        .replaceFirst('para ', 'para ');

    return 'Uso: $usage Example: ${lesson.exampleEn}';
  }

  String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }

    return value[0].toUpperCase() + value.substring(1);
  }

  Future<void> _handleLaunchFromNotification() async {
    final details = await _notifications.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      _openWordOfDay();
    }
  }

  void _handleNotificationTap(NotificationResponse response) {
    if (response.payload == _wordOfDayPayload) {
      _openWordOfDay();
    }
  }

  void _openWordOfDay() {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      _shouldOpenWordOfDay = true;
      return;
    }

    navigator.push(
      MaterialPageRoute<void>(builder: (_) => const WordOfDayScreen()),
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
