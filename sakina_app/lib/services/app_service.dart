import 'package:flutter/material.dart';
import 'package:appwrite/models.dart' as appwrite_models;
import 'auth_service.dart';
import 'storage_service.dart';
import '../models/user_model.dart';

class AppAuthResult {
  final bool success;
  final String message;
  final dynamic data;
  final UserModel? user;
  final appwrite_models.Session? session;

  AppAuthResult({
    required this.success,
    required this.message,
    this.data,
    this.user,
    this.session,
  });
}

class AppService extends ChangeNotifier {
  static final AppService _instance = AppService._internal();
  factory AppService() => _instance;
  AppService._internal();

  static AppService get instance => _instance;

  final AuthService _authService = AuthService.instance;
  StorageService? _storageService;
  UserModel? _currentUser;
  appwrite_models.Session? _currentSession;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  UserModel? get currentUser => _currentUser;
  appwrite_models.Session? get currentSession => _currentSession;
  bool get isAuthenticated => _currentUser != null && _currentSession != null;

  Future<void> initialize(StorageService storageService) async {
    if (_isInitialized) return;

    _storageService = storageService;

    try {
      // Initialize AuthService
      await _authService.initialize();

      // Check actual Appwrite session regardless of stored token
      final appwriteUser = _authService.currentUser;
      if (appwriteUser != null) {
        // Valid session exists in Appwrite
        _currentUser = _convertAppwriteUserToUserModel(appwriteUser);
        _currentSession = _authService.currentSession;

        // Persist minimal user data to storage
        await _storageService!.saveUserId(appwriteUser.$id);
        await _storageService!.saveUserEmail(appwriteUser.email);
        await _storageService!.setLoggedIn(true);
        if (_currentSession != null) {
          await _storageService!.saveUserToken(_currentSession!.$id);
        }
      } else {
        // No valid Appwrite session, clear stored data
        await _storageService!.clearUserData();
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('AppService initialization error: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<AppAuthResult> login(String email, String password) async {
    assert(_storageService != null, 'AppService.initialize must be called first');
    if (_storageService == null) {
      return AppAuthResult(
        success: false,
        message: 'AppService not initialized. Please initialize before use.',
      );
    }

    _setLoading(true);
    try {
      // Call AuthService login
      final authResult = await _authService.login(
        email: email,
        password: password,
      );

      if (authResult.success && authResult.user != null && authResult.session != null) {
        // Convert Appwrite user to UserModel
        _currentUser = _convertAppwriteUserToUserModel(authResult.user!);
        _currentSession = authResult.session;

        // Save session data to storage
        await _storageService!.saveUserToken(authResult.session!.$id);
        await _storageService!.saveUserId(authResult.user!.$id);
        await _storageService!.saveUserEmail(authResult.user!.email);
        await _storageService!.setLoggedIn(true);

        notifyListeners();

        return AppAuthResult(
          success: true,
          message: authResult.message,
          user: _currentUser,
          session: _currentSession,
          data: {'userId': authResult.user!.$id},
        );
      } else {
        return AppAuthResult(
          success: false,
          message: authResult.message,
        );
      }
    } catch (e) {
      debugPrint('Login error: $e');
      return AppAuthResult(
        success: false,
        message: 'حدث خطأ أثناء تسجيل الدخول: $e',
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<AppAuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    assert(_storageService != null, 'AppService.initialize must be called first');
    if (_storageService == null) {
      return AppAuthResult(
        success: false,
        message: 'AppService not initialized. Please initialize before use.',
      );
    }

    _setLoading(true);
    try {
      // Call AuthService register
      final authResult = await _authService.register(
        email: email,
        password: password,
        name: name,
      );

      if (authResult.success && authResult.user != null && authResult.session != null) {
        // Convert Appwrite user to UserModel
        _currentUser = _convertAppwriteUserToUserModel(authResult.user!);
        _currentSession = authResult.session;

        // Save session data to storage
        await _storageService!.saveUserToken(authResult.session!.$id);
        await _storageService!.saveUserId(authResult.user!.$id);
        await _storageService!.saveUserEmail(authResult.user!.email);
        await _storageService!.setLoggedIn(true);

        notifyListeners();

        return AppAuthResult(
          success: true,
          message: authResult.message,
          user: _currentUser,
          session: _currentSession,
          data: {'userId': authResult.user!.$id},
        );
      } else {
        return AppAuthResult(
          success: false,
          message: authResult.message,
        );
      }
    } catch (e) {
      debugPrint('Registration error: $e');
      return AppAuthResult(
        success: false,
        message: 'حدث خطأ أثناء إنشاء الحساب: $e',
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<AppAuthResult> logout() async {
    assert(_storageService != null, 'AppService.initialize must be called first');
    if (_storageService == null) {
      return AppAuthResult(
        success: false,
        message: 'AppService not initialized. Please initialize before use.',
      );
    }

    _setLoading(true);
    try {
      // Call AuthService logout
      final authResult = await _authService.logout();

      // Clear local state
      _currentUser = null;
      _currentSession = null;

      // Clear storage data
      await _storageService!.clearUserData();

      notifyListeners();

      return AppAuthResult(
        success: true,
        message: authResult.message,
      );
    } catch (e) {
      debugPrint('Logout error: $e');
      return AppAuthResult(
        success: false,
        message: 'حدث خطأ أثناء تسجيل الخروج: $e',
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<AppAuthResult> resetPassword(String email) async {
    assert(_storageService != null, 'AppService.initialize must be called first');
    if (_storageService == null) {
      return AppAuthResult(
        success: false,
        message: 'AppService not initialized. Please initialize before use.',
      );
    }

    _setLoading(true);
    try {
      final authResult = await _authService.resetPassword(email: email);

      return AppAuthResult(
        success: authResult.success,
        message: authResult.message,
      );
    } catch (e) {
      debugPrint('Reset password error: $e');
      return AppAuthResult(
        success: false,
        message: 'حدث خطأ أثناء إعادة تعيين كلمة المرور: $e',
      );
    } finally {
      _setLoading(false);
    }
  }

  UserModel _convertAppwriteUserToUserModel(appwrite_models.User appwriteUser) {
    return UserModel(
      id: appwriteUser.$id,
      email: appwriteUser.email,
      name: appwriteUser.name,
      createdAt: DateTime.parse(appwriteUser.$createdAt),
      isEmailVerified: appwriteUser.emailVerification,
      isPhoneVerified: appwriteUser.phoneVerification,
    );
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
