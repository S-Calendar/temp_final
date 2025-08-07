// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 
import 'pages/main_page.dart';
import 'pages/search_page.dart';
import 'pages/settings_page.dart';
import 'pages/favorite_items_page.dart';
import 'pages/hidden_items_page.dart';
import 'pages/year_page.dart';
import 'pages/login_page.dart';
import 'package:timezone/data/latest.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  tz.initializeTimeZones();
  // Firebase 초기화 중복 방지 및 예외 처리
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }
  } catch (e) {
    print('Firebase already initialized: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SCalendar',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login', // 로그인 페이지를 시작점으로
      routes: {
        '/login': (context) => const LoginPage(),
        '/main_page': (context) => const MainPage(),
        '/search': (context) => const SearchPage(),
        '/settings': (context) => const SettingsPage(),
        '/favorite': (context) => const FavoriteItemsPage(),
        '/hidden': (context) => const HiddenItemsPage(),
        '/year_page': (context) => const YearCalendarPage(),
      },
    );
  }
}
