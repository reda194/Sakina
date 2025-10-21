import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../models/mood_entry.dart';
import '../../../core/services/ai_service.dart';

class AdvancedMoodProvider with ChangeNotifier {
  final List<MoodEntry> _moodEntries = [];
  final AiService _aiService = AiService.instance;
  
  bool _isLoading = false;
  String? _error;
  
  // Settings
  bool _dailyReminders = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  bool _weeklyReports = true;
  bool _smartInsights = true;
  int _trackingStreak = 0;
  DateTime? _lastEntryDate;
  
  // Analytics
  final Map<String, double> _factorCorrelations = {};
  List<String> _topPositiveFactors = [];
  List<String> _topNegativeFactors = [];
  double _averageMood = 0.0;
  final Map<int, double> _weeklyAverages = {};
  
  // Getters
  List<MoodEntry> get moodEntries => List.unmodifiable(_moodEntries);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get dailyReminders => _dailyReminders;
  TimeOfDay get reminderTime => _reminderTime;
  bool get weeklyReports => _weeklyReports;
  bool get smartInsights => _smartInsights;
  int get trackingStreak => _trackingStreak;
  DateTime? get lastEntryDate => _lastEntryDate;
  Map<String, double> get factorCorrelations => Map.unmodifiable(_factorCorrelations);
  List<String> get topPositiveFactors => List.unmodifiable(_topPositiveFactors);
  List<String> get topNegativeFactors => List.unmodifiable(_topNegativeFactors);
  double get averageMood => _averageMood;
  Map<int, double> get weeklyAverages => Map.unmodifiable(_weeklyAverages);
  
  // Recent entries for quick access
  List<MoodEntry> get recentEntries {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    return _moodEntries
        .where((entry) => entry.timestamp.isAfter(sevenDaysAgo))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
  
  // Today's entry
  MoodEntry? get todayEntry {
    final today = DateTime.now();
    return _moodEntries.firstWhere(
      (entry) => 
          entry.timestamp.year == today.year &&
          entry.timestamp.month == today.month &&
          entry.timestamp.day == today.day,
      orElse: () => null as MoodEntry,
    );
  }
  
  // This week's entries
  List<MoodEntry> get thisWeekEntries {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    
    return _moodEntries
        .where((entry) => entry.timestamp.isAfter(startOfWeekDate))
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }
  
  // This month's entries
  List<MoodEntry> get thisMonthEntries {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    return _moodEntries
        .where((entry) => entry.timestamp.isAfter(startOfMonth))
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  AdvancedMoodProvider() {
    _loadData();
    _scheduleNotifications();
  }

  // Load data from storage
  Future<void> _loadData() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load mood entries
      final entriesJson = prefs.getStringList('mood_entries') ?? [];
      _moodEntries.clear();
      for (final entryJson in entriesJson) {
        final entryMap = json.decode(entryJson) as Map<String, dynamic>;
        _moodEntries.add(MoodEntry.fromJson(entryMap));
      }
      
      // Sort entries by timestamp (newest first)
      _moodEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      // Load settings
      _dailyReminders = prefs.getBool('daily_reminders') ?? true;
      _weeklyReports = prefs.getBool('weekly_reports') ?? true;
      _smartInsights = prefs.getBool('smart_insights') ?? true;
      _trackingStreak = prefs.getInt('tracking_streak') ?? 0;
      
      final reminderHour = prefs.getInt('reminder_hour') ?? 20;
      final reminderMinute = prefs.getInt('reminder_minute') ?? 0;
      _reminderTime = TimeOfDay(hour: reminderHour, minute: reminderMinute);
      
      final lastEntryTimestamp = prefs.getInt('last_entry_date');
      if (lastEntryTimestamp != null) {
        _lastEntryDate = DateTime.fromMillisecondsSinceEpoch(lastEntryTimestamp);
      }
      
      // Calculate analytics
      _calculateAnalytics();
      
      _error = null;
    } catch (e) {
      _error = 'فشل في تحميل البيانات: $e';
      debugPrint('Error loading mood data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Save data to storage
  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save mood entries
      final entriesJson = _moodEntries
          .map((entry) => json.encode(entry.toJson()))
          .toList();
      await prefs.setStringList('mood_entries', entriesJson);
      
      // Save settings
      await prefs.setBool('daily_reminders', _dailyReminders);
      await prefs.setBool('weekly_reports', _weeklyReports);
      await prefs.setBool('smart_insights', _smartInsights);
      await prefs.setInt('tracking_streak', _trackingStreak);
      await prefs.setInt('reminder_hour', _reminderTime.hour);
      await prefs.setInt('reminder_minute', _reminderTime.minute);
      
      if (_lastEntryDate != null) {
        await prefs.setInt('last_entry_date', _lastEntryDate!.millisecondsSinceEpoch);
      }
    } catch (e) {
      debugPrint('Error saving mood data: $e');
    }
  }

  // Add new mood entry
  Future<void> addMoodEntry(MoodEntry entry) async {
    _setLoading(true);
    try {
      // Remove existing entry for the same day if it exists
      _moodEntries.removeWhere((existing) =>
          existing.timestamp.year == entry.timestamp.year &&
          existing.timestamp.month == entry.timestamp.month &&
          existing.timestamp.day == entry.timestamp.day);
      
      // Add new entry
      _moodEntries.add(entry);
      _moodEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      // Update streak
      _updateTrackingStreak(entry.timestamp);
      
      // Save data
      await _saveData();
      
      // Recalculate analytics
      _calculateAnalytics();
      
      // Generate AI insights if enabled
      if (_smartInsights) {
        _generateAIInsights(entry);
      }
      
      _error = null;
    } catch (e) {
      _error = 'فشل في حفظ البيانات: $e';
      debugPrint('Error adding mood entry: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update existing mood entry
  Future<void> updateMoodEntry(String id, MoodEntry updatedEntry) async {
    _setLoading(true);
    try {
      final index = _moodEntries.indexWhere((entry) => entry.id == id);
      if (index != -1) {
        _moodEntries[index] = updatedEntry;
        _moodEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        await _saveData();
        _calculateAnalytics();
        
        _error = null;
      }
    } catch (e) {
      _error = 'فشل في تحديث البيانات: $e';
      debugPrint('Error updating mood entry: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Delete mood entry
  Future<void> deleteMoodEntry(String id) async {
    _setLoading(true);
    try {
      _moodEntries.removeWhere((entry) => entry.id == id);
      await _saveData();
      _calculateAnalytics();
      _error = null;
    } catch (e) {
      _error = 'فشل في حذف البيانات: $e';
      debugPrint('Error deleting mood entry: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get entries for a specific date range
  List<MoodEntry> getEntriesForDateRange(DateTime start, DateTime end) {
    return _moodEntries
        .where((entry) => 
            entry.timestamp.isAfter(start.subtract(const Duration(days: 1))) &&
            entry.timestamp.isBefore(end.add(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  // Get entries for a specific month
  List<MoodEntry> getEntriesForMonth(int year, int month) {
    return _moodEntries
        .where((entry) => 
            entry.timestamp.year == year && entry.timestamp.month == month)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  // Update tracking streak
  void _updateTrackingStreak(DateTime entryDate) {
    final today = DateTime.now();
    final entryDay = DateTime(entryDate.year, entryDate.month, entryDate.day);
    final todayDay = DateTime(today.year, today.month, today.day);
    
    if (_lastEntryDate == null) {
      _trackingStreak = 1;
    } else {
      final lastEntryDay = DateTime(
        _lastEntryDate!.year,
        _lastEntryDate!.month,
        _lastEntryDate!.day,
      );
      
      final daysDifference = todayDay.difference(lastEntryDay).inDays;
      
      if (daysDifference == 1) {
        // Consecutive day
        _trackingStreak++;
      } else if (daysDifference == 0) {
        // Same day, don't change streak
      } else {
        // Streak broken
        _trackingStreak = 1;
      }
    }
    
    _lastEntryDate = entryDate;
  }

  // Calculate analytics
  void _calculateAnalytics() {
    if (_moodEntries.isEmpty) {
      _averageMood = 0.0;
      _factorCorrelations.clear();
      _topPositiveFactors.clear();
      _topNegativeFactors.clear();
      _weeklyAverages.clear();
      return;
    }
    
    // Calculate average mood
    _averageMood = _moodEntries
        .map((entry) => entry.mood.numericValue.toDouble())
        .reduce((a, b) => a + b) / _moodEntries.length;
    
    // Calculate factor correlations
    _calculateFactorCorrelations();
    
    // Calculate weekly averages
    _calculateWeeklyAverages();
    
    // Identify top factors
    _identifyTopFactors();
  }

  // Calculate factor correlations with mood
  void _calculateFactorCorrelations() {
    _factorCorrelations.clear();
    
    final factorMoodSums = <String, double>{};
    final factorCounts = <String, int>{};
    
    for (final entry in _moodEntries) {
      if (entry.triggers != null) {
        for (final factor in entry.triggers!) {
          factorMoodSums[factor] = (factorMoodSums[factor] ?? 0) + entry.mood.numericValue.toDouble();
          factorCounts[factor] = (factorCounts[factor] ?? 0) + 1;
        }
      }
    }
    
    factorMoodSums.forEach((factor, moodSum) {
      final count = factorCounts[factor]!;
      if (count >= 3) { // Only consider factors with at least 3 occurrences
        _factorCorrelations[factor] = moodSum / count;
      }
    });
  }

  // Calculate weekly averages
  void _calculateWeeklyAverages() {
    _weeklyAverages.clear();
    
    final weeklyMoods = <int, List<double>>{};
    
    for (final entry in _moodEntries) {
      final weekday = entry.timestamp.weekday;
      weeklyMoods[weekday] = (weeklyMoods[weekday] ?? [])..add(entry.mood.numericValue.toDouble());
    }
    
    weeklyMoods.forEach((weekday, moods) {
      _weeklyAverages[weekday] = moods.reduce((a, b) => a + b) / moods.length;
    });
  }

  // Identify top positive and negative factors
  void _identifyTopFactors() {
    final sortedFactors = _factorCorrelations.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    _topPositiveFactors = sortedFactors
        .where((entry) => entry.value > _averageMood)
        .take(5)
        .map((entry) => entry.key)
        .toList();
    
    _topNegativeFactors = sortedFactors
        .where((entry) => entry.value < _averageMood)
        .take(5)
        .map((entry) => entry.key)
        .toList();
  }

  // Generate AI insights
  Future<void> _generateAIInsights(MoodEntry entry) async {
    try {
      final recentEntries = _moodEntries.take(7).toList();
      final context = {
        'current_mood': entry.mood.name,
        'current_mood_numeric': entry.mood.numericValue,
        'sleep_quality': entry.sleepQuality,
        'energy_level': entry.energyLevel,
        'anxiety_level': entry.anxietyLevel,
        'recent_average': recentEntries.isNotEmpty
            ? recentEntries.map((e) => e.mood.numericValue.toDouble()).reduce((a, b) => a + b) / recentEntries.length
            : 0.0,
        'triggers': entry.triggers,
        'note': entry.note,
        'tracking_streak': _trackingStreak,
      };

      // This would typically call an AI service
      // For now, we'll just log the context
      debugPrint('AI Insight Context: $context');
    } catch (e) {
      debugPrint('Error generating AI insights: $e');
    }
  }

  // Settings management
  Future<void> updateDailyReminders(bool enabled) async {
    _dailyReminders = enabled;
    await _saveData();
    
    if (enabled) {
      _scheduleNotifications();
    } else {
      // await _notificationService.cancelAllNotifications();
    }
    
    notifyListeners();
  }

  Future<void> updateReminderTime(TimeOfDay time) async {
    _reminderTime = time;
    await _saveData();
    
    if (_dailyReminders) {
      _scheduleNotifications();
    }
    
    notifyListeners();
  }

  Future<void> updateWeeklyReports(bool enabled) async {
    _weeklyReports = enabled;
    await _saveData();
    notifyListeners();
  }

  Future<void> updateSmartInsights(bool enabled) async {
    _smartInsights = enabled;
    await _saveData();
    notifyListeners();
  }

  // Schedule notifications
  Future<void> _scheduleNotifications() async {
    if (!_dailyReminders) return;
    
    try {
      // await _notificationService.scheduleDailyNotification(
      //   id: 1,
      //   title: 'تذكير تسجيل المزاج',
      //   body: 'كيف كان مزاجك اليوم؟ سجل مشاعرك الآن',
      //   hour: _reminderTime.hour,
      //   minute: _reminderTime.minute,
      // );
    } catch (e) {
      debugPrint('Error scheduling notifications: $e');
    }
  }

  // Export data
  Map<String, dynamic> exportData() {
    return {
      'mood_entries': _moodEntries.map((entry) => entry.toJson()).toList(),
      'settings': {
        'daily_reminders': _dailyReminders,
        'reminder_time': {
          'hour': _reminderTime.hour,
          'minute': _reminderTime.minute,
        },
        'weekly_reports': _weeklyReports,
        'smart_insights': _smartInsights,
      },
      'analytics': {
        'tracking_streak': _trackingStreak,
        'average_mood': _averageMood,
        'factor_correlations': _factorCorrelations,
        'weekly_averages': _weeklyAverages,
      },
      'export_date': DateTime.now().toIso8601String(),
    };
  }

  // Import data
  Future<void> importData(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      // Import mood entries
      if (data['mood_entries'] != null) {
        _moodEntries.clear();
        for (final entryData in data['mood_entries']) {
          _moodEntries.add(MoodEntry.fromJson(entryData));
        }
        _moodEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }
      
      // Import settings
      if (data['settings'] != null) {
        final settings = data['settings'];
        _dailyReminders = settings['daily_reminders'] ?? _dailyReminders;
        _weeklyReports = settings['weekly_reports'] ?? _weeklyReports;
        _smartInsights = settings['smart_insights'] ?? _smartInsights;
        
        if (settings['reminder_time'] != null) {
          final reminderTime = settings['reminder_time'];
          _reminderTime = TimeOfDay(
            hour: reminderTime['hour'] ?? 20,
            minute: reminderTime['minute'] ?? 0,
          );
        }
      }
      
      // Import analytics
      if (data['analytics'] != null) {
        final analytics = data['analytics'];
        _trackingStreak = analytics['tracking_streak'] ?? 0;
      }
      
      await _saveData();
      _calculateAnalytics();
      
      if (_dailyReminders) {
        _scheduleNotifications();
      }
      
      _error = null;
    } catch (e) {
      _error = 'فشل في استيراد البيانات: $e';
      debugPrint('Error importing data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Clear all data
  Future<void> clearAllData() async {
    _setLoading(true);
    try {
      _moodEntries.clear();
      _trackingStreak = 0;
      _lastEntryDate = null;
      _factorCorrelations.clear();
      _topPositiveFactors.clear();
      _topNegativeFactors.clear();
      _averageMood = 0.0;
      _weeklyAverages.clear();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('mood_entries');
      await prefs.remove('tracking_streak');
      await prefs.remove('last_entry_date');
      
      _error = null;
    } catch (e) {
      _error = 'فشل في مسح البيانات: $e';
      debugPrint('Error clearing data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get mood statistics
  Map<String, dynamic> getMoodStatistics() {
    if (_moodEntries.isEmpty) {
      return {
        'total_entries': 0,
        'average_mood': 0.0,
        'best_mood': 0,
        'worst_mood': 0,
        'mood_variance': 0.0,
      };
    }
    
    final moodValues = _moodEntries.map((e) => e.mood.toDouble()).toList();
    final total = moodValues.length;
    final average = moodValues.reduce((a, b) => a + b) / total;
    final best = moodValues.reduce((a, b) => a > b ? a : b);
    final worst = moodValues.reduce((a, b) => a < b ? a : b);

    // Calculate variance
    final variance = moodValues
        .map((mood) => (mood - average) * (mood - average))
        .reduce((a, b) => a + b) / total;
    
    return {
      'total_entries': total,
      'average_mood': average,
      'best_mood': best,
      'worst_mood': worst,
      'mood_variance': variance,
    };
  }
}

class TimeOfDay {
  final int hour;
  final int minute;
  
  const TimeOfDay({required this.hour, required this.minute});
  
  @override
  String toString() => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}