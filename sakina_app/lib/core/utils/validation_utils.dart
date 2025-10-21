class ValidationUtils {
  /// التحقق من صحة البريد الإلكتروني
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// التحقق من صحة رقم الهاتف
  static bool isValidPhone(String phone) {
    // يدعم الأرقام السعودية والعربية
    return RegExp(r'^(\+966|966|0)?[5][0-9]{8}$').hasMatch(phone.replaceAll(' ', '').replaceAll('-', ''));
  }

  /// التحقق من قوة كلمة المرور
  static PasswordStrength getPasswordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.empty;
    if (password.length < 6) return PasswordStrength.weak;
    
    int score = 0;
    
    // طول كلمة المرور
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    
    // احتواء على أحرف كبيرة
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    
    // احتواء على أحرف صغيرة
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    
    // احتواء على أرقام
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    
    // احتواء على رموز خاصة
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;
    
    if (score < 3) return PasswordStrength.weak;
    if (score < 5) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  /// التحقق من صحة الاسم
  static bool isValidName(String name) {
    if (name.trim().isEmpty) return false;
    if (name.trim().length < 2) return false;
    // يدعم الأحرف العربية والإنجليزية والمسافات
    return RegExp(r'^[a-zA-Zأ-ي\s]+$').hasMatch(name.trim());
  }

  /// التحقق من صحة العمر
  static bool isValidAge(int age) {
    return age >= 13 && age <= 120;
  }

  /// التحقق من صحة الرقم القومي السعودي
  static bool isValidSaudiID(String id) {
    if (id.length != 10) return false;
    if (!RegExp(r'^[12]').hasMatch(id)) return false;
    
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      int digit = int.parse(id[i]);
      if (i % 2 == 0) {
        digit *= 2;
        if (digit > 9) digit = digit ~/ 10 + digit % 10;
      }
      sum += digit;
    }
    
    int checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit == int.parse(id[9]);
  }

  /// التحقق من صحة رقم الترخيص المهني
  static bool isValidLicenseNumber(String license) {
    if (license.trim().isEmpty) return false;
    // يجب أن يكون بين 6-20 حرف ورقم
    return RegExp(r'^[A-Za-z0-9]{6,20}$').hasMatch(license.trim());
  }

  /// التحقق من صحة السعر
  static bool isValidPrice(double price) {
    return price > 0 && price <= 10000;
  }

  /// التحقق من صحة التقييم
  static bool isValidRating(double rating) {
    return rating >= 0 && rating <= 5;
  }

  /// التحقق من صحة المدة بالدقائق
  static bool isValidDuration(int minutes) {
    return minutes > 0 && minutes <= 480; // حد أقصى 8 ساعات
  }

  /// التحقق من صحة النص (لا يحتوي على محتوى ضار)
  static bool isValidText(String text) {
    if (text.trim().isEmpty) return false;
    // التحقق من عدم وجود HTML أو JavaScript
    if (RegExp(r'<[^>]*>|javascript:|data:|vbscript:', caseSensitive: false).hasMatch(text)) {
      return false;
    }
    return true;
  }

  /// التحقق من صحة URL
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// الحصول على رسالة خطأ للبريد الإلكتروني
  static String? validateEmail(String? email, {bool isArabic = true}) {
    if (email == null || email.isEmpty) {
      return isArabic ? 'البريد الإلكتروني مطلوب' : 'Email is required';
    }
    if (!isValidEmail(email)) {
      return isArabic ? 'البريد الإلكتروني غير صحيح' : 'Invalid email format';
    }
    return null;
  }

  /// الحصول على رسالة خطأ لرقم الهاتف
  static String? validatePhone(String? phone, {bool isArabic = true}) {
    if (phone == null || phone.isEmpty) {
      return isArabic ? 'رقم الهاتف مطلوب' : 'Phone number is required';
    }
    if (!isValidPhone(phone)) {
      return isArabic ? 'رقم الهاتف غير صحيح' : 'Invalid phone number';
    }
    return null;
  }

  /// الحصول على رسالة خطأ لكلمة المرور
  static String? validatePassword(String? password, {bool isArabic = true}) {
    if (password == null || password.isEmpty) {
      return isArabic ? 'كلمة المرور مطلوبة' : 'Password is required';
    }
    
    final strength = getPasswordStrength(password);
    switch (strength) {
      case PasswordStrength.empty:
        return isArabic ? 'كلمة المرور مطلوبة' : 'Password is required';
      case PasswordStrength.weak:
        return isArabic ? 'كلمة المرور ضعيفة جداً' : 'Password is too weak';
      case PasswordStrength.medium:
      case PasswordStrength.strong:
        return null;
    }
  }

  /// الحصول على رسالة خطأ للاسم
  static String? validateName(String? name, {bool isArabic = true}) {
    if (name == null || name.isEmpty) {
      return isArabic ? 'الاسم مطلوب' : 'Name is required';
    }
    if (!isValidName(name)) {
      return isArabic ? 'الاسم غير صحيح' : 'Invalid name format';
    }
    return null;
  }

  /// الحصول على رسالة خطأ للنص المطلوب
  static String? validateRequired(String? value, String fieldName, {bool isArabic = true}) {
    if (value == null || value.trim().isEmpty) {
      return isArabic ? '$fieldName مطلوب' : '$fieldName is required';
    }
    return null;
  }

  /// التحقق من تطابق كلمتي المرور
  static String? validatePasswordConfirmation(String? password, String? confirmation, {bool isArabic = true}) {
    if (confirmation == null || confirmation.isEmpty) {
      return isArabic ? 'تأكيد كلمة المرور مطلوب' : 'Password confirmation is required';
    }
    if (password != confirmation) {
      return isArabic ? 'كلمتا المرور غير متطابقتين' : 'Passwords do not match';
    }
    return null;
  }
}

enum PasswordStrength {
  empty,
  weak,
  medium,
  strong,
}

extension PasswordStrengthExtension on PasswordStrength {
  String getLabel({bool isArabic = true}) {
    switch (this) {
      case PasswordStrength.empty:
        return isArabic ? 'فارغة' : 'Empty';
      case PasswordStrength.weak:
        return isArabic ? 'ضعيفة' : 'Weak';
      case PasswordStrength.medium:
        return isArabic ? 'متوسطة' : 'Medium';
      case PasswordStrength.strong:
        return isArabic ? 'قوية' : 'Strong';
    }
  }

  double get progress {
    switch (this) {
      case PasswordStrength.empty:
        return 0.0;
      case PasswordStrength.weak:
        return 0.25;
      case PasswordStrength.medium:
        return 0.75;
      case PasswordStrength.strong:
        return 1.0;
    }
  }
}