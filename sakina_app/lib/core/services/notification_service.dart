import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// Comprehensive notification service for managing local notifications
///
/// Provides functionality for:
/// - Daily reminders for mood tracking
/// - One-time notifications for scheduled events
/// - Immediate notifications
/// - Notification management (cancel, query)
class NotificationService {
  NotificationService._privateConstructor();
  static final NotificationService instance = NotificationService._privateConstructor();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize the notification service
  ///
  /// Must be called before using any notification features.
  /// Configures Android and iOS notification settings and requests permissions.
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize timezone database
      tz_data.initializeTimeZones();
      // Set local timezone (defaults to UTC if local timezone cannot be determined)
      // Note: For production, consider using flutter_native_timezone package
      // to get the actual device timezone
      tz.setLocalLocation(tz.getLocation('UTC'));

      // Android initialization settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize plugin
      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Request permissions for iOS
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _requestIOSPermissions();
      }

      // Create Android notification channel
      await _createAndroidNotificationChannel();

      _initialized = true;
      debugPrint('NotificationService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing NotificationService: $e');
    }
  }

  /// Request notification permissions on iOS
  Future<bool> _requestIOSPermissions() async {
    try {
      final result = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              DarwinFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    } catch (e) {
      debugPrint('Error requesting iOS permissions: $e');
      return false;
    }
  }

  /// Create Android notification channel for high importance notifications
  Future<void> _createAndroidNotificationChannel() async {
    try {
      const androidChannel = AndroidNotificationChannel(
        'sakina_main_channel',
        'Sakina Notifications',
        description: 'Main notification channel for Sakina app',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);
    } catch (e) {
      debugPrint('Error creating Android notification channel: $e');
    }
  }

  /// Handle notification tap events
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // TODO: Implement navigation based on notification payload
    // This could navigate to specific screens based on the notification type
  }

  /// Schedule a daily repeating notification at a specific time
  ///
  /// [id] - Unique notification ID
  /// [title] - Notification title
  /// [body] - Notification body text
  /// [hour] - Hour of day (0-23)
  /// [minute] - Minute of hour (0-59)
  Future<bool> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    try {
      if (!_initialized) {
        await initialize();
      }

      // Cancel existing notification with the same ID to avoid duplicates
      await cancelNotification(id);

      // Create time for the notification
      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // If the time has passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduledDate,
        _notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
      );

      debugPrint('Daily notification scheduled: ID=$id at $hour:$minute');
      return true;
    } catch (e) {
      debugPrint('Error scheduling daily notification: $e');
      return false;
    }
  }

  /// Schedule a one-time notification for a specific date and time
  ///
  /// [id] - Unique notification ID
  /// [title] - Notification title
  /// [body] - Notification body text
  /// [scheduledDate] - DateTime when notification should be shown
  Future<bool> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      if (!_initialized) {
        await initialize();
      }

      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduledDate,
        _notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint('Notification scheduled: ID=$id at $scheduledDate');
      return true;
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
      return false;
    }
  }

  /// Show an immediate notification
  ///
  /// [id] - Unique notification ID
  /// [title] - Notification title
  /// [body] - Notification body text
  Future<bool> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      if (!_initialized) {
        await initialize();
      }

      await _notificationsPlugin.show(
        id,
        title,
        body,
        _notificationDetails(),
      );

      debugPrint('Immediate notification shown: ID=$id');
      return true;
    } catch (e) {
      debugPrint('Error showing notification: $e');
      return false;
    }
  }

  /// Cancel a specific notification by ID
  Future<bool> cancelNotification(int id) async {
    try {
      await _notificationsPlugin.cancel(id);
      debugPrint('Notification cancelled: ID=$id');
      return true;
    } catch (e) {
      debugPrint('Error cancelling notification: $e');
      return false;
    }
  }

  /// Cancel all scheduled notifications
  Future<bool> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      debugPrint('All notifications cancelled');
      return true;
    } catch (e) {
      debugPrint('Error cancelling all notifications: $e');
      return false;
    }
  }

  /// Get all pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      final pending = await _notificationsPlugin.pendingNotificationRequests();
      debugPrint('Pending notifications: ${pending.length}');
      return pending;
    } catch (e) {
      debugPrint('Error getting pending notifications: $e');
      return [];
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final result = await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.areNotificationsEnabled();
        return result ?? false;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        // iOS doesn't provide a direct way to check, assume true if initialized
        return _initialized;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking notification permissions: $e');
      return false;
    }
  }

  /// Get notification details for both platforms
  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'sakina_main_channel',
        'Sakina Notifications',
        channelDescription: 'Main notification channel for Sakina app',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }
}

/// Notification ID convention:
/// - 1: Daily mood tracking reminder
/// - 2: Weekly report notification
/// - 100+: Therapy session reminders
/// - 200+: Consultation reminders
class NotificationIds {
  static const int dailyMoodReminder = 1;
  static const int weeklyReport = 2;
  static const int therapySessionBase = 100;
  static const int consultationBase = 200;
}
