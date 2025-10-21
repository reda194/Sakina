import 'package:flutter/material.dart';
import '../../../core/app/app_controller.dart';

class ProfileProvider extends ChangeNotifier {
  static ProfileProvider? _instance;
  static ProfileProvider get instance => _instance ??= ProfileProvider._();
  
  ProfileProvider._();

  // User profile data
  String _userName = 'المستخدم';
  String _userEmail = 'user@example.com';
  String _userPhone = '';
  String _userBio = '';
  String _profileImageUrl = '';
  DateTime? _birthDate;
  String _gender = '';
  
  // User preferences
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _language = 'ar';
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  
  // Privacy settings
  bool _dataAnalyticsEnabled = true;
  bool _personalizedAdsEnabled = false;
  bool _shareDataEnabled = false;
  
  // App usage statistics
  int _totalSessions = 0;
  int _totalMoodEntries = 0;
  int _totalMeditationMinutes = 0;
  int _streakDays = 0;
  DateTime? _lastActiveDate;
  
  // Getters
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userPhone => _userPhone;
  String get userBio => _userBio;
  String get profileImageUrl => _profileImageUrl;
  DateTime? get birthDate => _birthDate;
  String get gender => _gender;
  
  bool get notificationsEnabled => _notificationsEnabled;
  bool get darkModeEnabled => _darkModeEnabled;
  String get language => _language;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  
  bool get dataAnalyticsEnabled => _dataAnalyticsEnabled;
  bool get personalizedAdsEnabled => _personalizedAdsEnabled;
  bool get shareDataEnabled => _shareDataEnabled;
  
  int get totalSessions => _totalSessions;
  int get totalMoodEntries => _totalMoodEntries;
  int get totalMeditationMinutes => _totalMeditationMinutes;
  int get streakDays => _streakDays;
  DateTime? get lastActiveDate => _lastActiveDate;
  
  // Calculate age from birth date
  int? get age {
    if (_birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - _birthDate!.year;
    if (now.month < _birthDate!.month || 
        (now.month == _birthDate!.month && now.day < _birthDate!.day)) {
      age--;
    }
    return age;
  }
  
  // Get user initials for avatar
  String get userInitials {
    if (_userName.isEmpty) return 'U';
    final names = _userName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return _userName[0].toUpperCase();
  }
  
  // Update user profile
  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? bio,
    String? profileImageUrl,
    DateTime? birthDate,
    String? gender,
  }) async {
    if (name != null) _userName = name;
    if (email != null) _userEmail = email;
    if (phone != null) _userPhone = phone;
    if (bio != null) _userBio = bio;
    if (profileImageUrl != null) _profileImageUrl = profileImageUrl;
    if (birthDate != null) _birthDate = birthDate;
    if (gender != null) _gender = gender;
    
    // Update app controller
    await AppController.instance.updateUserName(_userName);
    
    notifyListeners();
  }
  
  // Update preferences
  Future<void> updatePreferences({
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    String? language,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) async {
    if (notificationsEnabled != null) {
      _notificationsEnabled = notificationsEnabled;
      await AppController.instance.updateNotificationSettings(_notificationsEnabled);
    }
    if (darkModeEnabled != null) {
      _darkModeEnabled = darkModeEnabled;
      await AppController.instance.toggleTheme();
    }
    if (language != null) {
      _language = language;
      await AppController.instance.changeLanguage(_language);
    }
    if (soundEnabled != null) _soundEnabled = soundEnabled;
    if (vibrationEnabled != null) _vibrationEnabled = vibrationEnabled;
    
    notifyListeners();
  }
  
  // Update privacy settings
  Future<void> updatePrivacySettings({
    bool? dataAnalyticsEnabled,
    bool? personalizedAdsEnabled,
    bool? shareDataEnabled,
  }) async {
    if (dataAnalyticsEnabled != null) _dataAnalyticsEnabled = dataAnalyticsEnabled;
    if (personalizedAdsEnabled != null) _personalizedAdsEnabled = personalizedAdsEnabled;
    if (shareDataEnabled != null) _shareDataEnabled = shareDataEnabled;
    
    notifyListeners();
  }
  
  // Update app usage statistics
  Future<void> updateStatistics({
    int? totalSessions,
    int? totalMoodEntries,
    int? totalMeditationMinutes,
    int? streakDays,
    DateTime? lastActiveDate,
  }) async {
    if (totalSessions != null) _totalSessions = totalSessions;
    if (totalMoodEntries != null) _totalMoodEntries = totalMoodEntries;
    if (totalMeditationMinutes != null) _totalMeditationMinutes = totalMeditationMinutes;
    if (streakDays != null) _streakDays = streakDays;
    if (lastActiveDate != null) _lastActiveDate = lastActiveDate;
    
    notifyListeners();
  }
  
  // Increment session count
  Future<void> incrementSessions() async {
    _totalSessions++;
    _lastActiveDate = DateTime.now();
    await AppController.instance.incrementSessions();
    notifyListeners();
  }
  
  // Increment mood entries
  Future<void> incrementMoodEntries() async {
    _totalMoodEntries++;
    await AppController.instance.recordMoodEntry();
    notifyListeners();
  }
  
  // Add meditation minutes
  Future<void> addMeditationMinutes(int minutes) async {
    _totalMeditationMinutes += minutes;
    notifyListeners();
  }
  
  // Update streak
  Future<void> updateStreak() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (_lastActiveDate == null) {
      _streakDays = 1;
    } else {
      final lastActive = DateTime(
        _lastActiveDate!.year,
        _lastActiveDate!.month,
        _lastActiveDate!.day,
      );
      
      final difference = today.difference(lastActive).inDays;
      
      if (difference == 1) {
        // Consecutive day
        _streakDays++;
      } else if (difference > 1) {
        // Streak broken
        _streakDays = 1;
      }
      // If difference == 0, same day, no change
    }
    
    _lastActiveDate = now;
    notifyListeners();
  }
  
  // Reset all data
  Future<void> resetProfile() async {
    _userName = 'المستخدم';
    _userEmail = 'user@example.com';
    _userPhone = '';
    _userBio = '';
    _profileImageUrl = '';
    _birthDate = null;
    _gender = '';
    
    _notificationsEnabled = true;
    _darkModeEnabled = false;
    _language = 'ar';
    _soundEnabled = true;
    _vibrationEnabled = true;
    
    _dataAnalyticsEnabled = true;
    _personalizedAdsEnabled = false;
    _shareDataEnabled = false;
    
    _totalSessions = 0;
    _totalMoodEntries = 0;
    _totalMeditationMinutes = 0;
    _streakDays = 0;
    _lastActiveDate = null;
    
    notifyListeners();
  }
  
  // Load sample data for demo
  void loadSampleData() {
    _userName = 'أحمد محمد';
    _userEmail = 'ahmed.mohamed@example.com';
    _userPhone = '+966501234567';
    _userBio = 'مهتم بالصحة النفسية والتطوير الذاتي';
    _birthDate = DateTime(1990, 5, 15);
    _gender = 'ذكر';
    
    _totalSessions = 45;
    _totalMoodEntries = 32;
    _totalMeditationMinutes = 180;
    _streakDays = 7;
    _lastActiveDate = DateTime.now();
    
    notifyListeners();
  }
  
  // Get profile completion percentage
  double get profileCompletionPercentage {
    int completedFields = 0;
    int totalFields = 7;
    
    if (_userName.isNotEmpty && _userName != 'المستخدم') completedFields++;
    if (_userEmail.isNotEmpty && _userEmail != 'user@example.com') completedFields++;
    if (_userPhone.isNotEmpty) completedFields++;
    if (_userBio.isNotEmpty) completedFields++;
    if (_profileImageUrl.isNotEmpty) completedFields++;
    if (_birthDate != null) completedFields++;
    if (_gender.isNotEmpty) completedFields++;
    
    return completedFields / totalFields;
  }
  
  // Get achievement level based on statistics
  String get achievementLevel {
    final totalPoints = _totalSessions + _totalMoodEntries + (_totalMeditationMinutes ~/ 10) + (_streakDays * 2);
    
    if (totalPoints >= 200) return 'خبير';
    if (totalPoints >= 100) return 'متقدم';
    if (totalPoints >= 50) return 'متوسط';
    if (totalPoints >= 20) return 'مبتدئ';
    return 'جديد';
  }
  
  // Get achievement color
  Color get achievementColor {
    switch (achievementLevel) {
      case 'خبير':
        return const Color(0xFFFFD700); // Gold
      case 'متقدم':
        return const Color(0xFFC0C0C0); // Silver
      case 'متوسط':
        return const Color(0xFFCD7F32); // Bronze
      case 'مبتدئ':
        return const Color(0xFF4CAF50); // Green
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }
}