import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:play_on_app/repo/notification_repository.dart';
import 'package:play_on_app/utils/hive_service/hive_service.dart';
import 'package:play_on_app/view_model/after_controller/notification_controller.dart';
import 'package:play_on_app/data/network/firebase_options.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

// 🔥 TOP-LEVEL BACKGROUND HANDLER (Must be top-level for reliability)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }
    print("📩 BACKGROUND MESSAGE RECEIVED: ${message.messageId}");
    
    // Initialize local notifications for background process
    final FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();
    
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    
    await localNotifications.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    // Ensure channel exists in background
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'playon_high_importance',
      'PlayOn Notifications',
      description: 'Important notifications from PlayOn',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Show the notification
    await NotificationService.showNotificationInternal(message, localNotifications);
  } catch (e) {
    print("❌ Error in background handler: $e");
  }
}

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  static final NotificationRepository _repo = NotificationRepository();

  // 🔥 INIT
  static Future<void> init() async {
    try {
      print("🔔 Initializing NotificationService...");

      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings();

      await _localNotifications.initialize(
        const InitializationSettings(android: android, iOS: ios),
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          _handleLocalNotificationClick(response);
        },
      );

      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'playon_high_importance',
        'PlayOn Notifications',
        description: 'Important notifications from PlayOn',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      // Request Android 13+ permission
      if (Platform.isAndroid) {
        await _localNotifications
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      }

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // iOS Foreground Notification options
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 1. Listen for messages when app is in foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("📩 FOREGROUND MESSAGE RECEIVED");
        showNotificationInternal(message, _localNotifications);
      });

      // 2. Listen for messages when app is in background but opened via notification
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print("📩 MESSAGE OPENED APP FROM BACKGROUND");
        _handleNotificationClick(message);
      });

      // 3. Check if app was opened from a terminated state via notification
      RemoteMessage? initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        print("📩 APP OPENED FROM TERMINATED STATE VIA NOTIFICATION");
        // Delay navigation to ensure GetX and Navigator are fully ready
        Future.delayed(const Duration(seconds: 2), () {
          _handleNotificationClick(initialMessage);
        });
      }

      // 4. Token refresh listener
      _messaging.onTokenRefresh.listen((newToken) {
        print("🎫 FCM TOKEN REFRESHED: $newToken");
        syncTokenToServer();
      });

      String? token = await _messaging.getToken();
      print("🎫 FCM TOKEN = $token");

      await requestPermissionAndSync();
      print("✅ NotificationService Init Complete");
    } catch (e) {
      print("❌ Error initializing notifications: $e");
    }
  }

  // 🔥 REQUEST PERMISSION AND SYNC TOKEN
  static Future<void> requestPermissionAndSync() async {
    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('User granted permission');
        await syncTokenToServer();
      } else {
        print('User declined or has not accepted permission');
      }
    } catch (e) {
      print("❌ Error requesting permission: $e");
    }
  }

  // 🔥 PUBLIC METHOD TO SYNC TOKEN
  static Future<void> syncTokenToServer() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      String? token = await _messaging.getToken();
      if (HiveService.isLogin() && token != null && token.isNotEmpty) {
        print("🚀 Syncing FCM Token...");
        await _repo.updateFcmToken(token);
      }
    } catch (e) {
      print("❌ ERROR SYNCING TOKEN: $e");
    }
  }

  // 🔥 SCHEDULE NOTIFICATION
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      if (scheduledDate.isBefore(DateTime.now())) {
        _showImmediateNotification(id, title, body);
        return;
      }

      const androidDetails = AndroidNotificationDetails(
        'playon_high_importance',
        'PlayOn Notifications',
        channelDescription: 'Important notifications from PlayOn',
        importance: Importance.max,
        priority: Priority.max,
        icon: '@mipmap/ic_launcher',
        playSound: true,
      );

      await _localNotifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      print("❌ Error scheduling notification: $e");
    }
  }

  static Future<void> _showImmediateNotification(int id, String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'playon_high_importance',
      'PlayOn Notifications',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
    );
    await _localNotifications.show(id, title, body, const NotificationDetails(android: androidDetails));
  }

  static Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  // 🔥 SHOW NOTIFICATION INTERNAL
  static Future<void> showNotificationInternal(RemoteMessage message, FlutterLocalNotificationsPlugin plugin) async {
    try {
      print("🔔 Preparing notification display...");
      RemoteNotification? notification = message.notification;

      String title = notification?.title ?? message.data['title'] ?? "PlayOn";
      String body = notification?.body ?? message.data['message'] ?? message.data['body'] ?? "New message";
      String? imageUrl = message.data['image'] ?? message.data['imageUrl'] ?? notification?.android?.imageUrl;

      BigPictureStyleInformation? bigPictureStyle;
      String? localImagePath;

      if (imageUrl != null && imageUrl.isNotEmpty && imageUrl.startsWith('http')) {
        try {
          final String fileName = 'notification_img_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final String? downloadedPath = await _downloadAndSaveFile(imageUrl, fileName);
          if (downloadedPath != null) {
            localImagePath = downloadedPath;
            bigPictureStyle = BigPictureStyleInformation(
              FilePathAndroidBitmap(localImagePath),
              largeIcon: FilePathAndroidBitmap(localImagePath),
              contentTitle: title,
              summaryText: body,
            );
          }
        } catch (e) {
          print("⚠️ Error downloading notification image: $e");
        }
      }

      final androidDetails = AndroidNotificationDetails(
        'playon_high_importance',
        'PlayOn Notifications',
        channelDescription: 'Important notifications from PlayOn',
        importance: Importance.max,
        priority: Priority.max,
        icon: '@mipmap/ic_launcher',
        styleInformation: bigPictureStyle,
        largeIcon: localImagePath != null ? FilePathAndroidBitmap(localImagePath) : null,
        playSound: true,
        enableVibration: true,
        showWhen: true,
        autoCancel: true,
        visibility: NotificationVisibility.public,
      );

      final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

      await plugin.show(
        notificationId,
        title,
        body,
        NotificationDetails(
          android: androidDetails,
          iOS: DarwinNotificationDetails(
            attachments: localImagePath != null ? [DarwinNotificationAttachment(localImagePath)] : null,
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
      print("🚀 Notification displayed in tray: $notificationId");
    } catch (e) {
      print("❌ Error showing notification internal: $e");
    }
  }

  static Future<String?> _downloadAndSaveFile(String url, String fileName) async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final String filePath = '${directory.path}/$fileName';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      }
    } catch (e) {
      print("❌ Download Error: $e");
    }
    return null;
  }

  static void _handleNotificationClick(RemoteMessage message) {
    if (Get.isRegistered<NotificationController>()) {
      Get.find<NotificationController>().refreshData();
    }
    Get.toNamed('/notification');
  }

  static void _handleLocalNotificationClick(NotificationResponse response) {
    if (Get.isRegistered<NotificationController>()) {
      Get.find<NotificationController>().refreshData();
    }
    Get.toNamed('/notification');
  }
}
