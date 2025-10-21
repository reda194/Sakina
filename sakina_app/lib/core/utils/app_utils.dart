import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class AppUtils {
  /// إظهار رسالة SnackBar
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// إظهار حوار تأكيد
  static Future<bool> showConfirmDialog(
    BuildContext context,
    String title,
    String message, {
    String confirmText = 'تأكيد',
    String cancelText = 'إلغاء',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// إظهار حوار تحميل
  static void showLoadingDialog(BuildContext context, {String message = 'جاري التحميل...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  /// إخفاء حوار التحميل
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// نسخ النص إلى الحافظة
  static Future<void> copyToClipboard(String text, BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: text));
    showSnackBar(context, 'تم نسخ النص');
  }

  /// فتح رابط في المتصفح
  static Future<void> launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// إجراء مكالمة هاتفية
  static Future<void> makePhoneCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// إرسال رسالة SMS
  static Future<void> sendSMS(String phoneNumber, {String? message}) async {
    final uri = Uri.parse('sms:$phoneNumber${message != null ? '?body=$message' : ''}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// إرسال بريد إلكتروني
  static Future<void> sendEmail(String email, {String? subject, String? body}) async {
    final uri = Uri.parse('mailto:$email?subject=${subject ?? ''}&body=${body ?? ''}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// مشاركة نص
  static Future<void> shareText(String text, {String? subject}) async {
    await Share.share(text, subject: subject);
  }

  /// تنسيق الأرقام (إضافة فواصل)
  static String formatNumber(num number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}،',
    );
  }

  /// تنسيق المبلغ المالي
  static String formatCurrency(double amount, {String currency = 'ريال'}) {
    return '${formatNumber(amount)} $currency';
  }

  /// تحويل الحجم بالبايت إلى نص قابل للقراءة
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes بايت';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} كيلوبايت';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} ميجابايت';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} جيجابايت';
  }

  /// الحصول على لون عشوائي
  static Color getRandomColor() {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.amber,
    ];
    return colors[(DateTime.now().millisecondsSinceEpoch % colors.length)];
  }

  /// الحصول على الأحرف الأولى من الاسم
  static String getInitials(String name) {
    final words = name.trim().split(' ');
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  /// التحقق من الاتصال بالإنترنت
  static Future<bool> hasInternetConnection() async {
    try {
      // يمكن استخدام connectivity_plus للتحقق الفعلي
      return true; // مؤقت
    } catch (e) {
      return false;
    }
  }

  /// تأخير التنفيذ
  static Future<void> delay(Duration duration) async {
    await Future.delayed(duration);
  }

  /// إزالة HTML tags من النص
  static String stripHtmlTags(String htmlText) {
    return htmlText.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  /// اقتطاع النص مع إضافة نقاط
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// تحويل النص إلى عنوان URL صالح
  static String slugify(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .trim();
  }

  /// الحصول على رسالة خطأ مناسبة
  static String getErrorMessage(dynamic error, {bool isArabic = true}) {
    if (error == null) {
      return isArabic ? 'حدث خطأ غير معروف' : 'Unknown error occurred';
    }
    
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('network') || errorString.contains('connection')) {
      return isArabic ? 'خطأ في الاتصال بالإنترنت' : 'Network connection error';
    }
    
    if (errorString.contains('timeout')) {
      return isArabic ? 'انتهت مهلة الاتصال' : 'Connection timeout';
    }
    
    if (errorString.contains('permission')) {
      return isArabic ? 'ليس لديك صلاحية للوصول' : 'Permission denied';
    }
    
    if (errorString.contains('not found')) {
      return isArabic ? 'البيانات المطلوبة غير موجودة' : 'Requested data not found';
    }
    
    return isArabic ? 'حدث خطأ غير متوقع' : 'An unexpected error occurred';
  }

  /// تحويل الوقت إلى نص نسبي (منذ 5 دقائق، منذ ساعة، إلخ)
  static String getRelativeTime(DateTime dateTime, {bool isArabic = true}) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return isArabic ? 'منذ ${difference.inDays} ${difference.inDays == 1 ? 'يوم' : 'أيام'}' 
                      : '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    }
    
    if (difference.inHours > 0) {
      return isArabic ? 'منذ ${difference.inHours} ${difference.inHours == 1 ? 'ساعة' : 'ساعات'}'
                      : '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    }
    
    if (difference.inMinutes > 0) {
      return isArabic ? 'منذ ${difference.inMinutes} ${difference.inMinutes == 1 ? 'دقيقة' : 'دقائق'}'
                      : '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    }
    
    return isArabic ? 'الآن' : 'Just now';
  }

  /// إنشاء معرف فريد
  static String generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// التحقق من كون الجهاز في الوضع المظلم
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// الحصول على حجم الشاشة
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  /// التحقق من كون الجهاز جهاز لوحي
  static bool isTablet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.shortestSide >= 600;
  }

  /// إخفاء لوحة المفاتيح
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }
}