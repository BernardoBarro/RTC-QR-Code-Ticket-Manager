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
    apiKey: 'AIzaSyAq9cXFXfA9X3BHBwOGf4EpYUGEgEfcSuA',
    appId: '1:144470287922:web:b212fee229bc5885ba7e2b',
    messagingSenderId: '144470287922',
    projectId: 'rtc-project-9bb1d',
    authDomain: 'rtc-project-9bb1d.firebaseapp.com',
    storageBucket: 'rtc-project-9bb1d.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAf-VifXzAcdz8TY3uhJFc0zs91A5QbRbc',
    appId: '1:144470287922:android:15a4ecd534247db5ba7e2b',
    messagingSenderId: '144470287922',
    projectId: 'rtc-project-9bb1d',
    storageBucket: 'rtc-project-9bb1d.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCHmdduJ9g4sEOhgcofpMoBoJbVmedVb_Q',
    appId: '1:144470287922:ios:2933484dce774b76ba7e2b',
    messagingSenderId: '144470287922',
    projectId: 'rtc-project-9bb1d',
    storageBucket: 'rtc-project-9bb1d.appspot.com',
    iosBundleId: 'com.example.rtcProject',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCHmdduJ9g4sEOhgcofpMoBoJbVmedVb_Q',
    appId: '1:144470287922:ios:2933484dce774b76ba7e2b',
    messagingSenderId: '144470287922',
    projectId: 'rtc-project-9bb1d',
    storageBucket: 'rtc-project-9bb1d.appspot.com',
    iosBundleId: 'com.example.rtcProject',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAq9cXFXfA9X3BHBwOGf4EpYUGEgEfcSuA',
    appId: '1:144470287922:web:e34844fa74ec1e44ba7e2b',
    messagingSenderId: '144470287922',
    projectId: 'rtc-project-9bb1d',
    authDomain: 'rtc-project-9bb1d.firebaseapp.com',
    storageBucket: 'rtc-project-9bb1d.appspot.com',
  );

}