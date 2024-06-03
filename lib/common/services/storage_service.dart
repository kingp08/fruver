import 'dart:convert';

import 'package:fruver/common/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../values/constants.dart';

class StorageService {
  late final SharedPreferences _preferences;

  Future<StorageService> init() async {
    _preferences = await SharedPreferences.getInstance();
    return this;
  }

  Future<bool> setBool(String key, bool value) async {
    return await _preferences.setBool(key, value);
  }

  Future<bool> setString(String key, String value) async {
    return await _preferences.setString(key, value);
  }

  UserModel? getUserProfile() {
    var userProfile =
        _preferences.getString(AppConstants.STORAGE_USER_PROFILE_KEY) ?? "";
    if (userProfile.isNotEmpty) {
      print(userProfile);
      return UserModel.fromJson(jsonDecode(userProfile));
    }

    return null;
  }

  bool isLoggedIn() {
    return _preferences.getBool(AppConstants.IS_LOGGED_IN) ?? false;
  }

  Future<bool> removeValue(String key) {
    return _preferences.remove(key);
  }

  Future<bool> clear() {
    return _preferences.clear();
  }
}
