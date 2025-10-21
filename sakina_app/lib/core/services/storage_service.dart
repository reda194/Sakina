import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  static const String _messagesKey = 'chat_messages';
  static const String _userPreferencesKey = 'user_preferences';
  static const String _moodDataKey = 'mood_data';
  static const String _analyticsDataKey = 'analytics_data';
  
  SharedPreferences? _prefs;

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Chat Messages Storage
  Future<void> saveMessage(Map<String, dynamic> message) async {
    try {
      await _initPrefs();
      final messages = await getMessages();
      messages.add(message);
      
      // Keep only last 1000 messages to prevent storage overflow
      if (messages.length > 1000) {
        messages.removeRange(0, messages.length - 1000);
      }
      
      await _prefs!.setString(_messagesKey, jsonEncode(messages));
    } catch (e) {
      debugPrint('Error saving message: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getMessages() async {
    try {
      await _initPrefs();
      final messagesJson = _prefs!.getString(_messagesKey);
      if (messagesJson == null) return [];
      
      final List<dynamic> messagesList = jsonDecode(messagesJson);
      return messagesList.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error getting messages: $e');
      return [];
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await _initPrefs();
      final messages = await getMessages();
      messages.removeWhere((message) => message['id'] == messageId);
      await _prefs!.setString(_messagesKey, jsonEncode(messages));
    } catch (e) {
      debugPrint('Error deleting message: $e');
    }
  }

  Future<void> clearMessages() async {
    try {
      await _initPrefs();
      await _prefs!.remove(_messagesKey);
    } catch (e) {
      debugPrint('Error clearing messages: $e');
    }
  }

  // User Preferences Storage
  Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    try {
      await _initPrefs();
      await _prefs!.setString(_userPreferencesKey, jsonEncode(preferences));
    } catch (e) {
      debugPrint('Error saving user preferences: $e');
    }
  }

  Future<Map<String, dynamic>> getUserPreferences() async {
    try {
      await _initPrefs();
      final preferencesJson = _prefs!.getString(_userPreferencesKey);
      if (preferencesJson == null) return {};
      
      return Map<String, dynamic>.from(jsonDecode(preferencesJson));
    } catch (e) {
      debugPrint('Error getting user preferences: $e');
      return {};
    }
  }

  // Mood Data Storage
  Future<void> saveMoodEntry(Map<String, dynamic> moodEntry) async {
    try {
      await _initPrefs();
      final moodData = await getMoodData();
      moodData.add(moodEntry);
      
      // Keep only last 365 days of mood data
      final cutoffDate = DateTime.now().subtract(const Duration(days: 365));
      moodData.removeWhere((entry) {
        final entryDate = DateTime.parse(entry['date']);
        return entryDate.isBefore(cutoffDate);
      });
      
      await _prefs!.setString(_moodDataKey, jsonEncode(moodData));
    } catch (e) {
      debugPrint('Error saving mood entry: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getMoodData() async {
    try {
      await _initPrefs();
      final moodDataJson = _prefs!.getString(_moodDataKey);
      if (moodDataJson == null) return [];
      
      final List<dynamic> moodList = jsonDecode(moodDataJson);
      return moodList.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error getting mood data: $e');
      return [];
    }
  }

  Future<void> deleteMoodEntry(String entryId) async {
    try {
      await _initPrefs();
      final moodData = await getMoodData();
      moodData.removeWhere((entry) => entry['id'] == entryId);
      await _prefs!.setString(_moodDataKey, jsonEncode(moodData));
    } catch (e) {
      debugPrint('Error deleting mood entry: $e');
    }
  }

  // Analytics Data Storage
  Future<void> saveAnalyticsData(Map<String, dynamic> analyticsData) async {
    try {
      await _initPrefs();
      await _prefs!.setString(_analyticsDataKey, jsonEncode(analyticsData));
    } catch (e) {
      debugPrint('Error saving analytics data: $e');
    }
  }

  Future<Map<String, dynamic>> getAnalyticsData() async {
    try {
      await _initPrefs();
      final analyticsJson = _prefs!.getString(_analyticsDataKey);
      if (analyticsJson == null) return {};
      
      return Map<String, dynamic>.from(jsonDecode(analyticsJson));
    } catch (e) {
      debugPrint('Error getting analytics data: $e');
      return {};
    }
  }

  // Generic Storage Methods
  Future<void> saveString(String key, String value) async {
    try {
      await _initPrefs();
      await _prefs!.setString(key, value);
    } catch (e) {
      debugPrint('Error saving string: $e');
    }
  }

  Future<String?> getString(String key) async {
    try {
      await _initPrefs();
      return _prefs!.getString(key);
    } catch (e) {
      debugPrint('Error getting string: $e');
      return null;
    }
  }

  Future<void> saveInt(String key, int value) async {
    try {
      await _initPrefs();
      await _prefs!.setInt(key, value);
    } catch (e) {
      debugPrint('Error saving int: $e');
    }
  }

  Future<int?> getInt(String key) async {
    try {
      await _initPrefs();
      return _prefs!.getInt(key);
    } catch (e) {
      debugPrint('Error getting int: $e');
      return null;
    }
  }

  Future<void> saveBool(String key, bool value) async {
    try {
      await _initPrefs();
      await _prefs!.setBool(key, value);
    } catch (e) {
      debugPrint('Error saving bool: $e');
    }
  }

  Future<bool?> getBool(String key) async {
    try {
      await _initPrefs();
      return _prefs!.getBool(key);
    } catch (e) {
      debugPrint('Error getting bool: $e');
      return null;
    }
  }

  Future<void> saveDouble(String key, double value) async {
    try {
      await _initPrefs();
      await _prefs!.setDouble(key, value);
    } catch (e) {
      debugPrint('Error saving double: $e');
    }
  }

  Future<double?> getDouble(String key) async {
    try {
      await _initPrefs();
      return _prefs!.getDouble(key);
    } catch (e) {
      debugPrint('Error getting double: $e');
      return null;
    }
  }

  Future<void> remove(String key) async {
    try {
      await _initPrefs();
      await _prefs!.remove(key);
    } catch (e) {
      debugPrint('Error removing key: $e');
    }
  }

  Future<void> clear() async {
    try {
      await _initPrefs();
      await _prefs!.clear();
    } catch (e) {
      debugPrint('Error clearing storage: $e');
    }
  }

  Future<bool> containsKey(String key) async {
    try {
      await _initPrefs();
      return _prefs!.containsKey(key);
    } catch (e) {
      debugPrint('Error checking key: $e');
      return false;
    }
  }

  Future<Set<String>> getKeys() async {
    try {
      await _initPrefs();
      return _prefs!.getKeys();
    } catch (e) {
      debugPrint('Error getting keys: $e');
      return <String>{};
    }
  }
}