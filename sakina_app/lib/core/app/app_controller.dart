import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/app_service.dart';

class AppController extends ChangeNotifier {
  static AppController? _instance;
  static AppController get instance => _instance ??= AppController._();
  
  AppController._();

  // Theme management
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  // Language management
  Locale _currentLocale = const Locale('ar');
  Locale get currentLocale => _currentLocale;

  // User authentication state
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  // User data
  String? _userName;
  String? _userEmail;
  String? get userName => _userName;
  String? get userEmail => _userEmail;

  // App initialization
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Notification settings
  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;

  // Premium status
  bool _isPremiumUser = false;
  bool get isPremiumUser => _isPremiumUser;

  // Mood tracking
  DateTime? _lastMoodEntry;
  DateTime? get lastMoodEntry => _lastMoodEntry;

  // App statistics
  int _streakDays = 0;
  int _completedSessions = 0;
  int _meditationHours = 0;
  double _happinessLevel = 0.0;

  int get streakDays => _streakDays;
  int get completedSessions => _completedSessions;
  int get meditationHours => _meditationHours;
  double get happinessLevel => _happinessLevel;

  // Initialize app data
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load theme preference
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      
      // Load language preference
      final languageCode = prefs.getString('languageCode') ?? 'ar';
      _currentLocale = Locale(languageCode);
      
      // Load authentication state
      _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
      
      // Load user data
      _userName = prefs.getString('userName');
      _userEmail = prefs.getString('userEmail');
      
      // Load notification settings
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      
      // Load premium status
      _isPremiumUser = prefs.getBool('isPremiumUser') ?? false;
      
      // Load last mood entry
      final lastMoodTimestamp = prefs.getInt('lastMoodEntry');
      if (lastMoodTimestamp != null) {
        _lastMoodEntry = DateTime.fromMillisecondsSinceEpoch(lastMoodTimestamp);
      }
      
      // Load statistics
      _streakDays = prefs.getInt('streakDays') ?? 0;
      _completedSessions = prefs.getInt('completedSessions') ?? 0;
      _meditationHours = prefs.getInt('meditationHours') ?? 0;
      _happinessLevel = prefs.getDouble('happinessLevel') ?? 0.0;
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing app: $e');
    }
  }

  // Theme management
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  Future<void> setTheme(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', _isDarkMode);
      notifyListeners();
    }
  }

  // Language management
  Future<void> changeLanguage(Locale locale) async {
    if (_currentLocale != locale) {
      _currentLocale = locale;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('languageCode', locale.languageCode);
      notifyListeners();
    }
  }

  // Authentication management
  Future<void> login(String email, String name) async {
    _isAuthenticated = true;
    _userEmail = email;
    _userName = name;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', true);
    await prefs.setString('userEmail', email);
    await prefs.setString('userName', name);
    
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      // Call AppService logout to ensure Appwrite session is terminated
      await AppService.instance.logout();
    } catch (e) {
      debugPrint('AppService logout error: $e');
    }

    // Clear local AppController state
    _isAuthenticated = false;
    _userEmail = null;
    _userName = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', false);
    await prefs.remove('userEmail');
    await prefs.remove('userName');

    notifyListeners();
  }

  // Update user name
  Future<void> updateUserName(String name) async {
    if (_userName != name) {
      _userName = name;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', name);
      notifyListeners();
    }
  }

  // Notification management
  Future<void> toggleNotifications() async {
    _notificationsEnabled = !_notificationsEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    notifyListeners();
  }

  Future<void> updateNotificationSettings(bool enabled) async {
    if (_notificationsEnabled != enabled) {
      _notificationsEnabled = enabled;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notificationsEnabled', enabled);
      notifyListeners();
    }
  }

  // Premium management
  Future<void> setPremiumStatus(bool isPremium) async {
    _isPremiumUser = isPremium;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPremiumUser', isPremium);
    notifyListeners();
  }

  // Mood tracking
  Future<void> recordMoodEntry() async {
    _lastMoodEntry = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastMoodEntry', _lastMoodEntry!.millisecondsSinceEpoch);
    
    // Update streak if needed
    await _updateStreak();
    
    notifyListeners();
  }

  bool shouldShowMoodReminder() {
    if (_lastMoodEntry == null) return true;
    
    final now = DateTime.now();
    final lastEntry = _lastMoodEntry!;
    
    // Show reminder if last entry was not today
    return !_isSameDay(now, lastEntry);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  // Statistics management
  Future<void> incrementCompletedSessions() async {
    _completedSessions++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('completedSessions', _completedSessions);
    notifyListeners();
  }

  // Alias for incrementCompletedSessions to match requested API name
  Future<void> incrementSessions() async {
    await incrementCompletedSessions();
  }

  Future<void> addMeditationTime(int minutes) async {
    _meditationHours += minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('meditationHours', _meditationHours);
    notifyListeners();
  }

  Future<void> updateHappinessLevel(double level) async {
    _happinessLevel = level;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('happinessLevel', level);
    notifyListeners();
  }

  Future<void> _updateStreak() async {
    if (_lastMoodEntry == null) return;
    
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    
    // If last entry was yesterday, increment streak
    if (_isSameDay(_lastMoodEntry!, yesterday)) {
      _streakDays++;
    } else if (!_isSameDay(_lastMoodEntry!, now)) {
      // If last entry was not today or yesterday, reset streak
      _streakDays = 1;
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('streakDays', _streakDays);
  }

  // Get profile notification count
  int getProfileNotificationCount() {
    int count = 0;
    
    // Check for incomplete profile
    if (_userName == null || _userName!.isEmpty) count++;
    
    // Check for mood reminder
    if (shouldShowMoodReminder()) count++;
    
    return count;
  }

  // Reset all data (for testing or user request)
  Future<void> resetAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    _isDarkMode = false;
    _currentLocale = const Locale('ar');
    _isAuthenticated = false;
    _userName = null;
    _userEmail = null;
    _notificationsEnabled = true;
    _isPremiumUser = false;
    _lastMoodEntry = null;
    _streakDays = 0;
    _completedSessions = 0;
    _meditationHours = 0;
    _happinessLevel = 0.0;
    
    notifyListeners();
  }
}