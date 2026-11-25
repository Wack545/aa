// สร้างจาก android/app/google-services.json และ ios/Runner/GoogleService-Info.plist
// ของโปรเจกต์ Firebase tast-c7c8f ในรูปแบบเดียวกับที่ `flutterfire configure` สร้าง
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAh6vHn8C7VGkyUGfwVA00TQ9a8zSAcCgQ',
    appId: '1:552363521098:android:9922a9767e9d85debde2b3',
    messagingSenderId: '552363521098',
    projectId: 'tast-c7c8f',
    storageBucket: 'tast-c7c8f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCFwvr77BYNu5f44ftDGo4Tm2XMXhcKws0',
    appId: '1:552363521098:ios:ff499ea3bfdeacfbbde2b3',
    messagingSenderId: '552363521098',
    projectId: 'tast-c7c8f',
    storageBucket: 'tast-c7c8f.firebasestorage.app',
    iosBundleId: 'com.example.aa',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCFwvr77BYNu5f44ftDGo4Tm2XMXhcKws0',
    appId: '1:552363521098:ios:ff499ea3bfdeacfbbde2b3',
    messagingSenderId: '552363521098',
    projectId: 'tast-c7c8f',
    storageBucket: 'tast-c7c8f.firebasestorage.app',
    iosBundleId: 'com.example.aa',
  );
}
