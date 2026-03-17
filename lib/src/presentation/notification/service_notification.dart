import 'dart:io';
import 'package:devalay_app/src/core/shared_preference.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:devalay_app/src/presentation/notification/web_socket/web_socket.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // For iOS, wait for APNS token before getting FCM token
    String? token;
    if (Platform.isIOS) {
      // Get APNS token first
      // String? apnsToken = await _messaging.getAPNSToken();
      
      // if (apnsToken != null) {
      //   print('APNS Token: $apnsToken');
      //   // Now get FCM token
      //   token = await _messaging.getToken();
      // } else {
      //   print('APNS token not available yet, waiting...');
      //   // Listen for APNS token
      //   _messaging.onTokenRefresh.listen((fcmToken) {
      //     print('FCM Token refreshed: $fcmToken');
      //     PrefManager.setFcmToken(fcmToken);
      //   });
        
      //   // Try to get token with a delay
      //   await Future.delayed(const Duration(seconds: 2));
      //   token = await _messaging.getToken();
      // }
    } else {
      // For Android, directly get FCM token
      token = await _messaging.getToken();
    }

    print('FCM Token: $token');
    if (token != null) {
      PrefManager.setFcmToken(token);
    }

    // Android settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Final init settings for both platforms
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize the local notifications plugin
    await _localNotificationsPlugin.initialize(
      initializationSettings,
    );

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showNotification(message);

      // Increment unread count for real-time UI update
      try {
        NotificationSocketService().incrementNotificationCount();
      } catch (_) {}

      Fluttertoast.showToast(
        msg: message.notification?.title ?? 'New Notification',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
      );
    });

    // Handle messages when the app is opened from a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App opened from notification: ${message.notification?.title}');
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
    print('Handling background message: ${message.notification?.title}');
  }

  static Future<void> showNotification(RemoteMessage message) async {
    if (Platform.isAndroid) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'your_channel_id',
        'your_channel_name',
        icon: 'ic_notification',
        channelDescription: 'your_channel_description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _localNotificationsPlugin.show(
        0,
        message.notification?.title ?? 'No title',
        message.notification?.body ?? 'No body',
        platformChannelSpecifics,
      );
    } else {
      // iOS handles notifications differently
      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(iOS: iOSPlatformChannelSpecifics);

      await _localNotificationsPlugin.show(
        0,
        message.notification?.title ?? 'No title',
        message.notification?.body ?? 'No body',
        platformChannelSpecifics,
      );
    }
  }
}