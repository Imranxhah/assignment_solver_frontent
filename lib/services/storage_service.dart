import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../utils/constants.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();

  // Keys
  static const String _themeModeKey = 'theme_mode';

  // Theme Mode Management
  static Future<void> saveThemeMode(bool isDark) async {
    try {
      await _storage.write(key: _themeModeKey, value: isDark.toString());
    } catch (e) {
      print('Error saving theme mode: $e');
      rethrow;
    }
  }

  static Future<bool> getThemeMode() async {
    try {
      final value = await _storage.read(key: _themeModeKey);
      return value == 'true' ? true : false;
    } catch (e) {
      print('Error getting theme mode: $e');
      return false;
    }
  }

  // Token Management
  static Future<void> saveTokens(
      String accessToken, String refreshToken) async {
    try {
      await _storage.write(
          key: AppConstants.accessTokenKey, value: accessToken);
      await _storage.write(
          key: AppConstants.refreshTokenKey, value: refreshToken);
    } catch (e) {
      print('Error saving tokens: $e');
      rethrow;
    }
  }

  static Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: AppConstants.accessTokenKey);
    } catch (e) {
      print('Error getting access token: $e');
      return null;
    }
  }

  static Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: AppConstants.refreshTokenKey);
    } catch (e) {
      print('Error getting refresh token: $e');
      return null;
    }
  }

  static Future<void> deleteTokens() async {
    try {
      await _storage.delete(key: AppConstants.accessTokenKey);
      await _storage.delete(key: AppConstants.refreshTokenKey);
    } catch (e) {
      print('Error deleting tokens: $e');
    }
  }

  // User Data Management
  static Future<void> saveUser(User user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await _storage.write(key: AppConstants.userDataKey, value: userJson);
    } catch (e) {
      print('Error saving user: $e');
      rethrow;
    }
  }

  static Future<User?> getUser() async {
    try {
      final userJson = await _storage.read(key: AppConstants.userDataKey);
      if (userJson != null) {
        return User.fromJson(jsonDecode(userJson));
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  static Future<void> deleteUser() async {
    try {
      await _storage.delete(key: AppConstants.userDataKey);
    } catch (e) {
      print('Error deleting user: $e');
    }
  }

  // Clear All Data
  static Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      print('Error clearing storage: $e');
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final token = await getAccessToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }
}
