import 'dart:convert';

import 'package:dp/models/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSessionStorage {
  static const String _profileKey = 'user_profile';
  static const String _isLoggedInKey = 'is_logged_in';

  static Future<UserProfileData> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final rawProfile = prefs.getString(_profileKey);
    if (rawProfile == null || rawProfile.isEmpty) {
      return const UserProfileData.empty();
    }

    try {
      final json = jsonDecode(rawProfile) as Map<String, dynamic>;
      return UserProfileData.fromJson(json);
    } catch (_) {
      return const UserProfileData.empty();
    }
  }

  static Future<void> saveProfile(UserProfileData profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, value);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
  }
}
