import 'package:flutter/material.dart';

class AppService extends ChangeNotifier {
  static final AppService _instance = AppService._internal();
  factory AppService() => _instance;
  AppService._internal();

  static AppService get instance => _instance;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // تهيئة الخدمات الأساسية
    await Future.delayed(const Duration(milliseconds: 500));

    _isInitialized = true;
    notifyListeners();
  }

  @override
  void dispose() {
    // تنظيف الموارد
    super.dispose();
  }
}
