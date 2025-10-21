class AppConstants {
  // App Info
  static const String appName = 'سكينة';
  static const String appNameEn = 'Sakina';
  static const String appVersion = '1.0.0';

  // API Endpoints
  static const String baseUrl = 'https://api.sakina.com';
  static const String authEndpoint = '/auth';
  static const String profileEndpoint = '/profile';
  static const String consultationsEndpoint = '/consultations';
  static const String therapyEndpoint = '/therapy';
  static const String communityEndpoint = '/community';

  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userIdKey = 'user_id';
  static const String onboardingKey = 'onboarding_completed';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language_code';
  static const String biometricKey = 'biometric_enabled';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String consultationsCollection = 'consultations';
  static const String messagesCollection = 'messages';
  static const String therapyProgramsCollection = 'therapy_programs';
  static const String moodTrackerCollection = 'mood_tracker';
  static const String communityPostsCollection = 'community_posts';
  static const String specialistsCollection = 'specialists';

  // Pagination
  static const int pageSize = 20;
  static const int maxCachedPages = 5;

  // Time Constants
  static const int sessionTimeout = 30; // minutes
  static const int tokenRefreshInterval = 25; // minutes
  static const int moodReminderHour = 20; // 8 PM

  // Security
  static const int minPasswordLength = 8;
  static const int maxLoginAttempts = 5;
  static const int lockoutDuration = 30; // minutes

  // File Upload
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png'];

  // Animations
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration splashDuration = Duration(seconds: 3);
}
