import 'package:flutter/material.dart';
import '../../../models/mood_entry.dart';
import '../../../services/storage_service.dart';

class MoodProvider extends ChangeNotifier {
  final StorageService _storageService;

  List<MoodEntry> _moodEntries = [];
  bool _isLoading = false;
  String? _errorMessage;
  int? _currentMood;

  MoodProvider(this._storageService) {
    _loadMoodEntries();
  }

  // Getters
  List<MoodEntry> get moodEntries => _moodEntries;
  List<MoodEntry> get moodHistory => _moodEntries; // Alias for moodEntries
  List<MoodEntry> get recentMoodEntries {
    return _moodEntries.where((entry) {
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      return entry.timestamp.isAfter(sevenDaysAgo);
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get currentMood => _currentMood;

  double get averageMood {
    if (_moodEntries.isEmpty) return 3.0; // Neutral mood
    final sum = _moodEntries.fold(0.0, (sum, entry) => sum + entry.mood.numericValue.toDouble());
    return sum / _moodEntries.length;
  }

  int get trackingDays {
    final today = DateTime.now();
    final startOfMonth = DateTime(today.year, today.month, 1);
    return _moodEntries.where((entry) =>
      entry.timestamp.isAfter(startOfMonth.subtract(const Duration(days: 1)))
    ).length;
  }

  int get bestMood {
    if (_moodEntries.isEmpty) return 3;
    return _moodEntries.map((e) => e.mood.numericValue).reduce((a, b) => a > b ? a : b);
  }

  int get worstMood {
    if (_moodEntries.isEmpty) return 3;
    return _moodEntries.map((e) => e.mood.numericValue).reduce((a, b) => a < b ? a : b);
  }

  int get trackingStreak {
    if (_moodEntries.isEmpty) return 0;
    // Simple streak calculation - count consecutive days with entries
    int streak = 0;
    final today = DateTime.now();
    DateTime currentDate = today;

    while (true) {
      final hasEntry = _moodEntries.any((entry) {
        return entry.timestamp.year == currentDate.year &&
               entry.timestamp.month == currentDate.month &&
               entry.timestamp.day == currentDate.day;
      });

      if (!hasEntry) break;
      streak++;
      currentDate = currentDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  String get bestDay {
    if (_moodEntries.isEmpty) return 'لا توجد بيانات';

    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));

    final thisWeekEntries = _moodEntries.where((entry) =>
      entry.timestamp.isAfter(startOfWeek.subtract(const Duration(days: 1)))
    ).toList();

    if (thisWeekEntries.isEmpty) return 'لا توجد بيانات';

    final bestEntry = thisWeekEntries.reduce((a, b) =>
      a.mood > b.mood ? a : b
    );

    final days = ['السبت', 'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];
    return days[bestEntry.timestamp.weekday % 7];
  }

  // Load mood entries from storage
  Future<void> _loadMoodEntries() async {
    _isLoading = true;
    notifyListeners();

    try {
      final entries = await _storageService.getMoodEntries();
      _moodEntries = entries;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'فشل في تحميل بيانات المزاج';
      notifyListeners();
    }
  }

  // Add new mood entry
  Future<void> addMoodEntry(MoodEntry entry) async {
    try {
      _moodEntries.add(entry);
      _currentMood = entry.mood.numericValue; // Update current mood
      await _storageService.saveMoodEntry(entry);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'فشل في حفظ الحالة المزاجية';
      notifyListeners();
    }
  }

  // Load mood history (alias for refresh)
  Future<void> loadMoodHistory() async {
    await refresh();
  }

  // Update current mood
  Future<void> updateMood(int mood) async {
    try {
      final entry = MoodEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user', // Should get from auth provider
        mood: MoodType.fromNumeric(mood),
        timestamp: DateTime.now(),
      );

      await addMoodEntry(entry);
    } catch (e) {
      _errorMessage = 'فشل في تحديث المزاج';
      notifyListeners();
    }
  }

  // Get mood entries for a specific date range
  List<MoodEntry> getMoodEntriesForDateRange(
      DateTime startDate, DateTime endDate) {
    return _moodEntries.where((entry) {
      return entry.timestamp
              .isAfter(startDate.subtract(const Duration(days: 1))) &&
          entry.timestamp.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  // Get average mood for a time period
  double getAverageMood(List<MoodEntry> entries) {
    if (entries.isEmpty) return 0.0;

    final sum = entries.fold(0.0, (sum, entry) => sum + entry.mood.numericValue.toDouble());
    return sum / entries.length;
  }

  // Get mood trend (improving, declining, stable)
  String getMoodTrend() {
    if (_moodEntries.length < 2) return 'stable';

    final recent = _moodEntries.take(7).toList();
    final older = _moodEntries.skip(7).take(7).toList();

    if (recent.isEmpty || older.isEmpty) return 'stable';

    final recentAvg = getAverageMood(recent);
    final olderAvg = getAverageMood(older);

    if (recentAvg > olderAvg + 0.5) return 'improving';
    if (recentAvg < olderAvg - 0.5) return 'declining';
    return 'stable';
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Refresh data
  Future<void> refresh() async {
    await _loadMoodEntries();
  }
}
