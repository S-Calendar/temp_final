//main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/start_page.dart';
import 'pages/main_page.dart';
import 'pages/search_page.dart'; // 올바른 경로와 이름으로 수정
import 'pages/settings_page.dart';
import 'pages/favorite_items_page.dart';
import 'pages/hidden_items_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  // dotenv 먼저 로드
  await dotenv.load(fileName: ".env");

  // Firebase 초기화 추가
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SCalendar',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const StartPage(),
        '/main_page': (context) => const MainPage(),
        '/search': (context) => const SearchPage(),
        '/settings': (context) => const SettingsPage(),
        '/favorite': (context) => const FavoriteItemsPage(),
        '/hidden': (context) => const HiddenItemsPage(),
        '/filter': (context) => const MainPage(), // 또는 별도 페이지
      },
    );
  }
}
