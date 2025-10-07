import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/notice.dart';

class NoticeDetailScreen extends StatelessWidget {
  final Notice notice;

  const NoticeDetailScreen({super.key, required this.notice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(notice.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 카테고리 및 작성자 정보 표시
            Text(
              '${notice.category == 'upper_council' ? '[상급평의회 소식]' : '[내부 공지]'} / 작성자: ${notice.userName}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.black54,
                  ),
            ),
            const SizedBox(height: 8),
            // 작성일 표시
            Text(
              '게시일: ${DateFormat('yyyy년 MM월 dd일').format(notice.timestamp.toDate())}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const Divider(height: 32),

            // 첨부 이미지가 있을 경우 표시
            if (notice.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  notice.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Text('이미지를 불러올 수 없습니다.'));
                  },
                ),
              ),
            if (notice.imageUrl.isNotEmpty) const SizedBox(height: 24),

            // 내용 표시
            Text(
              notice.content,
              style: const TextStyle(fontSize: 18, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
