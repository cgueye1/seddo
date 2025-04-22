import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
class PushNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @pragma('vm:entry-point')
  PushNotificationService();

  Future<void> initialize() async {
    await Firebase.initializeApp();

    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Permissions granted');
    }

    await _setupLocalNotifications();

    String? token = await _firebaseMessaging.getToken();
    print("FCM Token: $token");

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpened);
  }

  Future<void> _setupLocalNotifications() async {
    // Configuration Android avec icône par défaut
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Création du canal de notification pour Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'Important Notifications',
      description: 'Channel for important notifications',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('ringtone'),
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
    final service = PushNotificationService();
    await service._showNotification(message);
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    await _showNotification(message);
  }

  Future<void> _handleNotificationOpened(RemoteMessage message) async {
    print('Notification opened: ${message.messageId}');
  }

  Future<void> _showNotification(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    final bool shouldRing = data['ring'] == 'true';

    // Configuration Android
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'high_importance_channel',
      'Important Notifications',
      channelDescription: 'Channel for important notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: shouldRing ? RawResourceAndroidNotificationSound('ringtone') : null,
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      icon: '@mipmap/ic_launcher', // Utilise l'icône de l'application
    );

    // Configuration iOS
    const DarwinNotificationDetails iosPlatformChannelSpecifics =
    DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'ringtone.caf',
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: shouldRing ? iosPlatformChannelSpecifics : null,
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // ID unique
      notification?.title ?? 'New notification',
      notification?.body ?? 'You have a new message',
      platformChannelSpecifics,
      payload: message.data.toString(),
    );

    if (shouldRing) {
      try {
        if (await Vibration.hasVibrator() ?? false) {
          await Vibration.vibrate(
            pattern: [500, 1000, 500, 1000],
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print('Vibration error: $e');
        }
      }
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }
}