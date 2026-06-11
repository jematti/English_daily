import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  factory NotificationService() => _instance;

  NotificationService._();

  static final NotificationService _instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'daily_word_channel';
  static const String _channelName = 'Daily word reminders';
  static const String _channelDescription =
      'Daily reminders to study English Drops Daily.';
  static const String _notificationTitle = 'English Drops Daily';
  static const String _notificationBody =
      'Tu gota de ingles del dia te espera.';

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

    await _notifications.initialize(settings: initializationSettings);
    await _createAndroidNotificationChannel();
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
