import 'package:flutter/material.dart';

class AuthResult {
  final bool success;
  final String message;
  final dynamic data;

  AuthResult({
    required this.success,
    required this.message,
    this.data,
  });
}

class AppService extends ChangeNotifier {
  static final AppService _instance = AppService._internal();
  factory AppService() => _instance;
  AppService._internal();

  static AppService get instance => _instance;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // تهيئة الخدمات الأساسية
    await Future.delayed(const Duration(milliseconds: 500));

    _isInitialized = true;
    notifyListeners();
  }

  Future<AuthResult> login(String email, String password) async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock authentication logic
      if (email.isNotEmpty && password.length >= 6) {
        return AuthResult(
          success: true,
          message: 'تم تسجيل الدخول بنجاح',
          data: {'userId': 'mock_user_id'},
        );
      } else {
        return AuthResult(
          success: false,
          message: 'بيانات الدخول غير صحيحة',
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'حدث خطأ أثناء تسجيل الدخول',
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock registration logic
      if (email.isNotEmpty && password.length >= 6 && name.isNotEmpty) {
        return AuthResult(
          success: true,
          message: 'تم إنشاء الحساب بنجاح',
          data: {'userId': 'mock_user_id'},
        );
      } else {
        return AuthResult(
          success: false,
          message: 'يرجى التأكد من صحة البيانات المدخلة',
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'حدث خطأ أثناء إنشاء الحساب',
      );
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    // تنظيف الموارد
    super.dispose();
  }
}
