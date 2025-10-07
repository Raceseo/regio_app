import 'package:flutter/material.dart';

// 현재는 빈 화면이지만 MainDrawer에서 참조되므로 필요합니다.
class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('단원 관리 (간부 전용)'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_person, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '단원 관리 기능이 여기에 표시됩니다.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
