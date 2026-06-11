import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'daily_word_channel';
  static const String _channelName = 'Daily word reminders';
  static const String _channelDescription =
      'Daily reminders to study English Drops Daily.';
  static const String _notificationTitle = 'English Drops Daily';
  static const String _notificationBody =
      'Tu gota de ingles del dia te espera.';

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
    if (kIsWeb) {
      return;
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(settings: initializationSettings);
    await _requestAndroidNotificationPermission();
  }

  Future<void> showTestNotification() async {
    await _notifications.show(
      id: 1,
      title: _notificationTitle,
      body: _notificationBody,
      notificationDetails: _notificationDetails,
    );
  }

  Future<void> scheduleDailyReminder() async {
    await _notifications.periodicallyShow(
      id: 2,
      title: _notificationTitle,
      body: _notificationBody,
      repeatInterval: RepeatInterval.daily,
      notificationDetails: _notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> _requestAndroidNotificationPermission() async {
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidImplementation?.requestNotificationsPermission();
  }
}
