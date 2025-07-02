import 'package:app_crud/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/profile_page.dart';
import 'pages/register_page.dart';
import 'pages/map_page.dart';
import 'widgets/bottom_navbar.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // จัดการแจ้งเตือน background ที่นี่
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await initializeDateFormatting('th_TH', null);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(fontFamily: 'Prompt'),
      locale: const Locale('th', 'TH'),
      supportedLocales: const [Locale('th', 'TH'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/',
      routes: {
        '/': (context) => AppEntry(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/main': (context) => MainPage(),
        '/profile': (context) => ProfilePage(),
        '/home': (context) => HomePage(),
        '/map': (context) => MapPage(),
      },
    );
  }
}

class AppEntry extends StatefulWidget {
  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId != null && userId.isNotEmpty) {
      // อัปเดต token ทุกครั้งที่เข้าแอป
      String? token = await FirebaseMessaging.instance.getToken();
      await sendTokenToServer(userId, token);

      Navigator.pushReplacementNamed(context, '/main');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _loadPages();
    _initFCM();
  }

  Future<void> _loadPages() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('userRole') ?? '';

    List<Widget> pages = [HomePage()];

    // ✅ แสดงหน้าแผนที่เฉพาะ owner และ admin
    if (role == 'owner' || role == 'admin') {
      pages.add(MapPage());
    }

    // ✅ แสดงหน้าโปรไฟล์สำหรับ user และ admin
    if (role == 'user' || role == 'admin') {
      pages.add(ProfilePage());
    }

    setState(() {
      _pages = pages;
    });
  }

  Future<void> _initFCM() async {
    // ขอ permission
    await FirebaseMessaging.instance.requestPermission();

    // รับ token
    String? token = await FirebaseMessaging.instance.getToken();
    print('FCM Token: $token');
    // ส่ง token + user_id ไปเก็บที่ server ของคุณ

    // รับ notification ตอนแอป foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // แสดง dialog หรือ local notification
      print('Notification: ${message.notification?.title}');
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : PageTransitionSwitcher(
              duration: const Duration(milliseconds: 600),
              transitionBuilder: (child, animation, secondaryAnimation) =>
                  FadeThroughTransition(
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    child: child,
                  ),
              child: _pages[_selectedIndex],
            ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

Future<void> sendTokenToServer(String userId, String? token) async {
  if (token == null) return;
  await http.post(
    Uri.parse('http://10.0.2.2/bcnlp_crud/api/save_token.php'),
    body: {
      'user_id': userId, // ✅ ต้องใช้ user_id ให้ตรงกับ PHP
      'fcm_token': token,
    },
  );
}

// เรียกหลัง login หรือหลังได้ token
// sendTokenToServer(userId, token);
