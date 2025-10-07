import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'firebase_options.dart';
// ⭐️ 1. import 경로의 파일 이름을 소문자로 정확하게 맞춰줍니다.
import 'screens/auth_screen.dart'; 
import 'screens/reports_screen.dart';
import 'global_variables.dart';

final _firebase = FirebaseAuth.instance;

void main() async {
  // main 함수는 변경사항 없습니다.
  WidgetsFlutterBinding.ensureInitialized();
  // 웹에서는 Firebase 초기화가 약간 다를 수 있으므로, 아래 코드는 Codespaces 환경에 더 적합합니다.
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
  // _AppState는 변경사항 없습니다.
  bool _isGlobalRoleUpdating = true;
  late StreamSubscription<User?> _authStateSubscription;

  @override
  void initState() {
    super.initState();
    _authStateSubscription = _firebase.authStateChanges().listen((User? user) async {
      if (!mounted) return;
      if (user != null) {
        await updateGlobalUserRole();
        if (mounted) {
          setState(() { _isGlobalRoleUpdating = false; });
        }
      } else {
        if (mounted) {
          setState(() { _isGlobalRoleUpdating = false; });
        }
      }
    });
  }

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
      home: StreamBuilder(
        stream: _firebase.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || _isGlobalRoleUpdating) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData) {
            return const ReportsScreen();
          }
          // ⭐️ 2. AuthScreen을 찾을 수 없어서 발생한 const 에러를 해결합니다.
          return const AuthScreen();
        },
      ),
      routes: {
        '/reports': (context) => const ReportsScreen(),
      },
    );
  }
}