// Firebase configuration, read from environment variables at runtime
// instead of being hardcoded here, so real project credentials never end up
// committed to source control.
//
// Values come from `frontend/.env` (gitignored — copy `.env.example` to
// `.env` and fill it in with your project's web config: Firebase console →
// Project settings → General → Your apps → Web app → SDK setup and
// configuration). `main.dart` loads that file via `flutter_dotenv` before
// this is read.
//
// This app only targets Flutter web, so only `web` is filled in below; add
// the other platform blocks (android/ios/macos/windows) the same way if
// this ever grows a native target.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart' show dotenv;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    throw UnsupportedError(
      'DefaultFirebaseOptions have not been configured for '
      '$defaultTargetPlatform - this app only targets web so far.',
    );
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
