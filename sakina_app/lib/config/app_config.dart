/// إعدادات التطبيق والبيئة
class AppConfig {
  // إعدادات Appwrite
  static const String APPWRITE_PROJECT_ID = "68721b73002afcee7cf6";
  static const String APPWRITE_ENDPOINT = "https://cloud.appwrite.io/v1";
  
  // إعدادات قاعدة البيانات
  static const String DATABASE_ID = "sakina_database";
  
  // معرفات المجموعات
  static const String USERS_COLLECTION_ID = "users";
  static const String MOOD_ENTRIES_COLLECTION_ID = "mood_entries";
  static const String MEDITATION_SESSIONS_COLLECTION_ID = "meditation_sessions";
  static const String JOURNAL_ENTRIES_COLLECTION_ID = "journal_entries";
  static const String USER_PREFERENCES_COLLECTION_ID = "user_preferences";
  
  // إعدادات التطبيق
  static const String APP_NAME = "سكينة";
  static const String APP_VERSION = "1.0.0";
  static const String PACKAGE_NAME = "com.sakina.sakina_app";
  
  // إعدادات الواجهة
  static const Duration ANIMATION_DURATION = Duration(milliseconds: 300);
  static const Duration SPLASH_DURATION = Duration(seconds: 3);
  
  // إعدادات التخزين المحلي
  static const String PREFS_USER_ID = "user_id";
  static const String PREFS_USER_EMAIL = "user_email";
  static const String PREFS_USER_NAME = "user_name";
  static const String PREFS_IS_LOGGED_IN = "is_logged_in";
  static const String PREFS_THEME_MODE = "theme_mode";
  static const String PREFS_LANGUAGE = "language";
  static const String PREFS_NOTIFICATIONS_ENABLED = "notifications_enabled";
  static const String PREFS_FIRST_TIME = "first_time";
  
  // إعدادات الإشعارات
  static const String NOTIFICATION_CHANNEL_ID = "sakina_notifications";
  static const String NOTIFICATION_CHANNEL_NAME = "إشعارات سكينة";
  static const String NOTIFICATION_CHANNEL_DESCRIPTION = "إشعارات تطبيق سكينة للصحة النفسية";
  
  // حدود البيانات
  static const int MAX_MOOD_ENTRIES_PER_DAY = 10;
  static const int MAX_JOURNAL_CONTENT_LENGTH = 5000;
  static const int MAX_MOOD_NOTE_LENGTH = 500;
  static const int MIN_MEDITATION_DURATION = 1; // دقيقة
  static const int MAX_MEDITATION_DURATION = 120; // دقيقة
  
  // URLs مفيدة
  static const String PRIVACY_POLICY_URL = "https://sakina-app.com/privacy";
  static const String TERMS_OF_SERVICE_URL = "https://sakina-app.com/terms";
  static const String SUPPORT_EMAIL = "support@sakina-app.com";
  static const String WEBSITE_URL = "https://sakina-app.com";
  
  // أنواع الحالات المزاجية
  static const List<String> MOOD_TYPES = [
    'سعيد',
    'حزين',
    'قلق',
    'هادئ',
    'متحمس',
    'غاضب',
    'مرتبك',
    'راضي',
    'متعب',
    'نشيط'
  ];
  
  // أنواع التأمل
  static const List<String> MEDITATION_TYPES = [
    'تأمل التنفس',
    'تأمل اليقظة الذهنية',
    'تأمل الجسم',
    'تأمل الحب والرحمة',
    'تأمل التصور',
    'تأمل المشي',
    'تأمل الاسترخاء'
  ];
  
  // الألوان الأساسية (hex codes)
  static const String PRIMARY_COLOR = "#6B73FF";
  static const String SECONDARY_COLOR = "#9B59B6";
  static const String SUCCESS_COLOR = "#27AE60";
  static const String WARNING_COLOR = "#F39C12";
  static const String ERROR_COLOR = "#E74C3C";
  static const String INFO_COLOR = "#3498DB";
  
  // إعدادات التطوير
  static const bool DEBUG_MODE = true;
  static const bool ENABLE_LOGGING = true;
  static const bool ENABLE_ANALYTICS = false;
  
  /// التحقق من صحة إعدادات Appwrite
  static bool get isAppwriteConfigured {
    return APPWRITE_PROJECT_ID.isNotEmpty && APPWRITE_ENDPOINT.isNotEmpty;
  }
  
  /// الحصول على URL كامل للـ endpoint
  static String get fullEndpoint {
    return APPWRITE_ENDPOINT.endsWith('/') 
        ? APPWRITE_ENDPOINT 
        : '$APPWRITE_ENDPOINT/';
  }
  
  /// التحقق من صحة البريد الإلكتروني
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  /// التحقق من قوة كلمة المرور
  static bool isStrongPassword(String password) {
    // على الأقل 8 أحرف، حرف كبير، حرف صغير، رقم
    return password.length >= 8 &&
           RegExp(r'[A-Z]').hasMatch(password) &&
           RegExp(r'[a-z]').hasMatch(password) &&
           RegExp(r'[0-9]').hasMatch(password);
  }
  
  /// الحصول على رسالة خطأ كلمة المرور
  static String getPasswordErrorMessage(String password) {
    if (password.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'كلمة المرور يجب أن تحتوي على حرف كبير';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'كلمة المرور يجب أن تحتوي على حرف صغير';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'كلمة المرور يجب أن تحتوي على رقم';
    }
    return '';
  }
}