import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:play_on_app/repo/notification_repository.dart';
import 'package:play_on_app/utils/hive_service/hive_service.dart';
import 'package:play_on_app/view_model/after_controller/notification_controller.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  static final NotificationRepository _repo = NotificationRepository();

  // 🔥 BACKGROUND HANDLE
  @pragma('vm:entry-point')
  static Future<void> backgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();

    // 🔥 IMPORTANT: initialize local notification again
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    await _localNotifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    // If message contains a notification, Android handles it automatically in background
    // We only show local notification if it's a data-only message
    if (message.notification == null) {
      if (_shouldShowNotification(message)) {
        _showNotificationInternal(message);
      }
    }
  }

  // 🔥 INIT
  static Future<void> init() async {
    // ✅ Local Notification Init
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    await _localNotifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (response) {
        print("👉 LOCAL NOTIFICATION CLICKED");
        print("👉 Payload: ${response.payload}");
      },
    );

    print("✅ Local Notification Initialized");

    // ✅ Channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    print("✅ Notification Channel Created");

    // ✅ TOKEN DEBUG
    String? token = await _messaging.getToken();
    print("🔥 TOKEN (INIT): $token");

    // ✅ TOKEN REFRESH
    _messaging.onTokenRefresh.listen((newToken) {
      print("🔄 TOKEN REFRESHED: $newToken");
      syncTokenToServer();
    });

    // ✅ FOREGROUND LISTENER
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📩 FOREGROUND MESSAGE RECEIVED");
      print("📩 Title: ${message.notification?.title}");
      print("📩 Body: ${message.notification?.body}");
      print("📦 Data: ${message.data}");

      if (_shouldShowNotification(message)) {
        _showNotificationInternal(message);

        if (Get.isRegistered<NotificationController>()) {
          Get.find<NotificationController>().refreshData();
        }
      }
    });

    // ✅ BACKGROUND CLICK (APP OPEN FROM NOTIFICATION)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("📲 NOTIFICATION CLICKED (BACKGROUND)");
      print("📦 Data: ${message.data}");
    });

    // ✅ TERMINATED STATE CLICK
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      print("🚀 APP OPENED FROM TERMINATED STATE");
      print("📦 Data: ${initialMessage.data}");
    }

    print("✅ NotificationService INIT DONE");
    
    // Request permission and sync
    await requestPermissionAndSync();
  }

  static bool _shouldShowNotification(RemoteMessage message) {
    final user = HiveService.getUser();
    if (user != null && user.createdAt != null) {
      final userCreatedTime = user.createdAt!;

      // Attempt to get timestamp from message sentTime
      final messageTime = message.sentTime?.millisecondsSinceEpoch;

      if (messageTime != null) {
        // Only show if message was sent after user was created
        return messageTime > userCreatedTime;
      }
    }
    // If we can't determine, default to showing
    return true;
  }

  // 🔥 REQUEST PERMISSION AND SYNC TOKEN
  static Future<void> requestPermissionAndSync() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted permission');
      await syncTokenToServer();
    } else {
      print('User declined or has not accepted permission');
    }
  }


  // 🔥 PUBLIC METHOD TO SYNC TOKEN (Call this after login)
  static Future<void> syncTokenToServer() async {
    try {
      if (HiveService.isLogin()) {
        String? token = await _messaging.getToken();
        if (token != null) {
          print("🔥 Syncing FCM Token: $token");
          await _repo.updateFcmToken(token);
        }
      }
    } catch (e) {
      print("Error syncing token: $e");
    }
  }

  // 🔥 SHOW NOTIFICATION INTERNAL
  static Future<void> _showNotificationInternal(RemoteMessage message) async {
    print("🔔 SHOWING LOCAL NOTIFICATION");

    RemoteNotification? notification = message.notification;

    String title = notification?.title ?? message.data['title'] ?? "PlayOn";
    String body = notification?.body ?? message.data['message'] ?? message.data['body'] ?? "";

    if (title.isEmpty && body.isEmpty) return; // Don't show empty notifications

    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    await _localNotifications.show(
      message.hashCode,
      title,
      body,
      const NotificationDetails(android: androidDetails),
    );
  }
}
