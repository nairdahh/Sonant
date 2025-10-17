// lib/firebase_options.dart - FIXED pentru Web

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

  // 🌐 WEB: Hardcoded (Firebase keys sunt PUBLICE - e OK!)
  // ✅ Aceste keys sunt SIGURE - protejate prin Firebase Security Rules
  static const FirebaseOptions web = FirebaseOptions(
    apiKey:
        'AIzaSyB8AOzUUeg4ne3BpVpj8z1Q5v8AjjmvDMc', // ← ÎnlocuieÈ™te cu al tău!
    appId:
        '1:114372126413:web:2e1680af9a8d751e972b84', // ← ÎnlocuieÈ™te cu al tău!
    messagingSenderId: '114372126413', // ← ÎnlocuieÈ™te cu al tău!
    projectId: 'sonant-c81f1', // ← ÎnlocuieÈ™te cu al tău!
    authDomain: 'sonant-c81f1.firebaseapp.com', // ← ÎnlocuieÈ™te cu al tău!
    storageBucket:
        'sonant-c81f1.firebasestorage.app', // ← ÎnlocuieÈ™te cu al tău!
    measurementId: 'G-ZQZD52Y0LE', // ← ÎnlocuieÈ™te cu al tău!
  );

  // 🤖 ANDROID: Din --dart-define (pentru builds production)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: String.fromEnvironment('ANDROID_API_KEY', defaultValue: ''),
    appId: String.fromEnvironment('ANDROID_APP_ID', defaultValue: ''),
    messagingSenderId:
        String.fromEnvironment('MESSAGING_SENDER_ID', defaultValue: ''),
    projectId: String.fromEnvironment('PROJECT_ID', defaultValue: ''),
    storageBucket: String.fromEnvironment('STORAGE_BUCKET', defaultValue: ''),
  );

  // 🍎 IOS: Din --dart-define
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: String.fromEnvironment('IOS_API_KEY', defaultValue: ''),
    appId: String.fromEnvironment('IOS_APP_ID', defaultValue: ''),
    messagingSenderId:
        String.fromEnvironment('MESSAGING_SENDER_ID', defaultValue: ''),
    projectId: String.fromEnvironment('PROJECT_ID', defaultValue: ''),
    storageBucket: String.fromEnvironment('STORAGE_BUCKET', defaultValue: ''),
    iosBundleId: String.fromEnvironment('IOS_BUNDLE_ID', defaultValue: ''),
  );

  // 🍎 MACOS: Același ca iOS
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: String.fromEnvironment('IOS_API_KEY', defaultValue: ''),
    appId: String.fromEnvironment('IOS_APP_ID', defaultValue: ''),
    messagingSenderId:
        String.fromEnvironment('MESSAGING_SENDER_ID', defaultValue: ''),
    projectId: String.fromEnvironment('PROJECT_ID', defaultValue: ''),
    storageBucket: String.fromEnvironment('STORAGE_BUCKET', defaultValue: ''),
    iosBundleId: String.fromEnvironment('IOS_BUNDLE_ID', defaultValue: ''),
  );

  // 🪟 WINDOWS: Din --dart-define
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: String.fromEnvironment('WINDOWS_API_KEY', defaultValue: ''),
    appId: String.fromEnvironment('WINDOWS_APP_ID', defaultValue: ''),
    messagingSenderId:
        String.fromEnvironment('MESSAGING_SENDER_ID', defaultValue: ''),
    projectId: String.fromEnvironment('PROJECT_ID', defaultValue: ''),
    authDomain: String.fromEnvironment('WINDOWS_AUTH_DOMAIN', defaultValue: ''),
    storageBucket: String.fromEnvironment('STORAGE_BUCKET', defaultValue: ''),
    measurementId:
        String.fromEnvironment('WINDOWS_MEASUREMENT_ID', defaultValue: ''),
  );
}
