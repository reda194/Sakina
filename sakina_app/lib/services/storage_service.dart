import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/mood_entry.dart';

class StorageService {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  StorageService(this._prefs, this._secureStorage);

  // Secure Storage Methods (for sensitive data)
  Future<String?> getSecureString(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      print('Error reading secure string: $e');
      return null;
    }
  }

  Future<void> setSecureString(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } catch (e) {
      print('Error writing secure string: $e');
    }
  }

  Future<void> deleteSecureString(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      print('Error deleting secure string: $e');
    }
  }

  Future<void> clearAllSecureData() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      print('Error clearing secure storage: $e');
    }
  }

  // Shared Preferences Methods (for non-sensitive data)
  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  Future<bool> setDouble(String key, double value) async {
    return await _prefs.setDouble(key, value);
  }

  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs.setStringList(key, value);
  }

  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  Future<bool> clear() async {
    return await _prefs.clear();
  }

  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  // User Session Methods
  Future<void> saveUserToken(String token) async {
    await setSecureString('user_token', token);
  }

  Future<String?> getUserToken() async {
    return await getSecureString('user_token');
  }

  Future<void> saveUserId(String userId) async {
    await setString('user_id', userId);
  }

  String? getUserId() {
    return getString('user_id');
  }

  Future<void> saveUserEmail(String email) async {
    await setString('user_email', email);
  }

  String? getUserEmail() {
    return getString('user_email');
  }

  Future<void> setLoggedIn(bool isLoggedIn) async {
    await setBool('is_logged_in', isLoggedIn);
  }

  bool isLoggedIn() {
    return getBool('is_logged_in') ?? false;
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    await setBool('onboarding_completed', completed);
  }

  bool isOnboardingCompleted() {
    return getBool('onboarding_completed') ?? false;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await setBool('biometric_enabled', enabled);
  }

  bool isBiometricEnabled() {
    return getBool('biometric_enabled') ?? false;
  }

  Future<void> setThemeMode(String mode) async {
    await setString('theme_mode', mode);
  }

  String getThemeMode() {
    return getString('theme_mode') ?? 'light';
  }

  Future<void> setLanguageCode(String code) async {
    await setString('language_code', code);
  }

  String getLanguageCode() {
    return getString('language_code') ?? 'ar';
  }

  Future<void> clearUserData() async {
    await deleteSecureString('user_token');
    await remove('user_id');
    await remove('user_email');
    await setBool('is_logged_in', false);
  }

  // Mood Entry Methods
  Future<void> saveMoodEntry(MoodEntry entry) async {
    try {
      final entries = await getMoodEntries();
      entries.add(entry);

      final jsonList = entries.map((e) => e.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      await setString('mood_entries', jsonString);
    } catch (e) {
      print('Error saving mood entry: $e');
      rethrow;
    }
  }

  Future<List<MoodEntry>> getMoodEntries() async {
    try {
      final jsonString = getString('mood_entries');
      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList.map((json) => MoodEntry.fromJson(json)).toList();
    } catch (e) {
      print('Error loading mood entries: $e');
      return [];
    }
  }

  Future<void> clearMoodEntries() async {
    await remove('mood_entries');
  }

  // User Preferences Methods
  Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    try {
      final jsonString = jsonEncode(preferences);
      await setString('user_preferences', jsonString);
    } catch (e) {
      print('Error saving user preferences: $e');
    }
  }

  Future<Map<String, dynamic>> getUserPreferences() async {
    try {
      final jsonString = getString('user_preferences');
      if (jsonString == null) return {};

      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('Error loading user preferences: $e');
      return {};
    }
  }

  // Generic list storage methods
  Future<List<Map<String, dynamic>>> getList(String key) async {
    try {
      final jsonString = getString(key);
      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List<dynamic>;

      // Iterate and check each item is a Map before casting, skip malformed items
      final result = <Map<String, dynamic>>[];
      for (final item in jsonList) {
        if (item is Map<String, dynamic>) {
          result.add(item);
        } else if (item is Map) {
          // Handle Map with non-String keys by converting
          result.add(Map<String, dynamic>.from(item));
        }
        // Skip items that are not Maps (malformed data)
      }
      return result;
    } catch (e) {
      print('Error loading list for key $key: $e');
      return [];
    }
  }

  Future<void> saveList(String key, List<Map<String, dynamic>> list) async {
    try {
      final jsonString = jsonEncode(list);
      await setString(key, jsonString);
    } catch (e) {
      print('Error saving list for key $key: $e');
      rethrow;
    }
  }
}
