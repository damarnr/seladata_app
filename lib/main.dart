// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Tambahkan ini
import 'firebase_options.dart'; // Tambahkan ini (file yang baru digenerate tadi)

import 'screens/dashboard_page.dart';
import 'screens/control_page.dart';
import 'screens/reports_page.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/splash_screen.dart';

void main() async {
  // 1. Wajib ditambahkan agar inisialisasi binding Flutter siap sebelum async process
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi Firebase menggunakan opsi dari file firebase_options.dart
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SelaData',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF7F9FB),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E824C)),
        useMaterial3: true,
      ),
      // Splash Screen tetap sebagai awal, nanti di sana kita cek status Login
      home: const SplashScreen(), 
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const ControlPage(),
    const ReportsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_remote_outlined),
              activeIcon: Icon(Icons.settings_remote),
              label: 'Controls'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded), 
              label: 'Reports'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF1E824C),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
      ),
    );
  }
}