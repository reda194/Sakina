import 'package:flutter/material.dart';
import '../../../services/storage_service.dart';
import '../../../models/user_model.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final StorageService _storageService;

  AuthStatus _status = AuthStatus.initial;
  UserModel? _currentUser;
  String? _errorMessage;

  AuthProvider(this._storageService) {
    _checkAuthStatus();
  }

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  UserModel? get user => _currentUser; // Alias for currentUser
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  StorageService get storageService => _storageService;

  Future<void> _checkAuthStatus() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final token = await _storageService.getUserToken();
      final userId = _storageService.getUserId();

      if (token != null && userId != null) {
        // TODO: Validate token with backend
        // For now, we'll create a mock user
        _currentUser = UserModel(
          id: userId,
          email: _storageService.getUserEmail() ?? '',
          name: 'مستخدم سكينة',
          createdAt: DateTime.now(),
        );
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Implement actual login API call
      // Simulating API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock successful login
      const mockToken = 'mock_auth_token_123';
      const mockUserId = 'user_123';

      await _storageService.saveUserToken(mockToken);
      await _storageService.saveUserId(mockUserId);
      await _storageService.saveUserEmail(email);
      await _storageService.setLoggedIn(true);

      _currentUser = UserModel(
        id: mockUserId,
        email: email,
        name: 'مستخدم سكينة',
        createdAt: DateTime.now(),
      );

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'فشل تسجيل الدخول. يرجى المحاولة مرة أخرى.';
      notifyListeners();
      return false;
    }
  }

  // طريقة تسجيل الدخول بالبريد الإلكتروني وكلمة المرور
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await login(email: email, password: password);
  }

  // طريقة تسجيل الدخول بـ Google
  Future<void> signInWithGoogle() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Implement Google Sign In
      await Future.delayed(const Duration(seconds: 2));

      // Mock successful Google login
      const mockToken = 'mock_google_token_123';
      const mockUserId = 'google_user_123';
      const mockEmail = 'user@gmail.com';

      await _storageService.saveUserToken(mockToken);
      await _storageService.saveUserId(mockUserId);
      await _storageService.saveUserEmail(mockEmail);
      await _storageService.setLoggedIn(true);

      _currentUser = UserModel(
        id: mockUserId,
        email: mockEmail,
        name: 'مستخدم Google',
        createdAt: DateTime.now(),
      );

      _status = AuthStatus.authenticated;
      notifyListeners();
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'فشل تسجيل الدخول بـ Google. يرجى المحاولة مرة أخرى.';
      notifyListeners();
      rethrow;
    }
  }

  // طريقة تسجيل الدخول بـ Facebook
  Future<void> signInWithFacebook() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Implement Facebook Sign In
      await Future.delayed(const Duration(seconds: 2));

      // Mock successful Facebook login
      const mockToken = 'mock_facebook_token_123';
      const mockUserId = 'facebook_user_123';
      const mockEmail = 'user@facebook.com';

      await _storageService.saveUserToken(mockToken);
      await _storageService.saveUserId(mockUserId);
      await _storageService.saveUserEmail(mockEmail);
      await _storageService.setLoggedIn(true);

      _currentUser = UserModel(
        id: mockUserId,
        email: mockEmail,
        name: 'مستخدم Facebook',
        createdAt: DateTime.now(),
      );

      _status = AuthStatus.authenticated;
      notifyListeners();
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'فشل تسجيل الدخول بـ Facebook. يرجى المحاولة مرة أخرى.';
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Implement actual signup API call
      // Simulating API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock successful signup
      const mockToken = 'mock_auth_token_456';
      const mockUserId = 'user_456';

      await _storageService.saveUserToken(mockToken);
      await _storageService.saveUserId(mockUserId);
      await _storageService.saveUserEmail(email);
      await _storageService.setLoggedIn(true);

      _currentUser = UserModel(
        id: mockUserId,
        email: email,
        name: name,
        createdAt: DateTime.now(),
      );

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'فشل إنشاء الحساب. يرجى المحاولة مرة أخرى.';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      await _storageService.clearUserData();
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
    } catch (e) {
      _errorMessage = 'فشل تسجيل الخروج. يرجى المحاولة مرة أخرى.';
    }

    notifyListeners();
  }

  Future<void> forgotPassword(String email) async {
    // TODO: Implement forgot password functionality
    await Future.delayed(const Duration(seconds: 1));
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
