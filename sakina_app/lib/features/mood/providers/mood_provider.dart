import 'package:flutter/material.dart';
import '../../../models/mood_entry.dart';
import '../../../services/storage_service.dart';

class MoodProvider extends ChangeNotifier {
  final StorageService _storageService;

  List<MoodEntry> _moodEntries = [];
  bool _isLoading = false;
  String? _errorMessage;

  MoodProvider(this._storageService) {
    _loadMoodEntries();
  }

  // Getters
  List<MoodEntry> get moodEntries => _moodEntries;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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
      await _storageService.saveMoodEntry(entry);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'فشل في حفظ الحالة المزاجية';
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

    final sum = entries.fold(0.0, (sum, entry) => sum + entry.mood);
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
