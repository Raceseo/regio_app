// lib/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // 입력값 검증
    if (email.isEmpty || password.isEmpty) {
      _showSnackbar('이메일과 비밀번호를 모두 입력해주세요.');
      return;
    }

    if (password.length < 6) {
      _showSnackbar('비밀번호는 6자리 이상이어야 합니다.');
      return;
    }

    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _showSnackbar('회원가입 성공! 이제 로그인할 수 있습니다.');

      // 회원가입 성공 시 로그인 화면으로 돌아가기
      if (mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String message;

      // Firebase에서 반환하는 에러 코드를 사용자에게 친절하게 보여줍니다.
      switch (e.code) {
        case 'weak-password':
          message = '비밀번호가 너무 약합니다.';
          break;
        case 'email-already-in-use':
          message = '이미 사용 중인 이메일입니다. 로그인해 주세요.';
          break;
        case 'invalid-email':
          message = '이메일 형식이 올바르지 않습니다.';
          break;
        default:
          message = '회원가입에 실패했습니다. 다시 시도해주세요. (${e.code})';
          break;
      }
      _showSnackbar(message);
    } catch (e) {
      _showSnackbar('알 수 없는 오류가 발생했습니다: $e');
    }
  }

  void _showSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('새 계정 등록'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: '이메일',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: '비밀번호 (6자 이상)',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _signUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('계정 만들기',
                  style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
