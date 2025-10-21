
enum TherapyProgramType {
  cbt, // Cognitive Behavioral Therapy
  mindfulness,
  anxiety,
  depression,
  stress,
  relationships,
  selfEsteem,
  sleep,
  addiction,
  trauma,
}

enum TherapyProgramLevel {
  beginner,
  intermediate,
  advanced,
}

enum TherapyProgramStatus {
  notStarted,
  inProgress,
  completed,
  paused,
}

enum ExerciseType {
  reading,
  writing,
  meditation,
  breathing,
  behavioral,
  cognitive,
  mindfulness,
  reflection,
  journaling,
  relaxation,
  physical,
}

class TherapyProgramModel {
  final String id;
  final String title;
  final String description;
  final String detailedDescription;
  final TherapyProgramType type;
  final TherapyProgramLevel level;
  final int durationWeeks;
  final int totalSessions;
  final List<String> objectives;
  final List<String> benefits;
  final List<String> requirements;
  final String imageUrl;
  final bool isPremium;
  final double rating;
  final int reviewsCount;
  final List<TherapySessionModel> sessions;
  final TherapyProgramStatus status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int currentSessionIndex;
  final double progress;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TherapyProgramModel({
    required this.id,
    required this.title,
    required this.description,
    required this.detailedDescription,
    required this.type,
    required this.level,
    required this.durationWeeks,
    required this.totalSessions,
    required this.objectives,
    required this.benefits,
    this.requirements = const [],
    required this.imageUrl,
    required this.isPremium,
    required this.rating,
    required this.reviewsCount,
    required this.sessions,
    this.status = TherapyProgramStatus.notStarted,
    this.startedAt,
    this.completedAt,
    this.currentSessionIndex = 0,
    this.progress = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TherapyProgramModel.fromJson(Map<String, dynamic> json) {
    return TherapyProgramModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      detailedDescription: json['detailedDescription'] as String,
      type: TherapyProgramType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TherapyProgramType.cbt,
      ),
      level: TherapyProgramLevel.values.firstWhere(
        (e) => e.name == json['level'],
        orElse: () => TherapyProgramLevel.beginner,
      ),
      durationWeeks: json['durationWeeks'] as int,
      totalSessions: json['totalSessions'] as int,
      objectives: List<String>.from(json['objectives'] as List),
      benefits: List<String>.from(json['benefits'] as List),
      requirements: List<String>.from((json['requirements'] ?? const []) as List),
      imageUrl: json['imageUrl'] as String,
      isPremium: json['isPremium'] as bool,
      rating: (json['rating'] as num).toDouble(),
      reviewsCount: json['reviewsCount'] as int,
      sessions: (json['sessions'] as List)
          .map((session) => TherapySessionModel.fromJson(session))
          .toList(),
      status: TherapyProgramStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TherapyProgramStatus.notStarted,
      ),
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      currentSessionIndex: json['currentSessionIndex'] as int? ?? 0,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'detailedDescription': detailedDescription,
      'type': type.name,
      'level': level.name,
      'durationWeeks': durationWeeks,
      'totalSessions': totalSessions,
      'objectives': objectives,
      'benefits': benefits,
      'requirements': requirements,
      'imageUrl': imageUrl,
      'isPremium': isPremium,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'sessions': sessions.map((session) => session.toJson()).toList(),
      'status': status.name,
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'currentSessionIndex': currentSessionIndex,
      'progress': progress,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  TherapyProgramModel copyWith({
    String? id,
    String? title,
    String? description,
    String? detailedDescription,
    TherapyProgramType? type,
    TherapyProgramLevel? level,
    int? durationWeeks,
    int? totalSessions,
    List<String>? objectives,
    List<String>? benefits,
    List<String>? requirements,
    String? imageUrl,
    bool? isPremium,
    double? rating,
    int? reviewsCount,
    List<TherapySessionModel>? sessions,
    TherapyProgramStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
    int? currentSessionIndex,
    double? progress,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TherapyProgramModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      detailedDescription: detailedDescription ?? this.detailedDescription,
      type: type ?? this.type,
      level: level ?? this.level,
      durationWeeks: durationWeeks ?? this.durationWeeks,
      totalSessions: totalSessions ?? this.totalSessions,
      objectives: objectives ?? this.objectives,
      benefits: benefits ?? this.benefits,
      requirements: requirements ?? this.requirements,
      imageUrl: imageUrl ?? this.imageUrl,
      isPremium: isPremium ?? this.isPremium,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      sessions: sessions ?? this.sessions,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      currentSessionIndex: currentSessionIndex ?? this.currentSessionIndex,
      progress: progress ?? this.progress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TherapyProgramModel &&
        other.id == id &&
        other.title == title &&
        other.type == type &&
        other.status == status;
  }

  @override
  int get hashCode {
    return Object.hash(id, title, type, status);
  }

  @override
  String toString() {
    return 'TherapyProgramModel(id: $id, title: $title, type: $type, status: $status, progress: $progress)';
  }
}

class TherapySessionModel {
  final String id;
  final String programId;
  final int sessionNumber;
  final String title;
  final String description;
  final String content;
  final List<TherapyExerciseModel> exercises;
  final Duration estimatedDuration;
  final List<String> learningObjectives;
  final String? videoUrl;
  final String? audioUrl;
  final List<String> resources;
  final bool isCompleted;
  final DateTime? completedAt;
  final double? userRating;
  final String? userNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TherapySessionModel({
    required this.id,
    required this.programId,
    required this.sessionNumber,
    required this.title,
    required this.description,
    required this.content,
    required this.exercises,
    required this.estimatedDuration,
    required this.learningObjectives,
    this.videoUrl,
    this.audioUrl,
    required this.resources,
    this.isCompleted = false,
    this.completedAt,
    this.userRating,
    this.userNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  int get durationMinutes => estimatedDuration.inMinutes;

  factory TherapySessionModel.fromJson(Map<String, dynamic> json) {
    return TherapySessionModel(
      id: json['id'] as String,
      programId: json['programId'] as String,
      sessionNumber: json['sessionNumber'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      content: json['content'] as String,
      exercises: (json['exercises'] as List)
          .map((exercise) => TherapyExerciseModel.fromJson(exercise))
          .toList(),
      estimatedDuration: Duration(
        minutes: json['estimatedDurationMinutes'] as int,
      ),
      learningObjectives: List<String>.from(json['learningObjectives'] as List),
      videoUrl: json['videoUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
      resources: List<String>.from(json['resources'] as List),
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      userRating: (json['userRating'] as num?)?.toDouble(),
      userNotes: json['userNotes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'programId': programId,
      'sessionNumber': sessionNumber,
      'title': title,
      'description': description,
      'content': content,
      'exercises': exercises.map((exercise) => exercise.toJson()).toList(),
      'estimatedDurationMinutes': estimatedDuration.inMinutes,
      'learningObjectives': learningObjectives,
      'videoUrl': videoUrl,
      'audioUrl': audioUrl,
      'resources': resources,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'userRating': userRating,
      'userNotes': userNotes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  TherapySessionModel copyWith({
    String? id,
    String? programId,
    int? sessionNumber,
    String? title,
    String? description,
    String? content,
    List<TherapyExerciseModel>? exercises,
    Duration? estimatedDuration,
    List<String>? learningObjectives,
    String? videoUrl,
    String? audioUrl,
    List<String>? resources,
    bool? isCompleted,
    DateTime? completedAt,
    double? userRating,
    String? userNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TherapySessionModel(
      id: id ?? this.id,
      programId: programId ?? this.programId,
      sessionNumber: sessionNumber ?? this.sessionNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      exercises: exercises ?? this.exercises,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      learningObjectives: learningObjectives ?? this.learningObjectives,
      videoUrl: videoUrl ?? this.videoUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      resources: resources ?? this.resources,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      userRating: userRating ?? this.userRating,
      userNotes: userNotes ?? this.userNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class TherapyExerciseModel {
  final String id;
  final String sessionId;
  final String title;
  final String description;
  final String instructions;
  final ExerciseType type;
  final Duration estimatedDuration;
  final List<String> questions;
  final Map<String, dynamic>? exerciseData;
  final bool isCompleted;
  final DateTime? completedAt;
  final Map<String, dynamic>? userResponse;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TherapyExerciseModel({
    required this.id,
    required this.sessionId,
    required this.title,
    required this.description,
    required this.instructions,
    required this.type,
    required this.estimatedDuration,
    required this.questions,
    this.exerciseData,
    this.isCompleted = false,
    this.completedAt,
    this.userResponse,
    required this.createdAt,
    required this.updatedAt,
  });

  int get durationMinutes => estimatedDuration.inMinutes;

  factory TherapyExerciseModel.fromJson(Map<String, dynamic> json) {
    return TherapyExerciseModel(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      instructions: json['instructions'] as String,
      type: ExerciseType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ExerciseType.reflection,
      ),
      estimatedDuration: Duration(
        minutes: json['estimatedDurationMinutes'] as int,
      ),
      questions: List<String>.from(json['questions'] as List),
      exerciseData: json['exerciseData'] as Map<String, dynamic>?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      userResponse: json['userResponse'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'title': title,
      'description': description,
      'instructions': instructions,
      'type': type.name,
      'estimatedDurationMinutes': estimatedDuration.inMinutes,
      'questions': questions,
      'exerciseData': exerciseData,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'userResponse': userResponse,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  TherapyExerciseModel copyWith({
    String? id,
    String? sessionId,
    String? title,
    String? description,
    String? instructions,
    ExerciseType? type,
    Duration? estimatedDuration,
    List<String>? questions,
    Map<String, dynamic>? exerciseData,
    bool? isCompleted,
    DateTime? completedAt,
    Map<String, dynamic>? userResponse,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TherapyExerciseModel(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      title: title ?? this.title,
      description: description ?? this.description,
      instructions: instructions ?? this.instructions,
      type: type ?? this.type,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      questions: questions ?? this.questions,
      exerciseData: exerciseData ?? this.exerciseData,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      userResponse: userResponse ?? this.userResponse,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class TherapyAssessmentModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final List<AssessmentQuestionModel> questions;
  final Map<String, dynamic>? results;
  final List<String> recommendedPrograms;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TherapyAssessmentModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.questions,
    this.results,
    required this.recommendedPrograms,
    this.isCompleted = false,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TherapyAssessmentModel.fromJson(Map<String, dynamic> json) {
    return TherapyAssessmentModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      questions: (json['questions'] as List)
          .map((question) => AssessmentQuestionModel.fromJson(question))
          .toList(),
      results: json['results'] as Map<String, dynamic>?,
      recommendedPrograms: List<String>.from(json['recommendedPrograms'] as List),
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'questions': questions.map((question) => question.toJson()).toList(),
      'results': results,
      'recommendedPrograms': recommendedPrograms,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class AssessmentQuestionModel {
  final String id;
  final String question;
  final String type; // 'multiple_choice', 'scale', 'text', 'yes_no'
  final List<String>? options;
  final int? minValue;
  final int? maxValue;
  final bool isRequired;
  final String? userAnswer;

  const AssessmentQuestionModel({
    required this.id,
    required this.question,
    required this.type,
    this.options,
    this.minValue,
    this.maxValue,
    this.isRequired = true,
    this.userAnswer,
  });

  factory AssessmentQuestionModel.fromJson(Map<String, dynamic> json) {
    return AssessmentQuestionModel(
      id: json['id'] as String,
      question: json['question'] as String,
      type: json['type'] as String,
      options: json['options'] != null
          ? List<String>.from(json['options'] as List)
          : null,
      minValue: json['minValue'] as int?,
      maxValue: json['maxValue'] as int?,
      isRequired: json['isRequired'] as bool? ?? true,
      userAnswer: json['userAnswer'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'type': type,
      'options': options,
      'minValue': minValue,
      'maxValue': maxValue,
      'isRequired': isRequired,
      'userAnswer': userAnswer,
    };
  }

  AssessmentQuestionModel copyWith({
    String? id,
    String? question,
    String? type,
    List<String>? options,
    int? minValue,
    int? maxValue,
    bool? isRequired,
    String? userAnswer,
  }) {
    return AssessmentQuestionModel(
      id: id ?? this.id,
      question: question ?? this.question,
      type: type ?? this.type,
      options: options ?? this.options,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      isRequired: isRequired ?? this.isRequired,
      userAnswer: userAnswer ?? this.userAnswer,
    );
  }
}