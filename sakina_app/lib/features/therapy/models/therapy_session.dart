import 'package:flutter/material.dart';

/// نموذج جلسة العلاج
class TherapySession {
  final String id;
  final String userId;
  final String? therapistId;
  final String title;
  final String description;
  final SessionType type;
  final SessionStatus status;
  final DateTime scheduledDate;
  final Duration duration;
  final String? notes;
  final List<String> goals;
  final List<String> techniques;
  final int? rating;
  final String? feedback;
  final Map<String, dynamic>? additionalData;
  final DateTime createdAt;
  final DateTime? completedAt;
  
  TherapySession({
    required this.id,
    required this.userId,
    this.therapistId,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.scheduledDate,
    required this.duration,
    this.notes,
    this.goals = const [],
    this.techniques = const [],
    this.rating,
    this.feedback,
    this.additionalData,
    required this.createdAt,
    this.completedAt,
  });
  
  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'therapistId': therapistId,
      'title': title,
      'description': description,
      'type': type.name,
      'status': status.name,
      'scheduledDate': scheduledDate.toIso8601String(),
      'duration': duration.inMinutes,
      'notes': notes,
      'goals': goals,
      'techniques': techniques,
      'rating': rating,
      'feedback': feedback,
      'additionalData': additionalData,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }
  
  /// إنشاء من JSON
  factory TherapySession.fromJson(Map<String, dynamic> json) {
    return TherapySession(
      id: json['id'],
      userId: json['userId'],
      therapistId: json['therapistId'],
      title: json['title'],
      description: json['description'],
      type: SessionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SessionType.individual,
      ),
      status: SessionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SessionStatus.scheduled,
      ),
      scheduledDate: DateTime.parse(json['scheduledDate']),
      duration: Duration(minutes: json['duration']),
      notes: json['notes'],
      goals: List<String>.from(json['goals'] ?? []),
      techniques: List<String>.from(json['techniques'] ?? []),
      rating: json['rating'],
      feedback: json['feedback'],
      additionalData: json['additionalData'],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
    );
  }
  
  /// نسخ مع تعديل
  TherapySession copyWith({
    String? id,
    String? userId,
    String? therapistId,
    String? title,
    String? description,
    SessionType? type,
    SessionStatus? status,
    DateTime? scheduledDate,
    Duration? duration,
    String? notes,
    List<String>? goals,
    List<String>? techniques,
    int? rating,
    String? feedback,
    Map<String, dynamic>? additionalData,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return TherapySession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      therapistId: therapistId ?? this.therapistId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      duration: duration ?? this.duration,
      notes: notes ?? this.notes,
      goals: goals ?? this.goals,
      techniques: techniques ?? this.techniques,
      rating: rating ?? this.rating,
      feedback: feedback ?? this.feedback,
      additionalData: additionalData ?? this.additionalData,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TherapySession && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}

/// أنواع جلسات العلاج
enum SessionType {
  individual,
  group,
  family,
  couple,
  online,
  assessment,
  followUp,
}

/// امتداد لأنواع الجلسات
extension SessionTypeExtension on SessionType {
  /// الاسم بالعربية
  String get arabicName {
    switch (this) {
      case SessionType.individual:
        return 'جلسة فردية';
      case SessionType.group:
        return 'جلسة جماعية';
      case SessionType.family:
        return 'جلسة عائلية';
      case SessionType.couple:
        return 'جلسة أزواج';
      case SessionType.online:
        return 'جلسة عبر الإنترنت';
      case SessionType.assessment:
        return 'جلسة تقييم';
      case SessionType.followUp:
        return 'جلسة متابعة';
    }
  }
  
  /// الأيقونة
  IconData get icon {
    switch (this) {
      case SessionType.individual:
        return Icons.person;
      case SessionType.group:
        return Icons.group;
      case SessionType.family:
        return Icons.family_restroom;
      case SessionType.couple:
        return Icons.favorite;
      case SessionType.online:
        return Icons.video_call;
      case SessionType.assessment:
        return Icons.assessment;
      case SessionType.followUp:
        return Icons.follow_the_signs;
    }
  }
  
  /// اللون
  Color get color {
    switch (this) {
      case SessionType.individual:
        return Colors.blue;
      case SessionType.group:
        return Colors.green;
      case SessionType.family:
        return Colors.orange;
      case SessionType.couple:
        return Colors.pink;
      case SessionType.online:
        return Colors.purple;
      case SessionType.assessment:
        return Colors.teal;
      case SessionType.followUp:
        return Colors.amber;
    }
  }
}

/// حالات الجلسة
enum SessionStatus {
  scheduled,
  inProgress,
  completed,
  cancelled,
  rescheduled,
  noShow,
}

/// امتداد لحالات الجلسة
extension SessionStatusExtension on SessionStatus {
  /// الاسم بالعربية
  String get arabicName {
    switch (this) {
      case SessionStatus.scheduled:
        return 'مجدولة';
      case SessionStatus.inProgress:
        return 'جارية';
      case SessionStatus.completed:
        return 'مكتملة';
      case SessionStatus.cancelled:
        return 'ملغية';
      case SessionStatus.rescheduled:
        return 'معاد جدولتها';
      case SessionStatus.noShow:
        return 'لم يحضر';
    }
  }
  
  /// اللون
  Color get color {
    switch (this) {
      case SessionStatus.scheduled:
        return Colors.blue;
      case SessionStatus.inProgress:
        return Colors.orange;
      case SessionStatus.completed:
        return Colors.green;
      case SessionStatus.cancelled:
        return Colors.red;
      case SessionStatus.rescheduled:
        return Colors.amber;
      case SessionStatus.noShow:
        return Colors.grey;
    }
  }
  
  /// الأيقونة
  IconData get icon {
    switch (this) {
      case SessionStatus.scheduled:
        return Icons.schedule;
      case SessionStatus.inProgress:
        return Icons.play_circle;
      case SessionStatus.completed:
        return Icons.check_circle;
      case SessionStatus.cancelled:
        return Icons.cancel;
      case SessionStatus.rescheduled:
        return Icons.update;
      case SessionStatus.noShow:
        return Icons.person_off;
    }
  }
}

/// تقنيات العلاج
class TherapyTechnique {
  static const List<String> commonTechniques = [
    'العلاج المعرفي السلوكي',
    'العلاج النفسي التحليلي',
    'العلاج الجماعي',
    'العلاج الأسري',
    'العلاج بالفن',
    'العلاج بالموسيقى',
    'العلاج بالحركة',
    'التأمل الذهني',
    'تقنيات الاسترخاء',
    'العلاج بالتعرض',
    'إعادة البناء المعرفي',
    'حل المشكلات',
    'التدريب على المهارات الاجتماعية',
    'إدارة الغضب',
    'تقنيات التأقلم',
  ];
}

/// أهداف العلاج
class TherapyGoal {
  static const List<String> commonGoals = [
    'تحسين المزاج',
    'تقليل القلق',
    'إدارة التوتر',
    'تحسين العلاقات',
    'زيادة الثقة بالنفس',
    'تطوير مهارات التواصل',
    'التعامل مع الصدمات',
    'إدارة الغضب',
    'تحسين النوم',
    'التغلب على الإدمان',
    'تطوير آليات التأقلم',
    'تحسين الأداء الأكاديمي',
    'تحسين الأداء المهني',
    'التعامل مع الحزن',
    'بناء المرونة النفسية',
  ];
}

/// إحصائيات جلسات العلاج
class TherapyStatistics {
  final int totalSessions;
  final int completedSessions;
  final int cancelledSessions;
  final double averageRating;
  final Duration totalDuration;
  final Map<SessionType, int> sessionsByType;
  final Map<String, int> techniqueUsage;
  final DateTime firstSession;
  final DateTime? lastSession;
  
  TherapyStatistics({
    required this.totalSessions,
    required this.completedSessions,
    required this.cancelledSessions,
    required this.averageRating,
    required this.totalDuration,
    required this.sessionsByType,
    required this.techniqueUsage,
    required this.firstSession,
    this.lastSession,
  });
  
  /// حساب الإحصائيات من قائمة الجلسات
  factory TherapyStatistics.fromSessions(List<TherapySession> sessions) {
    if (sessions.isEmpty) {
      return TherapyStatistics(
        totalSessions: 0,
        completedSessions: 0,
        cancelledSessions: 0,
        averageRating: 0.0,
        totalDuration: Duration.zero,
        sessionsByType: {},
        techniqueUsage: {},
        firstSession: DateTime.now(),
        lastSession: null,
      );
    }
    
    final completedSessions = sessions
        .where((s) => s.status == SessionStatus.completed)
        .length;
    
    final cancelledSessions = sessions
        .where((s) => s.status == SessionStatus.cancelled)
        .length;
    
    final ratingsSum = sessions
        .where((s) => s.rating != null)
        .fold<double>(0, (sum, s) => sum + s.rating!);
    
    final ratingsCount = sessions
        .where((s) => s.rating != null)
        .length;
    
    final averageRating = ratingsCount > 0 ? ratingsSum / ratingsCount : 0.0;
    
    final totalDuration = sessions.fold<Duration>(
      Duration.zero,
      (sum, s) => sum + s.duration,
    );
    
    final sessionsByType = <SessionType, int>{};
    final techniqueUsage = <String, int>{};
    
    for (final session in sessions) {
      sessionsByType[session.type] = (sessionsByType[session.type] ?? 0) + 1;
      
      for (final technique in session.techniques) {
        techniqueUsage[technique] = (techniqueUsage[technique] ?? 0) + 1;
      }
    }
    
    sessions.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    
    return TherapyStatistics(
      totalSessions: sessions.length,
      completedSessions: completedSessions,
      cancelledSessions: cancelledSessions,
      averageRating: averageRating,
      totalDuration: totalDuration,
      sessionsByType: sessionsByType,
      techniqueUsage: techniqueUsage,
      firstSession: sessions.first.scheduledDate,
      lastSession: sessions.isNotEmpty ? sessions.last.scheduledDate : null,
    );
  }
  
  /// معدل الحضور
  double get attendanceRate {
    if (totalSessions == 0) return 0.0;
    return completedSessions / totalSessions;
  }
  
  /// معدل الإلغاء
  double get cancellationRate {
    if (totalSessions == 0) return 0.0;
    return cancelledSessions / totalSessions;
  }
}