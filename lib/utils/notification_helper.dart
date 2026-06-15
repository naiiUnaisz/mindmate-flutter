import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {},
    );

    // Create notification channels for Android
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'break_reminder',
          'Break Reminder',
          description: 'Reminds you to take a break',
          importance: Importance.high,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'streak_reminder',
          'Streak Reminder',
          description: 'Reminds you to log your daily mood and keep your streak alive',
          importance: Importance.high,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'relax_reminder',
          'Relax Session Reminder',
          description: 'Reminds you to return before your relax session expires',
          importance: Importance.high,
        ),
      );
    }
  }

  static Future<bool> _getSetting(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('current_user_email')?.toLowerCase();
    final prefix = email != null ? '${email}_' : '';
    return prefs.getBool('${prefix}$key') ?? false;
  }

  /// Schedule break reminder daily at 10:00 AM.
  static Future<void> scheduleBreakReminder() async {
    await init();
    final enabled = await _getSetting('break_reminder');
    if (!enabled) return;

    await _plugin.cancel(1);

    await _plugin.zonedSchedule(
      1,
      'Break Reminder ☕',
      'Time to take a short break! Rest your eyes and stretch.',
      _nextInstanceOfTime(10, 0),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'break_reminder',
          'Break Reminder',
          channelDescription: 'Reminds you to take a break',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Schedule streak/mood reminder daily at 8:00 AM.
  static Future<void> scheduleStreakReminder() async {
    await init();
    final enabled = await _getSetting('streak_reminder');
    if (!enabled) return;

    await _plugin.cancel(2);

    await _plugin.zonedSchedule(
      2,
      'Daily Mood Reminder 🔥',
      'Selamat pagi! Jangan lupa catat mood harianmu hari ini agar streak tetap terjaga!',
      _nextInstanceOfTime(8, 0),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'streak_reminder',
          'Streak Reminder',
          channelDescription: 'Reminds you to log your daily mood and keep your streak alive',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Schedule a relax session reminder that fires [minutesBeforeExpiry]
  /// minutes before the session [expiresAt] time.
  static Future<void> scheduleRelaxReminder({
    required String appName,
    required DateTime expiresAt,
    int minutesBeforeExpiry = 2,
  }) async {
    await init();

    final reminderTime = expiresAt.subtract(Duration(minutes: minutesBeforeExpiry));

    if (reminderTime.isBefore(DateTime.now())) return;

    await _plugin.zonedSchedule(
      100,
      '⏰ Waktu Habis $appName',
      'Waktu anda tinggal $minutesBeforeExpiry menit, silahkan kembali ke aplikasi agar tidak kehilangan koin!',
      tz.TZDateTime.from(reminderTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'relax_reminder',
          'Relax Session Reminder',
          channelDescription: 'Reminds you to return before your relax session expires',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
          fullScreenIntent: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancel the relax session reminder.
  static Future<void> cancelRelaxReminder() async {
    await init();
    await _plugin.cancel(100);
  }

  static Future<void> cancelAll() async {
    await init();
    await _plugin.cancelAll();
  }

  static Future<void> cancelBreakReminder() async {
    await init();
    await _plugin.cancel(1);
  }

  static Future<void> cancelStreakReminder() async {
    await init();
    await _plugin.cancel(2);
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
