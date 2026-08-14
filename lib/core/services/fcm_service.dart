import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Top-level function for handling background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if necessary here when dealing with real implementation.
  debugPrint("Handling a background message: ${message.messageId}");
}

class FCMService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. Request Permission (iOS / Web)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }

    // 2. Setup Background Handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. Setup Local Notifications for Foreground display
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _localNotificationsPlugin.initialize(initializationSettings);

    // 4. Listen to Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint('Message also contained a notification: ${message.notification}');
        _showLocalNotification(message);
      }
    });

    // 5. Get Token (to send to backend)
    String? token = await _firebaseMessaging.getToken();
    debugPrint("FCM Token: $token");
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final String? type = message.data['type']; // 'alerte_ia', 'statut_devis', 'rapport', 'message'
    
    String channelId = 'chantier_track_default';
    String channelName = 'Notifications Générales';
    Importance importance = Importance.defaultImportance;
    Priority priority = Priority.defaultPriority;

    if (type == 'alerte_ia') {
      channelId = 'chantier_track_alerts';
      channelName = 'Alertes IA Critiques';
      importance = Importance.max;
      priority = Priority.high;
    } else if (type == 'message') {
      channelId = 'chantier_track_messages';
      channelName = 'Messages';
      importance = Importance.high;
      priority = Priority.high;
    }

    final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: importance,
      priority: priority,
    );
    
    final NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await _localNotificationsPlugin.show(
      message.notification.hashCode,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
    );
  }
}
