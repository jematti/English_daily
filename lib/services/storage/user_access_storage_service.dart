import 'dart:convert';

import 'package:english_drops_daily/domain/models/user_access_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserAccessStorageService {
  const UserAccessStorageService();

  static const String _userAccessKey = 'user_access';

  Future<UserAccessModel> getUserAccess() async {
    final preferences = await SharedPreferences.getInstance();
    final rawAccess = preferences.getString(_userAccessKey);

    if (rawAccess == null) {
      return UserAccessModel.free;
    }

    try {
      final json = jsonDecode(rawAccess) as Map<String, dynamic>;
      return UserAccessModel.fromJson(json);
    } on Object {
      return UserAccessModel.free;
    }
  }

  Future<void> saveUserAccess(UserAccessModel access) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_userAccessKey, jsonEncode(access.toJson()));
  }
}
