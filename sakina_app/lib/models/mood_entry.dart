class MoodEntry {
  final String id;
  final int mood; // 1-5 scale
  final String? note;
  final DateTime timestamp;
  final String userId;
  final List<String>? triggers;
  final List<String>? activities;
  final int? energyLevel; // 1-5 scale
  final int? anxietyLevel; // 1-5 scale
  final int? sleepQuality; // 1-5 scale

  MoodEntry({
    required this.id,
    required this.mood,
    this.note,
    required this.timestamp,
    required this.userId,
    this.triggers,
    this.activities,
    this.energyLevel,
    this.anxietyLevel,
    this.sleepQuality,
  });

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'],
      mood: json['mood'],
      note: json['note'],
      timestamp: DateTime.parse(json['timestamp']),
      userId: json['userId'],
      triggers: json['triggers'] != null 
          ? List<String>.from(json['triggers']) 
          : null,
      activities: json['activities'] != null 
          ? List<String>.from(json['activities']) 
          : null,
      energyLevel: json['energyLevel'],
      anxietyLevel: json['anxietyLevel'],
      sleepQuality: json['sleepQuality'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mood': mood,
      'note': note,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'triggers': triggers,
      'activities': activities,
      'energyLevel': energyLevel,
      'anxietyLevel': anxietyLevel,
      'sleepQuality': sleepQuality,
    };
  }

  MoodEntry copyWith({
    String? id,
    int? mood,
    String? note,
    DateTime? timestamp,
    String? userId,
    List<String>? triggers,
    List<String>? activities,
    int? energyLevel,
    int? anxietyLevel,
    int? sleepQuality,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      mood: mood ?? this.mood,
      note: note ?? this.note,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
      triggers: triggers ?? this.triggers,
      activities: activities ?? this.activities,
      energyLevel: energyLevel ?? this.energyLevel,
      anxietyLevel: anxietyLevel ?? this.anxietyLevel,
      sleepQuality: sleepQuality ?? this.sleepQuality,
    );
  }

  String get moodText {
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
        return 'غير محدد';
    }
  }

  String get moodEmoji {
    switch (mood) {
      case 5:
        return '😊';
      case 4:
        return '🙂';
      case 3:
        return '😐';
      case 2:
        return '😔';
      case 1:
        return '😢';
      default:
        return '❓';
    }
  }
} 