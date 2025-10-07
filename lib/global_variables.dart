import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 전역 변수: 앱의 어떤 곳에서든 이 변수들을 불러와 사용할 수 있습니다.

String globalUserId = '';
String globalUserName = '사용자';
String globalUserRole = 'user'; // 'user' 또는 'admin'

// 로그인한 사용자의 정보를 가져와 전역 변수를 업데이트하는 함수
Future<void> updateGlobalUserRole() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    globalUserId = user.uid; // 현재 로그인한 사용자의 UID 저장

    try {
      // 'users' 컬렉션에서 해당 사용자 문서(document)를 가져옵니다.
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        // 문서가 존재하면, 'role'과 'name' 필드의 값을 읽어 전역 변수에 저장합니다.
        globalUserRole = userDoc.data()?['role'] ?? 'user';
        globalUserName = userDoc.data()?['name'] ?? '사용자';
      } else {
        // 문서가 존재하지 않을 경우 기본값으로 설정
        globalUserRole = 'user';
        globalUserName = '사용자';
      }
    } catch (e) {
      // 오류 발생 시 기본값으로 설정
      print('사용자 역할/이름 로딩 실패: $e');
      globalUserRole = 'user';
      globalUserName = '사용자';
    }
  } else {
    // 로그아웃 상태일 경우 전역 변수 초기화
    globalUserId = '';
    globalUserRole = 'user';
    globalUserName = '사용자';
  }
}
