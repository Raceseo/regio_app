// lib/home_screen.dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('활동 보고 메인 화면'),
        backgroundColor: Colors.indigo,
      ),
      body: const Center(
        child: Text(
          '로그인에 성공했습니다! 이제 활동 보고 기능을 만들 차례입니다.',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
