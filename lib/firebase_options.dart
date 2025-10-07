import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// 환경별 Firebase 구성을 위한 기본 옵션
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
        throw UnsupportedError(
          'DefaultFirebaseOptions only supports Android, iOS, macOS, and web.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions only supports Android, iOS, macOS, and web.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // 사용자 제공 Firebase Config (Web) 적용
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDXtssy11lDNEJV4ifUI8IDLR-LNhC_ijU', // 적용 완료
    appId: '1:981102623115:web:e3c0640f79a78745c2578e', // 적용 완료
    messagingSenderId: '981102623115', // 적용 완료
    projectId: 'regio-mariae-e0867', // 적용 완료
    authDomain: 'regio-mariae-e0867.firebaseapp.com', // 적용 완료
    storageBucket:
        'regio-mariae-e0867.appspot.com', // Firebase Storage 규칙에 필요한 기본값으로 설정
    measurementId: 'G-7SNMJPKV61', // 적용 완료
  );

  // 나머지 플랫폼은 플레이스홀더 유지 (웹 테스트 기준)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: '<YOUR_ANDROID_API_KEY>',
    appId: '1:<YOUR_ANDROID_APP_ID>',
    messagingSenderId: '981102623115',
    projectId: 'regio-mariae-e0867',
    storageBucket: 'regio-mariae-e0867.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: '<YOUR_IOS_API_KEY>',
    appId: '1:<YOUR_IOS_APP_ID>',
    messagingSenderId: '981102623115',
    projectId: 'regio-mariae-e0867',
    storageBucket: 'regio-mariae-e0867.appspot.com',
    iosBundleId: '<YOUR_BUNDLE_ID_COM_EXAMPLE_APP>',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: '<YOUR_MACOS_API_KEY>',
    appId: '1:<YOUR_MACOS_APP_ID>',
    messagingSenderId: '981102623115',
    projectId: 'regio-mariae-e0867',
    storageBucket: 'regio-mariae-e0867.appspot.com',
    iosBundleId: '<YOUR_BUNDLE_ID_COM_EXAMPLE_APP>',
  );
}
