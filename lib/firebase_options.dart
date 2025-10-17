// lib/firebase_options.dart

// File modified to use --dart-define for environment variables.
// ignore_for_file: type=lint

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: String.fromEnvironment('WEB_API_KEY'),
    appId: String.fromEnvironment('WEB_APP_ID'),
    messagingSenderId: String.fromEnvironment('MESSAGING_SENDER_ID'),
    projectId: String.fromEnvironment('PROJECT_ID'),
    authDomain: String.fromEnvironment('WEB_AUTH_DOMAIN'),
    storageBucket: String.fromEnvironment('STORAGE_BUCKET'),
    measurementId: String.fromEnvironment('WEB_MEASUREMENT_ID'),
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: String.fromEnvironment('ANDROID_API_KEY'),
    appId: String.fromEnvironment('ANDROID_APP_ID'),
    messagingSenderId: String.fromEnvironment('MESSAGING_SENDER_ID'),
    projectId: String.fromEnvironment('PROJECT_ID'),
    storageBucket: String.fromEnvironment('STORAGE_BUCKET'),
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: String.fromEnvironment('IOS_API_KEY'),
    appId: String.fromEnvironment('IOS_APP_ID'),
    messagingSenderId: String.fromEnvironment('MESSAGING_SENDER_ID'),
    projectId: String.fromEnvironment('PROJECT_ID'),
    storageBucket: String.fromEnvironment('STORAGE_BUCKET'),
    iosBundleId: String.fromEnvironment('IOS_BUNDLE_ID'),
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: String.fromEnvironment('IOS_API_KEY'),
    appId: String.fromEnvironment('IOS_APP_ID'),
    messagingSenderId: String.fromEnvironment('MESSAGING_SENDER_ID'),
    projectId: String.fromEnvironment('PROJECT_ID'),
    storageBucket: String.fromEnvironment('STORAGE_BUCKET'),
    iosBundleId: String.fromEnvironment('IOS_BUNDLE_ID'),
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: String.fromEnvironment('WINDOWS_API_KEY'),
    appId: String.fromEnvironment('WINDOWS_APP_ID'),
    messagingSenderId: String.fromEnvironment('MESSAGING_SENDER_ID'),
    projectId: String.fromEnvironment('PROJECT_ID'),
    authDomain: String.fromEnvironment('WINDOWS_AUTH_DOMAIN'),
    storageBucket: String.fromEnvironment('STORAGE_BUCKET'),
    measurementId: String.fromEnvironment('WINDOWS_MEASUREMENT_ID'),
  );
}
