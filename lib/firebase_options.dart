// File generated by FlutterFire CLI.
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
    apiKey: 'AIzaSyBhUXebmUEbe01MGHx4e8juwryBAyfm264',
    appId: '1:855978759795:web:4577753a2979a8edba7c06',
    messagingSenderId: '855978759795',
    projectId: 'testapp-305b7',
    authDomain: 'testapp-305b7.firebaseapp.com',
    storageBucket: 'testapp-305b7.firebasestorage.app',
    measurementId: 'G-XH2NRMWRNJ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBMfF1nR5Lu1-Ux5Gg8i8-mDhF3OBva26E',
    appId: '1:855978759795:android:52e9ce003480c120ba7c06',
    messagingSenderId: '855978759795',
    projectId: 'testapp-305b7',
    storageBucket: 'testapp-305b7.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDt1ofhp-4ge4umT2ds6VNmGwW3cM8ImzQ',
    appId: '1:855978759795:ios:c0d3b15abc267366ba7c06',
    messagingSenderId: '855978759795',
    projectId: 'testapp-305b7',
    storageBucket: 'testapp-305b7.firebasestorage.app',
    iosBundleId: 'com.example.weatherApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDt1ofhp-4ge4umT2ds6VNmGwW3cM8ImzQ',
    appId: '1:855978759795:ios:c0d3b15abc267366ba7c06',
    messagingSenderId: '855978759795',
    projectId: 'testapp-305b7',
    storageBucket: 'testapp-305b7.firebasestorage.app',
    iosBundleId: 'com.example.weatherApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBhUXebmUEbe01MGHx4e8juwryBAyfm264',
    appId: '1:855978759795:web:caa39d1f864e85efba7c06',
    messagingSenderId: '855978759795',
    projectId: 'testapp-305b7',
    authDomain: 'testapp-305b7.firebaseapp.com',
    storageBucket: 'testapp-305b7.firebasestorage.app',
    measurementId: 'G-T38DJNJ081',
  );
}
