import 'package:flutter/material.dart';

/// نموذج مدخل المزاج
class MoodEntry {
  final String id;
  final String userId;
  final MoodType mood;
  final int intensity; // من 1 إلى 10
  final String? notes;
  final List<String> factors;
  final DateTime timestamp;
  final Map<String, dynamic>? additionalData;
  
  MoodEntry({
    required this.id,
    required this.userId,
    required this.mood,
    required this.intensity,
    this.notes,
    this.factors = const [],
    required this.timestamp,
    this.additionalData,
  });
  
  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'mood': mood.name,
      'intensity': intensity,
      'notes': notes,
      'factors': factors,
      'timestamp': timestamp.toIso8601String(),
      'additionalData': additionalData,
    };
  }
  
  /// إنشاء من JSON
  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'],
      userId: json['userId'],
      mood: MoodType.values.firstWhere(
        (e) => e.name == json['mood'],
        orElse: () => MoodType.neutral,
      ),
      intensity: json['intensity'],
      notes: json['notes'],
      factors: List<String>.from(json['factors'] ?? []),
      timestamp: DateTime.parse(json['timestamp']),
      additionalData: json['additionalData'],
    );
  }
  
  /// نسخ مع تعديل
  MoodEntry copyWith({
    String? id,
    String? userId,
    MoodType? mood,
    int? intensity,
    String? notes,
    List<String>? factors,
    DateTime? timestamp,
    Map<String, dynamic>? additionalData,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mood: mood ?? this.mood,
      intensity: intensity ?? this.intensity,
      notes: notes ?? this.notes,
      factors: factors ?? this.factors,
      timestamp: timestamp ?? this.timestamp,
      additionalData: additionalData ?? this.additionalData,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MoodEntry && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}

/// أنواع المزاج
enum MoodType {
  veryHappy,
  happy,
  neutral,
  sad,
  verySad,
  angry,
  anxious,
  excited,
  calm,
  stressed,
}

/// امتداد لأنواع المزاج
extension MoodTypeExtension on MoodType {
  /// الاسم بالعربية
  String get arabicName {
    switch (this) {
      case MoodType.veryHappy:
        return 'سعيد جداً';
      case MoodType.happy:
        return 'سعيد';
      case MoodType.neutral:
        return 'محايد';
      case MoodType.sad:
        return 'حزين';
      case MoodType.verySad:
        return 'حزين جداً';
      case MoodType.angry:
        return 'غاضب';
      case MoodType.anxious:
        return 'قلق';
      case MoodType.excited:
        return 'متحمس';
      case MoodType.calm:
        return 'هادئ';
      case MoodType.stressed:
        return 'متوتر';
    }
  }
  
  /// الأيقونة
  IconData get icon {
    switch (this) {
      case MoodType.veryHappy:
        return Icons.sentiment_very_satisfied;
      case MoodType.happy:
        return Icons.sentiment_satisfied;
      case MoodType.neutral:
        return Icons.sentiment_neutral;
      case MoodType.sad:
        return Icons.sentiment_dissatisfied;
      case MoodType.verySad:
        return Icons.sentiment_very_dissatisfied;
      case MoodType.angry:
        return Icons.mood_bad;
      case MoodType.anxious:
        return Icons.psychology;
      case MoodType.excited:
        return Icons.celebration;
      case MoodType.calm:
        return Icons.self_improvement;
      case MoodType.stressed:
        return Icons.stress_management;
    }
  }
  
  /// اللون
  Color get color {
    switch (this) {
      case MoodType.veryHappy:
        return Colors.green.shade600;
      case MoodType.happy:
        return Colors.green.shade400;
      case MoodType.neutral:
        return Colors.grey.shade500;
      case MoodType.sad:
        return Colors.blue.shade400;
      case MoodType.verySad:
        return Colors.blue.shade600;
      case MoodType.angry:
        return Colors.red.shade500;
      case MoodType.anxious:
        return Colors.orange.shade500;
      case MoodType.excited:
        return Colors.purple.shade400;
      case MoodType.calm:
        return Colors.teal.shade400;
      case MoodType.stressed:
        return Colors.amber.shade600;
    }
  }
  
  /// القيمة الرقمية (للإحصائيات)
  double get numericValue {
    switch (this) {
      case MoodType.veryHappy:
        return 5.0;
      case MoodType.happy:
        return 4.0;
      case MoodType.excited:
        return 4.5;
      case MoodType.calm:
        return 3.5;
      case MoodType.neutral:
        return 3.0;
      case MoodType.anxious:
        return 2.5;
      case MoodType.stressed:
        return 2.0;
      case MoodType.sad:
        return 2.0;
      case MoodType.angry:
        return 1.5;
      case MoodType.verySad:
        return 1.0;
    }
  }
}

/// العوامل المؤثرة على المزاج
class MoodFactor {
  static const List<String> commonFactors = [
    'النوم',
    'الطعام',
    'التمارين',
    'العمل',
    'العائلة',
    'الأصدقاء',
    'الطقس',
    'الصحة',
    'المال',
    'الدراسة',
    'العلاقات',
    'الهوايات',
    'السفر',
    'الأخبار',
    'وسائل التواصل',
  ];
  
  static const List<String> positiveFactors = [
    'قضاء وقت مع الأحباء',
    'ممارسة الرياضة',
    'الاستماع للموسيقى',
    'القراءة',
    'التأمل',
    'الطبيعة',
    'الإنجازات',
    'المساعدة للآخرين',
    'التعلم الجديد',
    'الراحة',
  ];
  
  static const List<String> negativeFactors = [
    'قلة النوم',
    'ضغط العمل',
    'المشاكل المالية',
    'الخلافات',
    'المرض',
    'الوحدة',
    'القلق من المستقبل',
    'الذكريات السيئة',
    'الإرهاق',
    'عدم الثقة بالنفس',
  ];
}

/// إحصائيات المزاج
class MoodStatistics {
  final Map<MoodType, int> moodCounts;
  final double averageMood;
  final MoodType mostCommonMood;
  final List<String> topFactors;
  final DateTime startDate;
  final DateTime endDate;
  
  MoodStatistics({
    required this.moodCounts,
    required this.averageMood,
    required this.mostCommonMood,
    required this.topFactors,
    required this.startDate,
    required this.endDate,
  });
  
  /// حساب الإحصائيات من قائمة المدخلات
  factory MoodStatistics.fromEntries(List<MoodEntry> entries) {
    if (entries.isEmpty) {
      return MoodStatistics(
        moodCounts: {},
        averageMood: 3.0,
        mostCommonMood: MoodType.neutral,
        topFactors: [],
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      );
    }
    
    final moodCounts = <MoodType, int>{};
    final factorCounts = <String, int>{};
    double totalMoodValue = 0;
    
    for (final entry in entries) {
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
      totalMoodValue += entry.mood.numericValue;
      
      for (final factor in entry.factors) {
        factorCounts[factor] = (factorCounts[factor] ?? 0) + 1;
      }
    }
    
    final averageMood = totalMoodValue / entries.length;
    final mostCommonMood = moodCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    final topFactors = factorCounts.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value))
        ..take(5);
    
    entries.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    return MoodStatistics(
      moodCounts: moodCounts,
      averageMood: averageMood,
      mostCommonMood: mostCommonMood,
      topFactors: topFactors.map((e) => e.key).toList(),
      startDate: entries.first.timestamp,
      endDate: entries.last.timestamp,
    );
  }
}