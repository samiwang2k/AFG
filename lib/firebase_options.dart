// File generated by FlutterFire CLI.
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
    apiKey: 'AIzaSyDOer_GpRvu2ZOvYNUDUuF93JnjVDDgAeQ',
    appId: '1:533992936885:web:a1b1a2592e4c9321bf35fc',
    messagingSenderId: '533992936885',
    projectId: 'jevents-afg',
    authDomain: 'jevents-afg.firebaseapp.com',
    storageBucket: 'jevents-afg.appspot.com',
    measurementId: 'G-RQGD3NC2P7',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDbffRp_QEKJnfMj4zal_mPvj9Hq8_3l_c',
    appId: '1:533992936885:android:2b1e328ed228975bbf35fc',
    messagingSenderId: '533992936885',
    projectId: 'jevents-afg',
    storageBucket: 'jevents-afg.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAOQFgFNlroJsYMlp67gac0_QMCCUfyokE',
    appId: '1:533992936885:ios:18d117bb88de5481bf35fc',
    messagingSenderId: '533992936885',
    projectId: 'jevents-afg',
    storageBucket: 'jevents-afg.appspot.com',
    iosBundleId: 'com.example.afg',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAOQFgFNlroJsYMlp67gac0_QMCCUfyokE',
    appId: '1:533992936885:ios:18d117bb88de5481bf35fc',
    messagingSenderId: '533992936885',
    projectId: 'jevents-afg',
    storageBucket: 'jevents-afg.appspot.com',
    iosBundleId: 'com.example.afg',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDOer_GpRvu2ZOvYNUDUuF93JnjVDDgAeQ',
    appId: '1:533992936885:web:410a95bf10abe353bf35fc',
    messagingSenderId: '533992936885',
    projectId: 'jevents-afg',
    authDomain: 'jevents-afg.firebaseapp.com',
    storageBucket: 'jevents-afg.appspot.com',
    measurementId: 'G-93M9BEC43F',
  );
}
