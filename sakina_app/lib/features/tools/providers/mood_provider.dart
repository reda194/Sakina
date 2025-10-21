import 'package:flutter/material.dart';
import '../../../models/mood_entry.dart';
import '../../../services/storage_service.dart';

class MoodProvider extends ChangeNotifier {
  final StorageService _storageService;

  List<MoodEntry> _moodEntries = [];
  bool _isLoading = false;
  String? _errorMessage;

  MoodProvider(this._storageService) {
    loadMoodEntries();
  }

  List<MoodEntry> get moodEntries => _moodEntries;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get mood entries for today
  List<MoodEntry> get todayEntries {
    final today = DateTime.now();
    return _moodEntries
        .where((entry) =>
            entry.timestamp.year == today.year &&
            entry.timestamp.month == today.month &&
            entry.timestamp.day == today.day)
        .toList();
  }

  // Get mood entries for this week
  List<MoodEntry> get weekEntries {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return _moodEntries
        .where((entry) => entry.timestamp
            .isAfter(weekStart.subtract(const Duration(days: 1))))
        .toList();
  }

  // Get mood entries for this month
  List<MoodEntry> get monthEntries {
    final now = DateTime.now();
    return _moodEntries
        .where((entry) =>
            entry.timestamp.year == now.year &&
            entry.timestamp.month == now.month)
        .toList();
  }

  // Calculate average mood for a period
  double? getAverageMood(List<MoodEntry> entries) {
    if (entries.isEmpty) return null;
    final sum = entries.fold(0, (sum, entry) => sum + entry.mood);
    return sum / entries.length;
  }

  // Get mood entries in a specific date range
  List<MoodEntry> getMoodEntriesInRange(DateTime startDate, DateTime endDate) {
    return _moodEntries
        .where((entry) => 
            entry.timestamp.isAfter(startDate.subtract(const Duration(days: 1))) &&
            entry.timestamp.isBefore(endDate.add(const Duration(days: 1))))
        .toList();
  }

  // Get mood trend (positive, negative, stable)
  String getMoodTrend() {
    if (_moodEntries.length < 7) return 'غير كافٍ';

    final recentWeek = weekEntries;
    final previousWeek = _moodEntries.where((entry) {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final prevWeekStart = weekStart.subtract(const Duration(days: 7));
      return entry.timestamp
              .isAfter(prevWeekStart.subtract(const Duration(days: 1))) &&
          entry.timestamp.isBefore(weekStart);
    }).toList();

    final recentAvg = getAverageMood(recentWeek);
    final previousAvg = getAverageMood(previousWeek);

    if (recentAvg == null || previousAvg == null) return 'غير كافٍ';

    final difference = recentAvg - previousAvg;
    if (difference > 0.5) return 'متحسن';
    if (difference < -0.5) return 'متراجع';
    return 'مستقر';
  }

  Future<void> loadMoodEntries() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Load from Firebase or local storage
      // For now, we'll use mock data
      await Future.delayed(const Duration(seconds: 1));

      final userId = _storageService.getUserId() ?? 'guest';
      _moodEntries = _generateMockData(userId);
    } catch (e) {
      _errorMessage = 'فشل في تحميل بيانات المزاج';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveMoodEntry(MoodEntry entry) async {
    try {
      // TODO: Save to Firebase
      // For now, just add to local list
      _moodEntries.add(entry);
      _moodEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'فشل في حفظ المزاج';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMoodEntry(String entryId) async {
    try {
      _moodEntries.removeWhere((entry) => entry.id == entryId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'فشل في حذف المزاج';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Generate mock data for demonstration
  List<MoodEntry> _generateMockData(String userId) {
    final entries = <MoodEntry>[];
    final now = DateTime.now();

    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final mood = 2 + (i % 4); // Varying moods between 2-5

      entries.add(MoodEntry(
        id: 'mood_$i',
        mood: mood,
        note: i % 3 == 0 ? 'شعرت بتحسن اليوم' : null,
        timestamp: date,
        userId: userId,
        triggers: i % 2 == 0 ? ['العمل', 'التوتر'] : null,
        activities: i % 3 == 0 ? ['المشي', 'القراءة'] : null,
        energyLevel: mood > 3 ? 4 : 2,
        anxietyLevel: mood < 3 ? 4 : 2,
        sleepQuality: mood > 3 ? 4 : 3,
      ));
    }

    return entries;
  }
}
