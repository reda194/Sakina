class TherapistConstants {
  // حالات المعالج
  static const String statusActive = 'active';
  static const String statusInactive = 'inactive';
  static const String statusBusy = 'busy';
  static const String statusOffline = 'offline';

  // أنواع التخصصات
  static const List<String> specializations = [
    'علاج نفسي عام',
    'علاج القلق والتوتر',
    'علاج الاكتئاب',
    'علاج الصدمات النفسية',
    'علاج اضطرابات الأكل',
    'علاج إدمان',
    'علاج الأطفال والمراهقين',
    'علاج الأزواج والعلاقات',
    'علاج اضطرابات النوم',
    'علاج اضطرابات الشخصية',
    'العلاج السلوكي المعرفي',
    'العلاج النفسي التحليلي',
    'العلاج الجماعي',
    'العلاج بالفن والموسيقى',
  ];

  // مستويات الخبرة
  static const List<String> experienceLevels = [
    'مبتدئ (أقل من سنتين)',
    'متوسط (2-5 سنوات)',
    'متقدم (5-10 سنوات)',
    'خبير (أكثر من 10 سنوات)',
  ];

  // أنواع الجلسات
  static const List<String> sessionTypes = [
    'جلسة فردية',
    'جلسة جماعية',
    'جلسة أزواج',
    'جلسة عائلية',
    'استشارة سريعة',
    'جلسة طوارئ',
  ];

  // مدد الجلسات (بالدقائق)
  static const List<int> sessionDurations = [
    30,
    45,
    60,
    90,
    120,
  ];

  // أسعار الجلسات الافتراضية
  static const Map<int, double> defaultSessionPrices = {
    30: 150.0,
    45: 200.0,
    60: 250.0,
    90: 350.0,
    120: 450.0,
  };

  // أيام الأسبوع
  static const List<String> weekDays = [
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
  ];

  // أوقات العمل الافتراضية
  static const Map<String, Map<String, String>> defaultWorkingHours = {
    'الأحد': {'start': '09:00', 'end': '17:00'},
    'الاثنين': {'start': '09:00', 'end': '17:00'},
    'الثلاثاء': {'start': '09:00', 'end': '17:00'},
    'الأربعاء': {'start': '09:00', 'end': '17:00'},
    'الخميس': {'start': '09:00', 'end': '17:00'},
    'الجمعة': {'start': '14:00', 'end': '18:00'},
    'السبت': {'start': '09:00', 'end': '17:00'},
  };

  // أنواع الإشعارات
  static const List<String> notificationTypes = [
    'موعد جديد',
    'تذكير بموعد',
    'إلغاء موعد',
    'رسالة من عميل',
    'تقييم جديد',
    'دفعة مالية',
    'تحديث في النظام',
  ];

  // حالات الجلسات
  static const String sessionStatusScheduled = 'scheduled';
  static const String sessionStatusInProgress = 'in_progress';
  static const String sessionStatusCompleted = 'completed';
  static const String sessionStatusCancelled = 'cancelled';
  static const String sessionStatusNoShow = 'no_show';

  // أنواع الدفع
  static const List<String> paymentMethods = [
    'نقداً',
    'بطاقة ائتمان',
    'تحويل بنكي',
    'محفظة إلكترونية',
    'تأمين صحي',
  ];

  // شركات التأمين المدعومة
  static const List<String> supportedInsuranceProviders = [
    'بوبا العربية',
    'التعاونية للتأمين',
    'ساب تكافل',
    'الأهلي تكافل',
    'وقاية للتأمين',
    'اتحاد الخليج للتأمين',
    'الدرع العربي للتأمين',
    'سلامة للتأمين',
  ];

  // مستويات التقييم
  static const Map<int, String> ratingLabels = {
    1: 'ضعيف جداً',
    2: 'ضعيف',
    3: 'متوسط',
    4: 'جيد',
    5: 'ممتاز',
  };

  // أنواع التقارير
  static const List<String> reportTypes = [
    'تقرير يومي',
    'تقرير أسبوعي',
    'تقرير شهري',
    'تقرير ربع سنوي',
    'تقرير سنوي',
    'تقرير مخصص',
  ];

  // حدود النظام
  static const int maxClientsPerTherapist = 200;
  static const int maxSessionsPerDay = 12;
  static const int maxSessionDurationMinutes = 180;
  static const int minSessionDurationMinutes = 15;
  static const double maxHourlyRate = 1000.0;
  static const double minHourlyRate = 50.0;

  // رسائل النظام
  static const Map<String, String> systemMessages = {
    'welcome': 'مرحباً بك في تطبيق سكينة للمعالجين النفسيين',
    'sessionReminder': 'تذكير: لديك جلسة خلال 15 دقيقة',
    'newClientRegistered': 'عميل جديد قام بالتسجيل',
    'paymentReceived': 'تم استلام دفعة مالية جديدة',
    'profileIncomplete': 'يرجى إكمال ملفك الشخصي',
    'verificationRequired': 'يتطلب التحقق من هويتك المهنية',
  };

  // إعدادات الإشعارات الافتراضية
  static const Map<String, bool> defaultNotificationSettings = {
    'newAppointments': true,
    'appointmentReminders': true,
    'cancellations': true,
    'clientMessages': true,
    'reviews': true,
    'payments': true,
    'systemUpdates': false,
    'marketing': false,
  };

  // ألوان حالات المعالج
  static const Map<String, String> statusColors = {
    'active': '#4CAF50',
    'inactive': '#9E9E9E',
    'busy': '#FF9800',
    'offline': '#F44336',
  };

  // أيقونات التخصصات
  static const Map<String, String> specializationIcons = {
    'علاج نفسي عام': 'psychology',
    'علاج القلق والتوتر': 'self_improvement',
    'علاج الاكتئاب': 'sentiment_very_dissatisfied',
    'علاج الصدمات النفسية': 'healing',
    'علاج اضطرابات الأكل': 'restaurant',
    'علاج إدمان': 'block',
    'علاج الأطفال والمراهقين': 'child_care',
    'علاج الأزواج والعلاقات': 'favorite',
    'علاج اضطرابات النوم': 'bedtime',
    'علاج اضطرابات الشخصية': 'person',
    'العلاج السلوكي المعرفي': 'psychology_alt',
    'العلاج النفسي التحليلي': 'analytics',
    'العلاج الجماعي': 'groups',
    'علاج بالفن والموسيقى': 'palette',
  };

  // نصائح للمعالجين
  static const List<String> therapistTips = [
    'حافظ على التواصل المنتظم مع عملائك',
    'استخدم تقنيات العلاج المبنية على الأدلة',
    'اهتم بصحتك النفسية كمعالج',
    'طور مهاراتك باستمرار من خلال التدريب',
    'احترم حدود العلاقة المهنية',
    'وثق جلساتك بعناية',
    'كن متاحاً لحالات الطوارئ',
    'استخدم التكنولوجيا لتحسين خدماتك',
  ];

  // معايير جودة الخدمة
  static const Map<String, double> qualityStandards = {
    'minimumRating': 4.0,
    'maximumCancellationRate': 0.1, // 10%
    'minimumResponseTime': 2.0, // ساعات
    'maximumNoShowRate': 0.05, // 5%
  };
}