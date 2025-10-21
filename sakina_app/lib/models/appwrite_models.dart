// نماذج البيانات للعمل مع Appwrite
// Models for working with Appwrite database

import 'package:appwrite/models.dart';

// نموذج المستخدم
class UserModel {
  final String id;
  final String userId;
  final String name;
  final String email;
  final int? age;
  final String? gender;
  final String? profilePicture;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    this.age,
    this.gender,
    this.profilePicture,
    required this.createdAt,
    required this.updatedAt,
  });

  // تحويل من Document إلى UserModel
  factory UserModel.fromDocument(Document doc) {
    return UserModel(
      id: doc.$id,
      userId: doc.data['userId'] ?? '',
      name: doc.data['name'] ?? '',
      email: doc.data['email'] ?? '',
      age: doc.data['age'],
      gender: doc.data['gender'],
      profilePicture: doc.data['profilePicture'],
      createdAt: DateTime.parse(doc.data['createdAt']),
      updatedAt: DateTime.parse(doc.data['updatedAt']),
    );
  }

  // تحويل إلى Map للإرسال إلى قاعدة البيانات
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'age': age,
      'gender': gender,
      'profilePicture': profilePicture,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // نسخ مع تعديل
  UserModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    int? age,
    String? gender,
    String? profilePicture,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      profilePicture: profilePicture ?? this.profilePicture,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// نموذج مدخل المزاج
class MoodEntryModel {
  final String id;
  final String userId;
  final String mood;
  final int intensity;
  final String? notes;
  final DateTime date;
  final DateTime createdAt;

  MoodEntryModel({
    required this.id,
    required this.userId,
    required this.mood,
    required this.intensity,
    this.notes,
    required this.date,
    required this.createdAt,
  });

  factory MoodEntryModel.fromDocument(Document doc) {
    return MoodEntryModel(
      id: doc.$id,
      userId: doc.data['userId'] ?? '',
      mood: doc.data['mood'] ?? '',
      intensity: doc.data['intensity'] ?? 1,
      notes: doc.data['notes'],
      date: DateTime.parse(doc.data['date']),
      createdAt: DateTime.parse(doc.data['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'mood': mood,
      'intensity': intensity,
      'notes': notes,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  MoodEntryModel copyWith({
    String? id,
    String? userId,
    String? mood,
    int? intensity,
    String? notes,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return MoodEntryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mood: mood ?? this.mood,
      intensity: intensity ?? this.intensity,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// نموذج جلسة التأمل
class MeditationSessionModel {
  final String id;
  final String userId;
  final String type;
  final int duration; // بالثواني
  final bool completed;
  final int? rating;
  final DateTime date;
  final DateTime createdAt;

  MeditationSessionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.duration,
    required this.completed,
    this.rating,
    required this.date,
    required this.createdAt,
  });

  factory MeditationSessionModel.fromDocument(Document doc) {
    return MeditationSessionModel(
      id: doc.$id,
      userId: doc.data['userId'] ?? '',
      type: doc.data['type'] ?? '',
      duration: doc.data['duration'] ?? 0,
      completed: doc.data['completed'] ?? false,
      rating: doc.data['rating'],
      date: DateTime.parse(doc.data['date']),
      createdAt: DateTime.parse(doc.data['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type,
      'duration': duration,
      'completed': completed,
      'rating': rating,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  MeditationSessionModel copyWith({
    String? id,
    String? userId,
    String? type,
    int? duration,
    bool? completed,
    int? rating,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return MeditationSessionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      completed: completed ?? this.completed,
      rating: rating ?? this.rating,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// نموذج مدخل المفكرة
class JournalEntryModel {
  final String id;
  final String userId;
  final String title;
  final String content;
  final bool isPrivate;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  JournalEntryModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.isPrivate,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JournalEntryModel.fromDocument(Document doc) {
    return JournalEntryModel(
      id: doc.$id,
      userId: doc.data['userId'] ?? '',
      title: doc.data['title'] ?? '',
      content: doc.data['content'] ?? '',
      isPrivate: doc.data['isPrivate'] ?? true,
      date: DateTime.parse(doc.data['date']),
      createdAt: DateTime.parse(doc.data['createdAt']),
      updatedAt: DateTime.parse(doc.data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'content': content,
      'isPrivate': isPrivate,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  JournalEntryModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    bool? isPrivate,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JournalEntryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      isPrivate: isPrivate ?? this.isPrivate,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// نموذج تفضيلات المستخدم
class UserPreferencesModel {
  final String id;
  final String userId;
  final String theme;
  final String language;
  final bool notificationsEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserPreferencesModel({
    required this.id,
    required this.userId,
    required this.theme,
    required this.language,
    required this.notificationsEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserPreferencesModel.fromDocument(Document doc) {
    return UserPreferencesModel(
      id: doc.$id,
      userId: doc.data['userId'] ?? '',
      theme: doc.data['theme'] ?? 'light',
      language: doc.data['language'] ?? 'ar',
      notificationsEnabled: doc.data['notificationsEnabled'] ?? true,
      createdAt: DateTime.parse(doc.data['createdAt']),
      updatedAt: DateTime.parse(doc.data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'theme': theme,
      'language': language,
      'notificationsEnabled': notificationsEnabled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserPreferencesModel copyWith({
    String? id,
    String? userId,
    String? theme,
    String? language,
    bool? notificationsEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserPreferencesModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// ثوابت قاعدة البيانات
class AppwriteConstants {
  // معرف المشروع
  static const String projectId = '676a0b8e000a9b6c9279';
  
  // نقطة النهاية
  static const String endpoint = 'https://cloud.appwrite.io/v1';
  
  // معرف قاعدة البيانات
  static const String databaseId = 'sakina_db';
  
  // معرفات المجموعات
  static const String usersCollectionId = 'users';
  static const String moodEntriesCollectionId = 'mood_entries';
  static const String meditationSessionsCollectionId = 'meditation_sessions';
  static const String journalEntriesCollectionId = 'journal_entries';
  static const String userPreferencesCollectionId = 'user_preferences';
  
  // معرف حاوية التخزين
  static const String userFilesBucketId = 'user_files';
  
  // أنواع المزاج المتاحة
  static const List<String> moodTypes = [
    'سعيد',
    'حزين',
    'قلق',
    'هادئ',
    'متحمس',
    'غاضب',
    'مرتبك',
    'راضي',
    'متعب',
    'نشيط',
  ];
  
  // أنواع جلسات التأمل
  static const List<String> meditationTypes = [
    'تأمل التنفس',
    'تأمل اليقظة الذهنية',
    'تأمل الجسم',
    'تأمل المحبة والرحمة',
    'تأمل التصور',
    'تأمل المشي',
    'تأمل الاسترخاء',
  ];
  
  // مدد جلسات التأمل (بالثواني)
  static const List<int> meditationDurations = [
    300,  // 5 دقائق
    600,  // 10 دقائق
    900,  // 15 دقائق
    1200, // 20 دقائق
    1800, // 30 دقائق
    2700, // 45 دقائق
    3600, // 60 دقيقة
  ];
  
  // الثيمات المتاحة
  static const List<String> themes = [
    'light',
    'dark',
    'system',
  ];
  
  // اللغات المتاحة
  static const List<String> languages = [
    'ar', // العربية
    'en', // الإنجليزية
  ];
}

// فئة مساعدة للتحقق من صحة البيانات
class ValidationHelper {
  // التحقق من صحة البريد الإلكتروني
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  // التحقق من قوة كلمة المرور
  static bool isValidPassword(String password) {
    return password.length >= 8;
  }
  
  // التحقق من صحة شدة المزاج
  static bool isValidMoodIntensity(int intensity) {
    return intensity >= 1 && intensity <= 10;
  }
  
  // التحقق من صحة تقييم جلسة التأمل
  static bool isValidMeditationRating(int rating) {
    return rating >= 1 && rating <= 5;
  }
  
  // التحقق من صحة مدة جلسة التأمل
  static bool isValidMeditationDuration(int duration) {
    return duration > 0 && duration <= 7200; // حد أقصى ساعتان
  }
}