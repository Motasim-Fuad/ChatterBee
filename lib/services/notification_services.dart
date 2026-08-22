import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint(' [BG] Message received: ${message.messageId}');
}

class NotificationPayload {
  final String? title;
  final String? body;
  final Map<String, dynamic> data;

  const NotificationPayload({
    this.title,
    this.body,
    this.data = const {},
  });

  factory NotificationPayload.fromRemoteMessage(RemoteMessage message) {
    return NotificationPayload(
      title: message.notification?.title,
      body: message.notification?.body,
      data: message.data,
    );
  }
}

class NotificationService extends GetxService {
  static NotificationService get to => Get.find();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  final RxnString fcmToken = RxnString();
  void Function(NotificationPayload payload)? onNotificationTap;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Used for important notifications.',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  Future<NotificationService> init() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _requestPermission();
    await _initLocalNotifications();
    await _createAndroidChannel();

    await _getFcmTokenOnly();

    _listenForeground();
    _listenBackgroundTap();
    await _handleTerminatedLaunch();

    debugPrint('✅ NotificationService ready (foreground + background)');
    return this;
  }

  Future<void> _requestPermission() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );
    debugPrint('🔐 Permission: ${settings.authorizationStatus}');
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
      onDidReceiveBackgroundNotificationResponse: _onLocalNotificationTap,
    );
  }

  Future<void> _createAndroidChannel() async {
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
    }
  }

  Future<void> _getFcmTokenOnly() async {
    if (Platform.isIOS) {
      String? apns;
      for (int i = 0; i < 15; i++) {
        apns = await _fcm.getAPNSToken();
        if (apns != null) break;
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    try {
      final token = await _fcm.getToken();
      fcmToken.value = token;
      debugPrint(' FCM Token: ${token ?? "null"}');
    } catch (e) {
      debugPrint(' FCM getToken() failed: $e');
    }
  }

  void _listenForeground() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(' [FG] ${message.notification?.title}');
      _showLocalNotification(message);
    });
  }

  void _listenBackgroundTap() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint(' [BG Tap] ${message.messageId}');
      _handlePayload(NotificationPayload.fromRemoteMessage(message));
    });
  }

  Future<void> _handleTerminatedLaunch() async {
    final message = await _fcm.getInitialMessage();
    if (message != null) {
      debugPrint(' [Terminated] ${message.messageId}');
      Future.delayed(const Duration(milliseconds: 500), () {
        _handlePayload(NotificationPayload.fromRemoteMessage(message));
      });
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final title = message.notification?.title ?? message.data['title'];
    final body = message.notification?.body ?? message.data['body'];

    try {
      await _localNotifications.show(
        message.hashCode,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } catch (e) {
      debugPrint(' Local notification error: $e');
    }
  }

  Future<void> showNotification({
    required String title,
    required String body,
    Map<String, String> data = const {},
  }) async {
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  void _handlePayload(NotificationPayload payload) {
    onNotificationTap?.call(payload);
  }

  @pragma('vm:entry-point')
  static void _onLocalNotificationTap(NotificationResponse response) {
    if (Get.isRegistered<NotificationService>()) {
      NotificationService.to._handlePayload(
        NotificationPayload(data: {'payload': response.payload ?? ''}),
      );
    }
  }
}
