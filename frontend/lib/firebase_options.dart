import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart' show dotenv;

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
          'DefaultFirebaseOptions have not been configured for '
          '$defaultTargetPlatform.',
        );
    }
  }

  static FirebaseOptions get web => FirebaseOptions(
    apiKey: _require('FIREBASE_API_KEY'),
    appId: _require('FIREBASE_APP_ID'),
    messagingSenderId: _require('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: _require('FIREBASE_PROJECT_ID'),
    authDomain: _require('FIREBASE_AUTH_DOMAIN'),
    storageBucket: _require('FIREBASE_STORAGE_BUCKET'),
    measurementId: dotenv.env['FIREBASE_MEASUREMENT_ID'],
  );

  static FirebaseOptions get android => FirebaseOptions(
    apiKey: _require('FIREBASE_API_KEY_ANDROID'),
    appId: _require('FIREBASE_APP_ID_ANDROID'),
    messagingSenderId: _require('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: _require('FIREBASE_PROJECT_ID'),
    storageBucket: _require('FIREBASE_STORAGE_BUCKET'),
  );

  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: _require('FIREBASE_API_KEY_IOS'),
    appId: _require('FIREBASE_APP_ID_IOS'),
    messagingSenderId: _require('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: _require('FIREBASE_PROJECT_ID'),
    storageBucket: _require('FIREBASE_STORAGE_BUCKET'),
    iosBundleId: _require('FIREBASE_IOS_BUNDLE_ID'),
  );

  static FirebaseOptions get macos => ios;

  static String _require(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw StateError(
        '$key is missing from frontend/.env - copy .env.example to .env '
        'and fill in your Firebase project config.',
      );
    }
    return value;
  }
}
