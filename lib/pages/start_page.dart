// pages/start_page.dart
import 'package:flutter/material.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

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
              'SCalendar 시작하기',
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
                'SCalendar는 성신여대 전용 공지 달력\n앱입니다. 공지사항을 한눈에 확인하고,\n신청 기간을 놓치지 마세요!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Color(0xFF6A6FB3),
              ),
              onPressed: () => Navigator.pushNamed(context, '/main_page'),
              child: const Text('시작하기', style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}
