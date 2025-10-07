import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 💡 Firestore 임포트 추가
import '../global_variables.dart'; // updateGlobalUserRole 함수 사용

// FirebaseAuth 인스턴스는 파일 상단에 정의되어 있어야 합니다.
final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // 폼 상태를 관리하기 위한 GlobalKey
  final _formKey = GlobalKey<FormState>();

  // 상태 변수
  var _isLogin = true; // 현재 로그인 모드인지 회원가입 모드인지
  var _isLoading = false;
  var _userEmail = '';
  var _userPassword = '';
  var _errorMessage = ''; // 사용자에게 보여줄 에러 메시지

  // 로그인/회원가입 처리 함수
  void _submitAuthForm(BuildContext context) async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();
      UserCredential userCredential;

      // 상태를 업데이트하여 로딩 인디케이터 표시 및 에러 메시지 초기화
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        if (_isLogin) {
          // 1. 로그인 시도
          userCredential = await _firebase.signInWithEmailAndPassword(
            email: _userEmail,
            password: _userPassword,
          );
        } else {
          // 2. 회원가입 시도
          userCredential = await _firebase.createUserWithEmailAndPassword(
            email: _userEmail,
            password: _userPassword,
          );

          // 💡 회원가입 직후 Firestore 'users' 컬렉션에 사용자 정보 저장 (필수)
          // 이 작업이 권한 업데이트에 필요하며, 없으면 role 가져오기에서 오류 발생
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'email': _userEmail,
            'role': 'member', // 기본 역할 설정
            'createdAt': Timestamp.now(), // 생성 시점 기록
          });
        }

        // 3. 로그인/가입 성공 후 전역 역할 업데이트
        // 이 함수 내부에서 Firestore 에러가 발생하면, 아래 catch(e)로 잡히게 됩니다.
        await updateGlobalUserRole();

        // 4. 핵심 수정: 로그인 성공 후 화면 닫기 (메인 화면으로 이동)
        if (!mounted) return;
        Navigator.of(context).pop();
      } on FirebaseAuthException catch (err) {
        // Firebase 인증 오류 처리
        String message = '로그인/회원가입 중 알 수 없는 오류가 발생했습니다.';

        if (err.code == 'user-not-found' || err.code == 'wrong-password') {
          message = '이메일 주소 또는 비밀번호가 일치하지 않습니다.';
        } else if (err.code == 'invalid-email') {
          message = '유효하지 않은 이메일 형식입니다.';
        } else if (err.code == 'weak-password') {
          message = '비밀번호가 너무 짧습니다. 6자 이상으로 설정해주세요.';
        } else if (err.code == 'email-already-in-use') {
          message = '이미 사용 중인 이메일입니다. 로그인을 시도해주세요.';
        } else if (err.code == 'api-key-not-valid') {
          message = '앱 설정 오류: API 키 구성을 확인해주세요.';
        }

        setState(() {
          _errorMessage = message;
          _isLoading = false;
        });
      } catch (e) {
        // 💡 일반적인 오류 처리 (Firestore 권한 거부 등)
        print('Submit Auth Form General Error: $e'); // 디버깅을 위해 콘솔에 상세 오류 출력
        setState(() {
          // Firestore Security Rules 문제일 가능성이 높습니다.
          _errorMessage = '시스템 오류 발생. Firestore 권한 또는 연결 상태를 확인해주세요.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI 구성은 이전과 동일
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            margin: const EdgeInsets.all(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // 이메일 입력 필드
                    TextFormField(
                      key: const ValueKey('email'),
                      autocorrect: false,
                      textCapitalization: TextCapitalization.none,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: '이메일 주소'),
                      validator: (value) {
                        if (value == null || !value.contains('@')) {
                          return '유효한 이메일 주소를 입력해주세요.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _userEmail = value!;
                      },
                    ),
                    // 비밀번호 입력 필드
                    TextFormField(
                      key: const ValueKey('password'),
                      obscureText: true,
                      decoration: const InputDecoration(labelText: '비밀번호'),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return '비밀번호는 6자 이상이어야 합니다.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _userPassword = value!;
                      },
                    ),
                    const SizedBox(height: 12),

                    // 에러 메시지 표시 영역
                    if (_errorMessage.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          _errorMessage,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // 로딩 또는 버튼 표시
                    if (_isLoading) const CircularProgressIndicator(),

                    if (!_isLoading)
                      ElevatedButton(
                        onPressed: () => _submitAuthForm(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(_isLogin ? '로그인' : '회원가입'),
                      ),

                    // 모드 전환 버튼
                    if (!_isLoading)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                            _errorMessage = ''; // 모드 변경 시 에러 메시지 초기화
                          });
                        },
                        child: Text(
                          _isLogin ? '계정이 없으신가요? 회원가입' : '이미 계정이 있으신가요? 로그인',
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
