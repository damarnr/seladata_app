// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'firebase_options.dart';

import 'screens/dashboard_page.dart';
import 'screens/control_page.dart';
import 'screens/reports_page.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/splash_screen.dart';

// 1. TAMBAHKAN KUNCI GLOBAL DI SINI
// Ini adalah "remote control" agar Drawer bisa dibuka dari file lain
final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        scaffoldBackgroundColor: const Color.fromARGB(255, 248, 248, 248),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E824C)),
        useMaterial3: true,
      ),
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

  // FUNGSI LOGOUT
  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  // FUNGSI DIALOG KONFIRMASI
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Apakah Anda yakin ingin keluar dari SelaData?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleLogout();
            },
            child: const Text("Keluar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  final List<Widget> _pages = [
    const DashboardPage(),
    const ControlPage(),
    const ReportsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 2. PASANG KUNCI KE SCAFFOLD
      key: scaffoldKey, 
      
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
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF1E824C)),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Color(0xFF1E824C)),
              ),
              accountName: const Text("User SelaData", style: TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: Text(FirebaseAuth.instance.currentUser?.email ?? "Email tidak ditemukan"),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: _showLogoutDialog, 
            ),
          ],
        ),
      ),
    );
  }
}