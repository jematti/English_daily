import 'dart:convert';

import 'package:english_drops_daily/domain/models/app_settings_model.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsStorageService {
  const AppSettingsStorageService();

  static const String _appSettingsKey = 'app_settings';
  static const List<String> _progressKeys = [
    'user_progress',
    'spaced_repetition_schedule',
  ];

  static final ValueNotifier<AppSettingsModel> settingsNotifier = ValueNotifier(
    AppSettingsModel.initial,
  );

  Future<AppSettingsModel> loadSettings() async {
    final preferences = await SharedPreferences.getInstance();
    final rawSettings = preferences.getString(_appSettingsKey);

    if (rawSettings == null) {
      settingsNotifier.value = AppSettingsModel.initial;
      return AppSettingsModel.initial;
    }

    try {
      final settings = AppSettingsModel.fromJson(
        jsonDecode(rawSettings) as Map<String, dynamic>,
      );
      settingsNotifier.value = settings;
      return settings;
    } on Object {
      settingsNotifier.value = AppSettingsModel.initial;
      return AppSettingsModel.initial;
    }
  }

  Future<void> saveSettings(AppSettingsModel settings) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_appSettingsKey, jsonEncode(settings.toJson()));
    settingsNotifier.value = settings;
  }

  Future<void> resetProgress() async {
    final preferences = await SharedPreferences.getInstance();
    for (final key in _progressKeys) {
      await preferences.remove(key);
    }
  }
}
