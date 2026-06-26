import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions not supported for this platform.',
        );
    }
  }

  // ── Rellena con los valores de tu proyecto Firebase ──
  // Ve a Firebase Console → Project Settings → General → Tus apps

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'API_KEY',
    appId: 'APP_ID',
    messagingSenderId: 'SENDER_ID',
    projectId: 'PROJECT_ID',
    authDomain: 'PROJECT_ID.firebaseapp.com',
    storageBucket: 'PROJECT_ID.appspot.com',
    measurementId: 'G-MEASUREMENT_ID',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'API_KEY',
    appId: 'APP_ID',
    messagingSenderId: 'SENDER_ID',
    projectId: 'PROJECT_ID',
    storageBucket: 'PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'API_KEY',
    appId: 'APP_ID',
    messagingSenderId: 'SENDER_ID',
    projectId: 'PROJECT_ID',
    storageBucket: 'PROJECT_ID.appspot.com',
    iosClientId: 'IOS_CLIENT_ID',
    iosBundleId: 'BUNDLE_ID',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'API_KEY',
    appId: 'APP_ID',
    messagingSenderId: 'SENDER_ID',
    projectId: 'PROJECT_ID',
    storageBucket: 'PROJECT_ID.appspot.com',
    iosClientId: 'IOS_CLIENT_ID',
    iosBundleId: 'BUNDLE_ID',
  );
}
