/// Enum representing mood levels on a 1-5 scale
enum MoodType {
  veryBad(1),
  bad(2),
  neutral(3),
  good(4),
  excellent(5);

  final int numericValue;
  const MoodType(this.numericValue);

  /// Convert to double for calculations
  double toDouble() => numericValue.toDouble();

  /// Convert to int for display/storage
  int toInt() => numericValue;

  /// Create MoodType from numeric value (1-5)
  static MoodType fromNumeric(int value) {
    switch (value) {
      case 1:
        return MoodType.veryBad;
      case 2:
        return MoodType.bad;
      case 3:
        return MoodType.neutral;
      case 4:
        return MoodType.good;
      case 5:
        return MoodType.excellent;
      default:
        throw ArgumentError('Mood value must be between 1 and 5, got: $value');
    }
  }

  /// Comparison operators
  bool operator >(MoodType other) => numericValue > other.numericValue;
  bool operator <(MoodType other) => numericValue < other.numericValue;
  bool operator >=(MoodType other) => numericValue >= other.numericValue;
  bool operator <=(MoodType other) => numericValue <= other.numericValue;

  /// Arithmetic helpers returning MoodType
  MoodType add(int value) {
    final newValue = (numericValue + value).clamp(1, 5);
    return MoodType.fromNumeric(newValue);
  }

  MoodType subtract(int value) {
    final newValue = (numericValue - value).clamp(1, 5);
    return MoodType.fromNumeric(newValue);
  }
}

class MoodEntry {
  final String id;
  final MoodType mood;
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

  // Alias getters for backward compatibility
  DateTime get date => timestamp;
  int? get sleep => sleepQuality;
  int? get energy => energyLevel;
  int? get stress => anxietyLevel;

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    // Handle both legacy int (1-5) and new enum string formats
    MoodType parsedMood;
    final moodValue = json['mood'];

    if (moodValue is int) {
      // Legacy format: int 1-5
      parsedMood = MoodType.fromNumeric(moodValue);
    } else if (moodValue is String) {
      // New format: enum name
      parsedMood = MoodType.values.firstWhere(
        (e) => e.name == moodValue,
        orElse: () => MoodType.neutral,
      );
    } else {
      throw ArgumentError('Invalid mood value type: ${moodValue.runtimeType}');
    }

    return MoodEntry(
      id: json['id'],
      mood: parsedMood,
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
      'mood': mood.name, // Serialize as enum name for forward compatibility
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
    MoodType? mood,
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
      case MoodType.excellent:
        return 'ممتاز';
      case MoodType.good:
        return 'جيد';
      case MoodType.neutral:
        return 'عادي';
      case MoodType.bad:
        return 'سيء';
      case MoodType.veryBad:
        return 'سيء جداً';
    }
  }

  String get moodEmoji {
    switch (mood) {
      case MoodType.excellent:
        return '😊';
      case MoodType.good:
        return '🙂';
      case MoodType.neutral:
        return '😐';
      case MoodType.bad:
        return '😔';
      case MoodType.veryBad:
        return '😢';
    }
  }
} 