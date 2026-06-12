import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings);
    _initialized = true;
  }

  static Future<void> showMatchNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'match_channel',
          'Match Notifications',
          channelDescription: 'World Cup match alerts',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  static Future<void> scheduleMatchReminder({
    required int matchId,
    required String homeTeam,
    required String awayTeam,
    required DateTime matchTime,
  }) async {
    // Calculate 15 min before match
    final remindAt = matchTime.subtract(const Duration(minutes: 15));
    final now = DateTime.now();
    if (remindAt.isBefore(now)) return;

    final delay = remindAt.difference(now);
    await Future.delayed(delay, () {
      showMatchNotification(
        id: matchId,
        title: 'Match Starting Soon!',
        body: '$homeTeam vs $awayTeam kicks off in 15 minutes',
      );
    });
  }
}
