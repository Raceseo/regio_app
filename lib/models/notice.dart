import 'package:cloud_firestore/cloud_firestore.dart';

// 공지사항(Notice) 문서를 위한 데이터 모델
class Notice {
  final String id;
  final String userId; // 작성자의 UID
  final String userName; // 작성자 이름
  final String title; // 공지 제목
  final String content; // 공지 내용
  final String imageUrl; // 첨부된 사진 URL
  final Timestamp timestamp; // 작성 시각
  final String category; // ⭐️ 새로 추가된 필드: 'upper_council' 또는 'internal'

  Notice({
    required this.id,
    required this.userId,
    required this.userName,
    required this.title,
    required this.content,
    this.imageUrl = '',
    required this.timestamp,
    required this.category, // ⭐️ 생성자에 추가
  });

  // Firestore DocumentSnapshot에서 모델을 생성하는 팩토리 메서드
  factory Notice.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Notice(
      id: snapshot.id,
      userId: data?['userId'] ?? '',
      userName: data?['userName'] ?? '작성자 정보 없음',
      title: data?['title'] ?? '제목 없음',
      content: data?['content'] ?? '내용 없음',
      imageUrl: data?['imageUrl'] ?? '',
      timestamp: data?['timestamp'] ?? Timestamp.now(),
      category: data?['category'] ?? 'internal', // ⭐️ 필드 읽기 (기본값: 'internal')
    );
  }

  // 모델을 Firestore에 저장하기 위한 Map으로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'timestamp': timestamp,
      'category': category, // ⭐️ 저장할 데이터에 추가
    };
  }
}
