import 'package:intl/intl.dart';

class AppDateUtils {
  static const String defaultDateFormat = 'yyyy-MM-dd';
  static const String defaultTimeFormat = 'HH:mm';
  static const String defaultDateTimeFormat = 'yyyy-MM-dd HH:mm';
  static const String arabicDateFormat = 'dd/MM/yyyy';
  static const String arabicTimeFormat = 'hh:mm a';
  static const String arabicDateTimeFormat = 'dd/MM/yyyy hh:mm a';

  /// تنسيق التاريخ للعرض
  static String formatDate(DateTime date, {String? format, bool isArabic = true}) {
    final formatter = DateFormat(format ?? (isArabic ? arabicDateFormat : defaultDateFormat), isArabic ? 'ar' : 'en');
    return formatter.format(date);
  }

  /// تنسيق الوقت للعرض
  static String formatTime(DateTime time, {String? format, bool isArabic = true}) {
    final formatter = DateFormat(format ?? (isArabic ? arabicTimeFormat : defaultTimeFormat), isArabic ? 'ar' : 'en');
    return formatter.format(time);
  }

  /// تنسيق التاريخ والوقت للعرض
  static String formatDateTime(DateTime dateTime, {String? format, bool isArabic = true}) {
    final formatter = DateFormat(format ?? (isArabic ? arabicDateTimeFormat : defaultDateTimeFormat), isArabic ? 'ar' : 'en');
    return formatter.format(dateTime);
  }

  /// الحصول على الفرق بين تاريخين بالأيام
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  /// التحقق من كون التاريخ اليوم
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  /// التحقق من كون التاريخ أمس
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
  }

  /// التحقق من كون التاريخ غداً
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day;
  }

  /// الحصول على نص وصفي للتاريخ (اليوم، أمس، غداً، إلخ)
  static String getRelativeDateText(DateTime date, {bool isArabic = true}) {
    if (isToday(date)) {
      return isArabic ? 'اليوم' : 'Today';
    } else if (isYesterday(date)) {
      return isArabic ? 'أمس' : 'Yesterday';
    } else if (isTomorrow(date)) {
      return isArabic ? 'غداً' : 'Tomorrow';
    } else {
      return formatDate(date, isArabic: isArabic);
    }
  }

  /// الحصول على بداية اليوم
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// الحصول على نهاية اليوم
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// الحصول على بداية الأسبوع
  static DateTime startOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return startOfDay(date.subtract(Duration(days: daysFromMonday)));
  }

  /// الحصول على نهاية الأسبوع
  static DateTime endOfWeek(DateTime date) {
    final daysToSunday = 7 - date.weekday;
    return endOfDay(date.add(Duration(days: daysToSunday)));
  }

  /// الحصول على بداية الشهر
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// الحصول على نهاية الشهر
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  /// تحويل النص إلى تاريخ
  static DateTime? parseDate(String dateString, {String? format}) {
    try {
      final formatter = DateFormat(format ?? defaultDateFormat);
      return formatter.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// الحصول على قائمة بالأيام في الشهر
  static List<DateTime> getDaysInMonth(DateTime date) {
    final firstDay = startOfMonth(date);
    final lastDay = endOfMonth(date);
    final days = <DateTime>[];
    
    for (var day = firstDay; day.isBefore(lastDay) || day.isAtSameMomentAs(lastDay); day = day.add(const Duration(days: 1))) {
      days.add(day);
    }
    
    return days;
  }

  /// الحصول على عدد الأيام في الشهر
  static int getDaysCountInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  /// التحقق من كون السنة كبيسة
  static bool isLeapYear(int year) {
    return (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);
  }

  /// الحصول على اسم الشهر
  static String getMonthName(int month, {bool isArabic = true}) {
    if (isArabic) {
      const arabicMonths = [
        'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
        'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
      ];
      return arabicMonths[month - 1];
    } else {
      const englishMonths = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return englishMonths[month - 1];
    }
  }

  /// الحصول على اسم اليوم
  static String getDayName(int weekday, {bool isArabic = true}) {
    if (isArabic) {
      const arabicDays = [
        'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'
      ];
      return arabicDays[weekday - 1];
    } else {
      const englishDays = [
        'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
      ];
      return englishDays[weekday - 1];
    }
  }
}