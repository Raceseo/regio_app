import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async'; // StreamSubscription 사용을 위해 임포트

import 'firebase_options.dart';
import 'screens/auth_screen.dart';
import 'screens/reports_screen.dart';
import 'global_variables.dart'; // 전역 변수 임포트

// Firebase 인증 인스턴스
final _firebase = FirebaseAuth.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  // 전역 변수(사용자 역할) 업데이트가 진행 중인지 확인하는 상태
  bool _isGlobalRoleUpdating = true; // <-- 초기값을 true로 변경하여 첫 로딩을 처리

  // 스트림 구독을 저장할 변수
  late StreamSubscription<User?> _authStateSubscription;

  @override
  void initState() {
    super.initState();

    // 인증 상태 변경을 구독하고 전역 변수 업데이트를 처리합니다.
    _authStateSubscription =
        _firebase.authStateChanges().listen((User? user) async {
      if (!mounted) return;

      if (user != null) {
        // global_variables.dart에 정의된 사용자 역할 업데이트 함수 호출
        await updateGlobalUserRole();

        // 역할 업데이트가 완료되면 로딩 상태 해제
        if (mounted) {
          setState(() {
            _isGlobalRoleUpdating = false;
          });
        }
      } else {
        // 로그아웃 상태이거나 미인증 상태
        if (mounted) {
          setState(() {
            _isGlobalRoleUpdating = false; // 로그아웃 시에도 로딩 해제
          });
        }
      }
    });
  }

  // ★ 중요: 위젯이 사라질 때 구독을 취소하여 setState 오류를 방지
  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '레지오 활동 보고 앱',
      theme: ThemeData().copyWith(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 63, 17, 177)),
      ),
      // StreamBuilder를 사용하여 인증 상태에 따라 화면을 분기
      home: StreamBuilder(
        stream: _firebase.authStateChanges(),
        builder: (ctx, snapshot) {
          // 1. Firebase 연결 대기 상태 또는 역할 업데이트 대기 상태
          if (snapshot.connectionState == ConnectionState.waiting ||
              _isGlobalRoleUpdating) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }

          // 2. 로그인 완료 및 역할 업데이트 완료 상태
          if (snapshot.hasData) {
            return const ReportsScreen();
          }

          // 3. 로그아웃 상태
          return const AuthScreen();
        },
      ),
      routes: {
        '/reports': (context) => const ReportsScreen(),
      },
    );
  }
}
