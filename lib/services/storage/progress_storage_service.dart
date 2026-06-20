import 'dart:convert';

import 'package:english_drops_daily/domain/models/user_progress_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressStorageService {
  const ProgressStorageService();

  static const String _progressKey = 'user_progress';

  Future<UserProgressModel> getProgress() async {
    final preferences = await SharedPreferences.getInstance();
    final rawProgress = preferences.getString(_progressKey);

    if (rawProgress == null) {
      return const UserProgressModel();
    }

    try {
      final json = jsonDecode(rawProgress) as Map<String, dynamic>;
      return UserProgressModel.fromJson(json);
    } on Object {
      return const UserProgressModel();
    }
  }

  Future<void> saveProgress(UserProgressModel progress) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_progressKey, jsonEncode(progress.toJson()));
  }

  Future<void> resetProgress() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_progressKey);
  }
}
