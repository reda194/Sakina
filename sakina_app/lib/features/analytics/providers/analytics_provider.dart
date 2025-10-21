import 'package:flutter/material.dart';
import '../../../models/mood_entry.dart';
import '../../../services/storage_service.dart';
import '../../tools/providers/mood_provider.dart';

class AnalyticsProvider with ChangeNotifier {
  final StorageService _storageService;
  final MoodProvider _moodProvider;

  AnalyticsProvider(this._storageService, this._moodProvider);

  bool _isLoading = false;
  String _selectedPeriod = 'week';
  
  // Analytics Data
  double _averageMood = 0.0;
  int _trackingDays = 0;
  double _averageEnergy = 0.0;
  double _averageSleep = 0.0;
  Map<String, int> _moodDistribution = {};
  List<Map<String, dynamic>> _topTriggers = [];
  List<Map<String, dynamic>> _goals = [];
  List<Map<String, dynamic>> _achievements = [];
  List<String> _moodSummary = [];
  List<String> _improvements = [];
  List<String> _recommendations = [];

  // Getters
  bool get isLoading => _isLoading;
  String get selectedPeriod => _selectedPeriod;
  double get averageMood => _averageMood;
  int get trackingDays => _trackingDays;
  double get averageEnergy => _averageEnergy;
  double get averageSleep => _averageSleep;
  Map<String, int> get moodDistribution => _moodDistribution;
  List<Map<String, dynamic>> get topTriggers => _topTriggers;
  List<Map<String, dynamic>> get goals => _goals;
  List<Map<String, dynamic>> get achievements => _achievements;
  List<String> get moodSummary => _moodSummary;
  List<String> get improvements => _improvements;
  List<String> get recommendations => _recommendations;

  Future<void> loadAnalytics() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _calculateAnalytics();
    } catch (e) {
      debugPrint('Error loading analytics: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void changePeriod(String period) {
    _selectedPeriod = period;
    loadAnalytics();
  }

  Future<void> _calculateAnalytics() async {
    final entries = await _getMoodEntriesForPeriod();
    
    if (entries.isEmpty) {
      _resetAnalytics();
      return;
    }

    _calculateBasicStats(entries);
    _calculateMoodDistribution(entries);
    _calculateTopTriggers(entries);
    _generateGoals();
    _generateAchievements();
    _generateInsights(entries);
  }

  Future<List<MoodEntry>> _getMoodEntriesForPeriod() async {
    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedPeriod) {
      case 'week':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'month':
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case 'quarter':
        startDate = DateTime(now.year, now.month - 3, now.day);
        break;
      case 'year':
        startDate = DateTime(now.year - 1, now.month, now.day);
        break;
      default:
        startDate = now.subtract(const Duration(days: 7));
    }

    return _moodProvider.getMoodEntriesInRange(startDate, now);
  }

  void _calculateBasicStats(List<MoodEntry> entries) {
    _trackingDays = entries.length;

    if (entries.isNotEmpty) {
      _averageMood = entries.map((e) => e.mood.numericValue.toDouble()).reduce((a, b) => a + b) / entries.length;
      
      final energyEntries = entries.where((e) => e.energyLevel != null);
      if (energyEntries.isNotEmpty) {
        _averageEnergy = energyEntries.map((e) => e.energyLevel!).reduce((a, b) => a + b) / energyEntries.length;
      }
      
      final sleepEntries = entries.where((e) => e.sleepQuality != null);
      if (sleepEntries.isNotEmpty) {
        _averageSleep = sleepEntries.map((e) => e.sleepQuality!).reduce((a, b) => a + b) / sleepEntries.length;
      }
    }
  }

  void _calculateMoodDistribution(List<MoodEntry> entries) {
    _moodDistribution = {
      'ممتاز': 0,
      'جيد': 0,
      'عادي': 0,
      'سيء': 0,
      'سيء جداً': 0,
    };

    for (final entry in entries) {
      final moodText = _getMoodText(entry.mood.toInt());
      _moodDistribution[moodText] = (_moodDistribution[moodText] ?? 0) + 1;
    }

    // Convert to percentages
    final total = entries.length;
    if (total > 0) {
      _moodDistribution = _moodDistribution.map(
        (key, value) => MapEntry(key, ((value / total) * 100).round()),
      );
    }
  }

  void _calculateTopTriggers(List<MoodEntry> entries) {
    final triggerCounts = <String, int>{};
    
    for (final entry in entries) {
      if (entry.triggers != null) {
        for (final trigger in entry.triggers!) {
          triggerCounts[trigger] = (triggerCounts[trigger] ?? 0) + 1;
        }
      }
    }

    _topTriggers = triggerCounts.entries
        .map((e) => {'name': e.key, 'count': e.value})
        .toList()
      ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int))
      ..take(5).toList();
  }

  void _generateGoals() {
    _goals = [
      {
        'title': 'تتبع المزاج يومياً',
        'progress': (_trackingDays / 30 * 100).clamp(0, 100).round(),
      },
      {
        'title': 'تحسين متوسط المزاج',
        'progress': (_averageMood / 5 * 100).round(),
      },
      {
        'title': 'زيادة مستوى الطاقة',
        'progress': (_averageEnergy / 5 * 100).round(),
      },
      {
        'title': 'تحسين جودة النوم',
        'progress': (_averageSleep / 5 * 100).round(),
      },
    ];
  }

  void _generateAchievements() {
    _achievements = [];
    
    if (_trackingDays >= 7) {
      _achievements.add({
        'icon': Icons.calendar_today,
        'title': 'أسبوع من التتبع',
        'description': 'تتبعت مزاجك لمدة أسبوع كامل',
        'date': 'منذ يومين',
      });
    }
    
    if (_averageMood >= 4) {
      _achievements.add({
        'icon': Icons.mood,
        'title': 'مزاج إيجابي',
        'description': 'حافظت على مزاج إيجابي',
        'date': 'منذ 3 أيام',
      });
    }
    
    if (_trackingDays >= 30) {
      _achievements.add({
        'icon': Icons.star,
        'title': 'شهر من التتبع',
        'description': 'تتبعت مزاجك لمدة شهر كامل',
        'date': 'منذ أسبوع',
      });
    }
  }

  void _generateInsights(List<MoodEntry> entries) {
    _moodSummary = [];
    _improvements = [];
    _recommendations = [];

    // Mood Summary
    if (_averageMood >= 4) {
      _moodSummary.add('مزاجك العام إيجابي ومستقر');
    } else if (_averageMood >= 3) {
      _moodSummary.add('مزاجك متوسط مع تقلبات طفيفة');
    } else {
      _moodSummary.add('مزاجك يحتاج إلى تحسين');
    }

    _moodSummary.add('تتبعت مزاجك لمدة $_trackingDays يوم');
    _moodSummary.add('متوسط مستوى الطاقة: ${_averageEnergy.toStringAsFixed(1)}');

    // Improvements
    if (_averageMood > 3.5) {
      _improvements.add('تحسن ملحوظ في المزاج العام');
    }
    if (_averageEnergy > 3.5) {
      _improvements.add('زيادة في مستوى الطاقة');
    }
    if (_averageSleep > 3.5) {
      _improvements.add('تحسن في جودة النوم');
    }

    // Recommendations
    if (_averageMood < 3) {
      _recommendations.add('ممارسة تمارين التنفس والاسترخاء');
      _recommendations.add('التواصل مع مختص نفسي');
    }
    if (_averageEnergy < 3) {
      _recommendations.add('ممارسة الرياضة بانتظام');
      _recommendations.add('تحسين نظام النوم');
    }
    if (_topTriggers.isNotEmpty) {
      _recommendations.add('تجنب المحفزات الرئيسية: ${_topTriggers.first['name']}');
    }
    
    _recommendations.add('الاستمرار في تتبع المزاج يومياً');
    _recommendations.add('ممارسة التأمل والذهن الواعي');
  }

  void _resetAnalytics() {
    _averageMood = 0.0;
    _trackingDays = 0;
    _averageEnergy = 0.0;
    _averageSleep = 0.0;
    _moodDistribution = {};
    _topTriggers = [];
    _goals = [];
    _achievements = [];
    _moodSummary = [];
    _improvements = [];
    _recommendations = [];
  }

  String _getMoodText(int mood) {
    switch (mood) {
      case 5:
        return 'ممتاز';
      case 4:
        return 'جيد';
      case 3:
        return 'عادي';
      case 2:
        return 'سيء';
      case 1:
        return 'سيء جداً';
      default:
        return 'عادي';
    }
  }

  // Export functionality
  Future<void> exportToPDF() async {
    // TODO: Implement PDF export
    debugPrint('Exporting to PDF...');
  }

  Future<void> exportToExcel() async {
    // TODO: Implement Excel export
    debugPrint('Exporting to Excel...');
  }

  // Weekly comparison
  Map<String, double> getWeeklyComparison() {
    // TODO: Implement weekly comparison logic
    return {
      'thisWeek': _averageMood,
      'lastWeek': _averageMood - 0.5,
      'change': 0.5,
    };
  }

  // Mood patterns
  List<Map<String, dynamic>> getMoodPatterns() {
    // TODO: Implement mood pattern analysis
    return [
      {
        'pattern': 'أفضل في الصباح',
        'confidence': 85,
        'description': 'مزاجك يكون أفضل في ساعات الصباح الأولى',
      },
      {
        'pattern': 'تحسن في نهاية الأسبوع',
        'confidence': 72,
        'description': 'مزاجك يتحسن خلال عطلة نهاية الأسبوع',
      },
    ];
  }

  // Correlation analysis
  Map<String, double> getCorrelations() {
    // TODO: Implement correlation analysis
    return {
      'mood_energy': 0.75,
      'mood_sleep': 0.68,
      'energy_sleep': 0.82,
    };
  }
}