import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/reports_screen.dart';
import '../screens/admin_screen.dart';
import '../screens/notice_screen.dart'; // 공지사항 화면 임포트
import '../global_variables.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // 상단 헤더 부분
          DrawerHeader(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.shield,
                    size: 48, color: Theme.of(context).colorScheme.onPrimary),
                const SizedBox(width: 18),
                Text(
                  '야탑동 성당 레지오',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                ),
              ],
            ),
          ),
          // --- 메뉴 목록 ---
          ListTile(
            leading: const Icon(Icons.article),
            title: const Text('활동 보고서'),
            onTap: () {
              // 현재 화면이 이미 활동 보고서일 수 있으므로, pop 후 push
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (ctx) => const ReportsScreen()),
              );
            },
          ),
          // ⭐️ Ray님께서 추가하려던 '공지사항' 메뉴입니다.
          ListTile(
            leading: const Icon(Icons.campaign),
            title: const Text('공지사항'),
            onTap: () {
              // 서랍을 먼저 닫고 화면 이동
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const NoticeScreen()),
              );
            },
          ),
          // 간부일 때만 '단원 관리' 메뉴 표시
          if (globalUserRole == 'admin')
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('단원 관리'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => const AdminScreen()),
                );
              },
            ),
          // Spacer를 사용해 로그아웃 버튼을 맨 아래로 보냅니다.
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('로그아웃'),
            onTap: () {
              FirebaseAuth.instance.signOut();
              // 로그아웃 후 서랍을 닫습니다.
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
