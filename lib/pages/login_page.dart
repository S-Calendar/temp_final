// pages/login_page.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // 경로는 실제 위치에 맞게 조정하세요

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  void _onGoogleLoginPressed(BuildContext context) async {
    final user = await AuthService().signInWithGoogle();
    if (user != null) {
      // 로그인 성공 처리: 예시로 다음 페이지로 이동
      print('로그인 성공: ${user.displayName}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${user.displayName}님 환영합니다!')),
      );

      // TODO: 실제 앱에서는 홈화면 등으로 이동
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
    } else {
      // 로그인 실패 또는 취소
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인에 실패했거나 취소되었습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6A6FB3),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/app_logo.png', height: 120),
            const SizedBox(height: 20),
            const Text(
              'SCalendar 로그인',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'SCalendar는 성신여대 전용 공지 달력 앱입니다.\n공지사항을 한눈에 확인하고, 신청 기간을 놓치지 마세요!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => _onGoogleLoginPressed(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF6A6FB3),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/google_logo.png', height: 24),
                  const SizedBox(width: 10),
                  const Text('Google로 로그인', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
