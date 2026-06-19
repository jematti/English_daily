import 'dart:convert';

import 'package:english_drops_daily/domain/models/notification_settings_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsStorageService {
  const SettingsStorageService();

  static const String _notificationSettingsKey = 'notification_settings';

  Future<NotificationSettingsModel> getNotificationSettings() async {
    final preferences = await SharedPreferences.getInstance();
    final rawSettings = preferences.getString(_notificationSettingsKey);

    if (rawSettings == null) {
      return NotificationSettingsModel.initial;
    }

    return _decodeNotificationSettings(rawSettings);
  }

  NotificationSettingsModel _decodeNotificationSettings(String rawSettings) {
    try {
      final json = jsonDecode(rawSettings) as Map<String, dynamic>;
      return NotificationSettingsModel.fromJson(json);
    } on Object {
      return NotificationSettingsModel.initial;
    }
  }

  Future<void> saveNotificationSettings(
    NotificationSettingsModel settings,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _notificationSettingsKey,
      jsonEncode(settings.toJson()),
    );
  }
}
