import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web not supported');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('This platform is not supported');
    }
  }

  // ✅ iOS values — GoogleService-Info.plist se liye hain
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDDBJXnBe4w6rn3w9R7i89KiIMS8lpA7dI',
    appId: '1:257271466858:ios:1b1de90e84ee66402fb313',
    messagingSenderId: '257271466858',
    projectId: 'playon-89168',
    storageBucket: 'playon-89168.firebasestorage.app',
    iosBundleId: 'com.cametech.playon',
    iosClientId: '257271466858-f1t04b696n2pd4boiebpcsagjq7sc5e0.apps.googleusercontent.com',
  );

  // ✅ Android values — google-services.json se lo
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC-sqlL40uvTiYmc2vSu2Sp5CM2kTEiHqw',        // google-services.json → api_key → current_key
    appId: '1:257271466858:android:dea14030f15a33fe2fb313',          // google-services.json → mobilesdk_app_id
    messagingSenderId: '257271466858',
    projectId: 'playon-89168',
    storageBucket: 'playon-89168.firebasestorage.app',
  );
}