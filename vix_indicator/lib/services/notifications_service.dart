import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationsService {
    static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

    static Future<void> initialize() async {
        const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
        const settings = InitializationSettings(android: androidSettings);
        await _notificationsPlugin.initialize(settings);
    }

    static Future<void> showNotification({
        required String title,
        required String body,
    }) async {
        const details = NotificationDetails(
            android: AndroidNotificationDetails(
                'default_channel', 
                'Default Channel', 
                channelDescription: 'Default channel for notifications',
                importance: Importance.high,
                priority: Priority.high,
            ),
        );

        await _notificationsPlugin.show(0, title, body, details);
    }
}