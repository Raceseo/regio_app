import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../models/notice.dart';
import '../widgets/main_drawer.dart';
import 'notice_detail_screen.dart';
import 'notice_form_screen.dart'; // ⭐️ 1. 글쓰기 화면 임포트
import '../global_variables.dart'; // ⭐️ 2. 권한 확인을 위한 전역 변수 임포트

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 현재 사용자가 글을 쓸 수 있는 권한이 있는지 확인
    final canWrite = globalUserRole == 'officer' || globalUserRole == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('공지사항'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '상급평의회 소식'),
            Tab(text: '내부 공지'),
          ],
        ),
      ),
      drawer: const MainDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _NoticeList(category: 'upper_council'),
          _NoticeList(category: 'internal'),
        ],
      ),
      // ⭐️ 3. 권한이 있을 때만 글쓰기 버튼(FloatingActionButton)을 표시
      floatingActionButton: canWrite
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => const NoticeFormScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null, // 권한이 없으면 버튼을 표시하지 않음
    );
  }
}

// _NoticeList 위젯은 변경사항 없습니다.
class _NoticeList extends StatelessWidget {
  final String category;
  const _NoticeList({required this.category});

  @override
  Widget build(BuildContext context) {
    final noticeStream = FirebaseFirestore.instance
        .collection('notices')
        .where('category', isEqualTo: category)
        .orderBy('timestamp', descending: true)
        .withConverter<Notice>(
          fromFirestore: Notice.fromFirestore,
          toFirestore: (Notice notice, _) => notice.toFirestore(),
        );

    return StreamBuilder<QuerySnapshot<Notice>>(
      stream: noticeStream.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('등록된 공지사항이 없습니다.'));
        }

        final notices = snapshot.data!.docs.map((doc) => doc.data()).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: notices.length,
          itemBuilder: (context, index) {
            final notice = notices[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: ListTile(
                title: Text(
                  notice.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${notice.userName} · ${DateFormat('yyyy.MM.dd').format(notice.timestamp.toDate())}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (ctx) => NoticeDetailScreen(notice: notice),
                  ));
                },
              ),
            );
          },
        );
      },
    );
  }
}
