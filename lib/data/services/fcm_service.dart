import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, debugPrint;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@pragma('vm:entry-point')
Future<void> _fcmBackgroundHandler(RemoteMessage message) async {}

class FcmService {
  final SupabaseClient _client;
  final FlutterLocalNotificationsPlugin _notif = FlutterLocalNotificationsPlugin();
  String? _token;
  bool _initialized = false;

  FcmService(this._client);

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    if (!kIsWeb) {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings();
      await _notif.initialize(const InitializationSettings(android: android, iOS: ios));
    }

    FirebaseMessaging.onBackgroundMessage(_fcmBackgroundHandler);

    if (!kIsWeb) {
      final messaging = FirebaseMessaging.instance;
      try {
        await messaging.requestPermission(alert: true, badge: true, sound: true);
        _token = await messaging.getToken();
        messaging.onTokenRefresh.listen((t) {
          _token = t;
          _upsertToken(t);
        });
        FirebaseMessaging.onMessage.listen(_showNotification);
      } catch (e) {
        debugPrint('FCM init failed: $e');
      }
    }
  }

  Future<void> saveToken() async {
    if (_token != null) await _upsertToken(_token!);
  }

  Future<void> _upsertToken(String token) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return;
    final deviceInfo = kIsWeb ? 'web' : defaultTargetPlatform.name;
    await _client.from('device_tokens').upsert({
      'user_id': uid,
      'fcm_token': token,
      'device_info': deviceInfo,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id, fcm_token');
  }

  void _showNotification(RemoteMessage message) {
    final n = message.notification;
    if (n == null) return;
    _notif.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      n.title,
      n.body,
      const NotificationDetails(
        android: AndroidNotificationDetails('worldcup', 'World Cup 2026',
          importance: Importance.high, priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: message.data['route'] as String?,
    );
  }
}
