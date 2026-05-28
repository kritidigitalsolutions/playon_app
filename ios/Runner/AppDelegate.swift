import UIKit
import Flutter
import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
  _ application: UIApplication,
  didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

//    FirebaseApp.configure()

    GeneratedPluginRegistrant.register(with: self)

    return super.application(
      application,
      didFinishLaunchingWithOptions: launchOptions
    )
  }
}
//
//import UIKit
//import Flutter
//import FirebaseCore
//import FirebaseMessaging
//import UserNotifications
//
//@main
//@objc class AppDelegate: FlutterAppDelegate, MessagingDelegate {
//
//  override func application(
//  _ application: UIApplication,
//  didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//  ) -> Bool {
//
//    // Firebase Initialize
//    FirebaseApp.configure()
//
//    // Notification Delegates
//    UNUserNotificationCenter.current().delegate = self
//    Messaging.messaging().delegate = self
//
//    // Notification Permission
//    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//
//    UNUserNotificationCenter.current().requestAuthorization(
//      options: authOptions
//    ) { granted, error in
//
//      if let error = error {
//        print("❌ Notification Permission Error: \(error.localizedDescription)")
//      }
//
//      print("✅ Notification Permission Granted: \(granted)")
//    }
//
//    application.registerForRemoteNotifications()
//
//    GeneratedPluginRegistrant.register(with: self)
//
//    return super.application(
//      application,
//      didFinishLaunchingWithOptions: launchOptions
//    )
//  }
//
//  // APNs Token
//  override func application(
//  _ application: UIApplication,
//  didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
//  ) {
//
//    Messaging.messaging().apnsToken = deviceToken
//
//    super.application(
//      application,
//      didRegisterForRemoteNotificationsWithDeviceToken: deviceToken
//    )
//  }
//
//  // FCM Token
//  func messaging(
//  _ messaging: Messaging,
//  didReceiveRegistrationToken fcmToken: String?
//  ) {
//
//    print("🔥 FCM TOKEN:")
//    print(fcmToken ?? "nil")
//  }
//
//  // Foreground Notification
//  override func userNotificationCenter(
//  _ center: UNUserNotificationCenter,
//  willPresent notification: UNNotification,
//  withCompletionHandler completionHandler:
//  @escaping (UNNotificationPresentationOptions) -> Void
//  ) {
//
//    completionHandler([.banner, .badge, .sound])
//  }
//
//  // Notification Tap
//  override func userNotificationCenter(
//  _ center: UNUserNotificationCenter,
//  didReceive response: UNNotificationResponse,
//  withCompletionHandler completionHandler: @escaping () -> Void
//  ) {
//
//    completionHandler()
//  }
//}