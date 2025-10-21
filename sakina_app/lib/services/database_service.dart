import 'package:appwrite/appwrite.dart';
import 'appwrite_repository.dart';
import '../config/app_config.dart';

/// خدمة قاعدة البيانات باستخدام Appwrite
class DatabaseService {
  static DatabaseService? _instance;
  static DatabaseService get instance => _instance ??= DatabaseService._();
  
  DatabaseService._();
  
  final AppwriteRepository _appwrite = AppwriteRepository.instance;
  
  /// إنشاء ملف تعريف المستخدم
  Future<DatabaseResult> createUserProfile({
    required String userId,
    required String name,
    required String email,
    String? phone,
    String? bio,
    DateTime? birthDate,
    String? gender,
  }) async {
    try {
      final data = {
        'user_id': userId,
        'name': name,
        'email': email,
        'phone': phone ?? '',
        'bio': bio ?? '',
        'birth_date': birthDate?.toIso8601String(),
        'gender': gender ?? '',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      final document = await _appwrite.createDocument(
        databaseId: AppConfig.DATABASE_ID,
        collectionId: AppConfig.USERS_COLLECTION_ID,
        data: data,
        documentId: userId,
      );
      
      return DatabaseResult(
        success: true,
        message: 'تم إنشاء ملف التعريف بنجاح',
        data: document?.data,
      );
    } on AppwriteException catch (e) {
      return DatabaseResult(
        success: false,
        message: _getErrorMessage(e),
      );
    } catch (e) {
      return DatabaseResult(
        success: false,
        message: 'حدث خطأ غير متوقع: $e',
      );
    }
  }
  
  /// الحصول على ملف تعريف المستخدم
  Future<DatabaseResult> getUserProfile(String userId) async {
    try {
      final document = await _appwrite.getDocument(
        databaseId: AppConfig.DATABASE_ID,
        collectionId: AppConfig.USERS_COLLECTION_ID,
        documentId: userId,
      );
      
      return DatabaseResult(
        success: true,
        message: 'تم جلب البيانات بنجاح',
        data: document?.data,
      );
    } on AppwriteException catch (e) {
      return DatabaseResult(
        success: false,
        message: _getErrorMessage(e),
      );
    } catch (e) {
      return DatabaseResult(
        success: false,
        message: 'حدث خطأ غير متوقع: $e',
      );
    }
  }
  
  /// تحديث ملف تعريف المستخدم
  Future<DatabaseResult> updateUserProfile({
    required String userId,
    Map<String, dynamic>? updates,
  }) async {
    try {
      if (updates == null || updates.isEmpty) {
        return const DatabaseResult(
          success: false,
          message: 'لا توجد بيانات للتحديث',
        );
      }
      
      updates['updated_at'] = DateTime.now().toIso8601String();
      
      final document = await _appwrite.updateDocument(
        databaseId: AppConfig.DATABASE_ID,
        collectionId: AppConfig.USERS_COLLECTION_ID,
        documentId: userId,
        data: updates,
      );
      
      return DatabaseResult(
        success: true,
        message: 'تم تحديث البيانات بنجاح',
        data: document?.data,
      );
    } on AppwriteException catch (e) {
      return DatabaseResult(
        success: false,
        message: _getErrorMessage(e),
      );
    } catch (e) {
      return DatabaseResult(
        success: false,
        message: 'حدث خطأ غير متوقع: $e',
      );
    }
  }
  
  /// إضافة إدخال حالة مزاجية
  Future<DatabaseResult> addMoodEntry({
    required String userId,
    required String mood,
    String? note,
    int? intensity,
    List<String>? tags,
  }) async {
    try {
      final data = {
        'user_id': userId,
        'mood': mood,
        'note': note ?? '',
        'intensity': intensity ?? 5,
        'tags': tags ?? [],
        'date': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      };
      
      final document = await _appwrite.createDocument(
        databaseId: AppConfig.DATABASE_ID,
        collectionId: AppConfig.MOOD_ENTRIES_COLLECTION_ID,
        data: data,
      );
      
      return DatabaseResult(
        success: true,
        message: 'تم حفظ الحالة المزاجية بنجاح',
        data: document?.data,
      );
    } on AppwriteException catch (e) {
      return DatabaseResult(
        success: false,
        message: _getErrorMessage(e),
      );
    } catch (e) {
      return DatabaseResult(
        success: false,
        message: 'حدث خطأ غير متوقع: $e',
      );
    }
  }
  
  /// الحصول على إدخالات الحالة المزاجية للمستخدم
  Future<DatabaseResult> getUserMoodEntries({
    required String userId,
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      List<String> queries = [Query.equal('user_id', userId)];
      
      if (startDate != null) {
        queries.add(Query.greaterThanEqual('date', startDate.toIso8601String()));
      }
      
      if (endDate != null) {
        queries.add(Query.lessThanEqual('date', endDate.toIso8601String()));
      }
      
      queries.add(Query.orderDesc('date'));
      
      if (limit != null) {
        queries.add(Query.limit(limit));
      }
      
      final documents = await _appwrite.listDocuments(
        databaseId: AppConfig.DATABASE_ID,
        collectionId: AppConfig.MOOD_ENTRIES_COLLECTION_ID,
        queries: queries,
      );
      
      return DatabaseResult(
        success: true,
        message: 'تم جلب البيانات بنجاح',
        data: documents?.documents.map((doc) => doc.data).toList(),
      );
    } on AppwriteException catch (e) {
      return DatabaseResult(
        success: false,
        message: _getErrorMessage(e),
      );
    } catch (e) {
      return DatabaseResult(
        success: false,
        message: 'حدث خطأ غير متوقع: $e',
      );
    }
  }
  
  /// إضافة جلسة تأمل
  Future<DatabaseResult> addMeditationSession({
    required String userId,
    required int duration, // بالدقائق
    required String type,
    String? notes,
  }) async {
    try {
      final data = {
        'user_id': userId,
        'duration': duration,
        'type': type,
        'notes': notes ?? '',
        'date': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      };
      
      final document = await _appwrite.createDocument(
        databaseId: AppConfig.DATABASE_ID,
        collectionId: AppConfig.MEDITATION_SESSIONS_COLLECTION_ID,
        data: data,
      );
      
      return DatabaseResult(
        success: true,
        message: 'تم حفظ جلسة التأمل بنجاح',
        data: document?.data,
      );
    } on AppwriteException catch (e) {
      return DatabaseResult(
        success: false,
        message: _getErrorMessage(e),
      );
    } catch (e) {
      return DatabaseResult(
        success: false,
        message: 'حدث خطأ غير متوقع: $e',
      );
    }
  }
  
  /// إضافة إدخال يومية
  Future<DatabaseResult> addJournalEntry({
    required String userId,
    required String title,
    required String content,
    String? mood,
    List<String>? tags,
  }) async {
    try {
      final data = {
        'user_id': userId,
        'title': title,
        'content': content,
        'mood': mood ?? '',
        'tags': tags ?? [],
        'date': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      final document = await _appwrite.createDocument(
        databaseId: AppConfig.DATABASE_ID,
        collectionId: AppConfig.JOURNAL_ENTRIES_COLLECTION_ID,
        data: data,
      );
      
      return DatabaseResult(
        success: true,
        message: 'تم حفظ اليومية بنجاح',
        data: document?.data,
      );
    } on AppwriteException catch (e) {
      return DatabaseResult(
        success: false,
        message: _getErrorMessage(e),
      );
    } catch (e) {
      return DatabaseResult(
        success: false,
        message: 'حدث خطأ غير متوقع: $e',
      );
    }
  }
  
  /// حفظ تفضيلات المستخدم
  Future<DatabaseResult> saveUserPreferences({
    required String userId,
    required Map<String, dynamic> preferences,
  }) async {
    try {
      final data = {
        'user_id': userId,
        'preferences': preferences,
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      final document = await _appwrite.createDocument(
        databaseId: AppConfig.DATABASE_ID,
        collectionId: AppConfig.USER_PREFERENCES_COLLECTION_ID,
        data: data,
        documentId: userId,
      );
      
      return DatabaseResult(
        success: true,
        message: 'تم حفظ التفضيلات بنجاح',
        data: document?.data,
      );
    } on AppwriteException catch (e) {
      // إذا كان المستند موجود، نحدثه
      if (e.code == 409) {
        return await updateUserPreferences(
          userId: userId,
          preferences: preferences,
        );
      }
      
      return DatabaseResult(
        success: false,
        message: _getErrorMessage(e),
      );
    } catch (e) {
      return DatabaseResult(
        success: false,
        message: 'حدث خطأ غير متوقع: $e',
      );
    }
  }
  
  /// تحديث تفضيلات المستخدم
  Future<DatabaseResult> updateUserPreferences({
    required String userId,
    required Map<String, dynamic> preferences,
  }) async {
    try {
      final data = {
        'preferences': preferences,
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      final document = await _appwrite.updateDocument(
        databaseId: AppConfig.DATABASE_ID,
        collectionId: AppConfig.USER_PREFERENCES_COLLECTION_ID,
        documentId: userId,
        data: data,
      );
      
      return DatabaseResult(
        success: true,
        message: 'تم تحديث التفضيلات بنجاح',
        data: document?.data,
      );
    } on AppwriteException catch (e) {
      return DatabaseResult(
        success: false,
        message: _getErrorMessage(e),
      );
    } catch (e) {
      return DatabaseResult(
        success: false,
        message: 'حدث خطأ غير متوقع: $e',
      );
    }
  }
  
  /// الحصول على تفضيلات المستخدم
  Future<DatabaseResult> getUserPreferences(String userId) async {
    try {
      final document = await _appwrite.getDocument(
        databaseId: AppConfig.DATABASE_ID,
        collectionId: AppConfig.USER_PREFERENCES_COLLECTION_ID,
        documentId: userId,
      );
      
      return DatabaseResult(
        success: true,
        message: 'تم جلب التفضيلات بنجاح',
        data: document?.data,
      );
    } on AppwriteException catch (e) {
      return DatabaseResult(
        success: false,
        message: _getErrorMessage(e),
      );
    } catch (e) {
      return DatabaseResult(
        success: false,
        message: 'حدث خطأ غير متوقع: $e',
      );
    }
  }
  
  /// حذف إدخال
  Future<DatabaseResult> deleteDocument({
    required String collectionId,
    required String documentId,
  }) async {
    try {
      final success = await _appwrite.deleteDocument(
        databaseId: AppConfig.DATABASE_ID,
        collectionId: collectionId,
        documentId: documentId,
      );
      
      return DatabaseResult(
        success: success,
        message: success ? 'تم الحذف بنجاح' : 'فشل في الحذف',
      );
    } on AppwriteException catch (e) {
      return DatabaseResult(
        success: false,
        message: _getErrorMessage(e),
      );
    } catch (e) {
      return DatabaseResult(
        success: false,
        message: 'حدث خطأ غير متوقع: $e',
      );
    }
  }
  
  /// تحويل رسائل الخطأ إلى العربية
  String _getErrorMessage(AppwriteException e) {
    switch (e.code) {
      case 401:
        return 'غير مصرح لك بالوصول';
      case 404:
        return 'البيانات غير موجودة';
      case 409:
        return 'البيانات موجودة بالفعل';
      case 400:
        return 'البيانات المدخلة غير صحيحة';
      case 500:
        return 'خطأ في الخادم';
      default:
        return e.message ?? 'حدث خطأ غير معروف';
    }
  }
}

/// نتيجة عملية قاعدة البيانات
class DatabaseResult {
  final bool success;
  final String message;
  final dynamic data;
  
  const DatabaseResult({
    required this.success,
    required this.message,
    this.data,
  });
  
  @override
  String toString() {
    return 'DatabaseResult(success: $success, message: $message)';
  }
}