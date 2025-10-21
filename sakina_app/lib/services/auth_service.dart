import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:flutter/foundation.dart';

import 'appwrite_repository.dart';

/// خدمة المصادقة باستخدام Appwrite
class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();
  
  AuthService._();
  
  final AppwriteRepository _appwrite = AppwriteRepository.instance;
  
  appwrite_models.User? _currentUser;
  appwrite_models.Session? _currentSession;
  
  // Getters
  appwrite_models.User? get currentUser => _currentUser;
  appwrite_models.Session? get currentSession => _currentSession;
  bool get isLoggedIn => _currentUser != null && _currentSession != null;
  
  /// تهيئة خدمة المصادقة
  Future<void> initialize() async {
    try {
      _currentUser = await _appwrite.getCurrentUser();
      if (_currentUser != null) {
        if (kDebugMode) {
          print('User already logged in: ${_currentUser!.email}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('No active session found');
      }
    }
  }
  
  /// إنشاء حساب جديد
  Future<AuthResult> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // إنشاء الحساب
      final user = await _appwrite.createAccount(
        email: email,
        password: password,
        name: name,
      );
      
      if (user != null) {
        // تسجيل الدخول تلقائياً بعد إنشاء الحساب
        final loginResult = await login(email: email, password: password);
        return loginResult;
      }
      
      return const AuthResult(
        success: false,
        message: 'فشل في إنشاء الحساب',
      );
    } on AppwriteException catch (e) {
      return AuthResult(
        success: false,
        message: _getErrorMessage(e),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'حدث خطأ غير متوقع: $e',
      );
    }
  }
  
  /// تسجيل الدخول
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final session = await _appwrite.login(
        email: email,
        password: password,
      );
      
      if (session != null) {
        _currentSession = session;
        _currentUser = await _appwrite.getCurrentUser();
        
        return AuthResult(
          success: true,
          message: 'تم تسجيل الدخول بنجاح',
          user: _currentUser,
          session: _currentSession,
        );
      }
      
      return const AuthResult(
        success: false,
        message: 'فشل في تسجيل الدخول',
      );
    } on AppwriteException catch (e) {
      return AuthResult(
        success: false,
        message: _getErrorMessage(e),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'حدث خطأ غير متوقع: $e',
      );
    }
  }
  
  /// تسجيل الخروج
  Future<AuthResult> logout() async {
    try {
      await _appwrite.logout();
      _currentUser = null;
      _currentSession = null;
      
      return const AuthResult(
        success: true,
        message: 'تم تسجيل الخروج بنجاح',
      );
    } on AppwriteException catch (e) {
      return AuthResult(
        success: false,
        message: _getErrorMessage(e),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'حدث خطأ غير متوقع: $e',
      );
    }
  }
  
  /// إعادة تعيين كلمة المرور
  Future<AuthResult> resetPassword({required String email}) async {
    try {
      await _appwrite.account.createRecovery(
        email: email,
        url: 'https://your-app.com/reset-password', // يجب تغييرها لرابط التطبيق الفعلي
      );
      
      return const AuthResult(
        success: true,
        message: 'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني',
      );
    } on AppwriteException catch (e) {
      return AuthResult(
        success: false,
        message: _getErrorMessage(e),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'حدث خطأ غير متوقع: $e',
      );
    }
  }
  
  /// تحديث بيانات المستخدم
  Future<AuthResult> updateProfile({
    String? name,
    String? email,
  }) async {
    try {
      appwrite_models.User? updatedUser;
      
      if (name != null) {
        updatedUser = await _appwrite.account.updateName(name: name);
      }
      
      if (email != null) {
        updatedUser = await _appwrite.account.updateEmail(
          email: email,
          password: '', // يتطلب كلمة المرور الحالية
        );
      }
      
      if (updatedUser != null) {
        _currentUser = updatedUser;
      }
      
      return AuthResult(
        success: true,
        message: 'تم تحديث البيانات بنجاح',
        user: _currentUser,
      );
    } on AppwriteException catch (e) {
      return AuthResult(
        success: false,
        message: _getErrorMessage(e),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'حدث خطأ غير متوقع: $e',
      );
    }
  }
  
  /// تغيير كلمة المرور
  Future<AuthResult> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _appwrite.account.updatePassword(
        password: newPassword,
        oldPassword: oldPassword,
      );
      
      return const AuthResult(
        success: true,
        message: 'تم تغيير كلمة المرور بنجاح',
      );
    } on AppwriteException catch (e) {
      return AuthResult(
        success: false,
        message: _getErrorMessage(e),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'حدث خطأ غير متوقع: $e',
      );
    }
  }
  
  /// تحويل رسائل الخطأ إلى العربية
  String _getErrorMessage(AppwriteException e) {
    switch (e.code) {
      case 401:
        return 'بيانات الدخول غير صحيحة';
      case 409:
        return 'المستخدم موجود بالفعل';
      case 429:
        return 'تم تجاوز عدد المحاولات المسموحة';
      case 400:
        return 'البيانات المدخلة غير صحيحة';
      case 404:
        return 'المستخدم غير موجود';
      case 500:
        return 'خطأ في الخادم';
      default:
        return e.message ?? 'حدث خطأ غير معروف';
    }
  }
}

/// نتيجة عملية المصادقة
class AuthResult {
  final bool success;
  final String message;
  final appwrite_models.User? user;
  final appwrite_models.Session? session;
  
  const AuthResult({
    required this.success,
    required this.message,
    this.user,
    this.session,
  });
  
  @override
  String toString() {
    return 'AuthResult(success: $success, message: $message)';
  }
}