import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityReport {
  final String id;
  final String userId;
  final String userName;
  final String title;
  final String content;
  final String unitName;
  final String imageUrl;
  final Timestamp timestamp;

  ActivityReport({
    required this.id,
    required this.userId,
    required this.userName,
    required this.title,
    required this.content,
    required this.unitName,
    this.imageUrl = '',
    required this.timestamp,
  });

  factory ActivityReport.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return ActivityReport(
      id: snapshot.id,
      userId: data?['userId'] ?? '',
      userName: data?['userName'] ?? '작성자 정보 없음',
      title: data?['title'] ?? '제목 없음',
      content: data?['content'] ?? '내용 없음',
      unitName: data?['unitName'] ?? '소속 없음',
      imageUrl: data?['imageUrl'] ?? '',
      timestamp: data?['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'title': title,
      'content': content,
      'unitName': unitName,
      'imageUrl': imageUrl,
      'timestamp': timestamp,
    };
  }
}
