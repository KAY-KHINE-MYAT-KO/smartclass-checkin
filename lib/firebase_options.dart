import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBkm_example_web_api_key',
    appId: '1:123456789:web:abcdef123456',
    messagingSenderId: '123456789',
    projectId: 'smart-class-checkin',
    authDomain: 'smart-class-checkin.firebaseapp.com',
    databaseURL: 'https://smart-class-checkin.firebaseio.com',
    storageBucket: 'smart-class-checkin.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBkm_example_android_api_key',
    appId: '1:123456789:android:abcdef123456',
    messagingSenderId: '123456789',
    projectId: 'smart-class-checkin',
    databaseURL: 'https://smart-class-checkin.firebaseio.com',
    storageBucket: 'smart-class-checkin.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBkm_example_ios_api_key',
    appId: '1:123456789:ios:abcdef123456',
    messagingSenderId: '123456789',
    projectId: 'smart-class-checkin',
    databaseURL: 'https://smart-class-checkin.firebaseio.com',
    storageBucket: 'smart-class-checkin.appspot.com',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBkm_example_macos_api_key',
    appId: '1:123456789:macos:abcdef123456',
    messagingSenderId: '123456789',
    projectId: 'smart-class-checkin',
    databaseURL: 'https://smart-class-checkin.firebaseio.com',
    storageBucket: 'smart-class-checkin.appspot.com',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBkm_example_windows_api_key',
    appId: '1:123456789:windows:abcdef123456',
    messagingSenderId: '123456789',
    projectId: 'smart-class-checkin',
    databaseURL: 'https://smart-class-checkin.firebaseio.com',
    storageBucket: 'smart-class-checkin.appspot.com',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyBkm_example_linux_api_key',
    appId: '1:123456789:linux:abcdef123456',
    messagingSenderId: '123456789',
    projectId: 'smart-class-checkin',
    databaseURL: 'https://smart-class-checkin.firebaseio.com',
    storageBucket: 'smart-class-checkin.appspot.com',
  );
}
