import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:seladata/screens/splash_screen.dart';
import 'dart:async';
import 'firebase_options.dart';

import 'screens/splash_screen.dart'; 
import 'screens/dashboard_page.dart';
import 'screens/control_page.dart';
import 'screens/reports_page.dart';
import 'screens/login_page.dart';

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
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E824C),
          primary: const Color(0xFF1E824C),
        ),
        fontFamily: 'Roboto', 
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E824C),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      // MENGEMBALIKAN KE SplashPage SEBAGAI HALAMAN AWAL
      home: const SplashScreen(), 
    );
  }
}

// ... (Sisa kode MainPage dan State tetap sama seperti sebelumnya)

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  String _displayName = "User SelaData";
  StreamSubscription<DatabaseEvent>? _userSubscription;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _startUserListener();
  }

  void _startUserListener() {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      _userSubscription = FirebaseDatabase.instance
          .ref('users/$uid')
          .onValue
          .listen((event) {
        if (event.snapshot.value != null) {
          final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
          if (mounted) {
            setState(() {
              _displayName = data['name']?.toString() ?? "User SelaData";
            });
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }

  void _showGuidelineDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Panduan Nutrisi",
          style: TextStyle(color: Color(0xFF1E824C), fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildGuidelineItem(Icons.science_outlined, "pH Air", "Ideal: 5.5 - 6.5", Colors.blue),
            const SizedBox(height: 10),
            _buildGuidelineItem(Icons.water_drop_outlined, "PPM (TDS)", "Ideal: 800 - 1200", Colors.orange),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup", style: TextStyle(color: Color(0xFF1E824C))),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(IconData icon, String title, String value, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(value, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

// ... (Bagian import dan class awal tetap sama)

  // PERBAIKAN FUNGSI DIALOG LOGOUT
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Logout"),
        content: const Text("Apakah Anda yakin ingin keluar dari SelaData?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Batal")
          ),
          TextButton(
            onPressed: () async {
              await _auth.signOut(); // Logout dari Firebase
              if (mounted) {
                // Gunakan cara ini agar tidak perlu mendaftarkan rute manual di MaterialApp
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false, // Menghapus semua riwayat halaman
                );
              }
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
      key: scaffoldKey,
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 10,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1E824C),
        unselectedItemColor: Colors.grey[400],
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_remote_outlined), activeIcon: Icon(Icons.settings_remote), label: 'Controls'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), activeIcon: Icon(Icons.bar_chart), label: 'Reports'),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF1E824C),
                borderRadius: BorderRadius.only(bottomRight: Radius.circular(30)),
              ),
              currentAccountPicture: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      'assets/images/logo_seladata.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            _displayName.isNotEmpty ? _displayName[0].toUpperCase() : "S",
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1E824C)),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              accountName: Text(_displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              accountEmail: Text(_auth.currentUser?.email ?? "No Email"),
            ),
            _buildDrawerItem(Icons.home_outlined, "Halaman Utama", 0),
            _buildDrawerItem(Icons.history_rounded, "Laporan Riwayat", 2),
            _buildDrawerItem(Icons.help_center_outlined, "Panduan Parameter", -1, action: _showGuidelineDialog),
            const Divider(indent: 20, endIndent: 20),
            _buildDrawerItem(Icons.logout, "Logout", -1, action: _showLogoutDialog, isDanger: true),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "SelaData v1.0.0\nSmart Farming System",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi helper untuk item drawer tetap sama
  Widget _buildDrawerItem(IconData icon, String title, int index, {VoidCallback? action, bool isDanger = false}) {
    bool isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: isSelected ? const Color(0xFF1E824C).withOpacity(0.1) : Colors.transparent,
        leading: Icon(icon, color: isDanger ? Colors.red : (isSelected ? const Color(0xFF1E824C) : Colors.black54)),
        title: Text(
          title,
          style: TextStyle(
            color: isDanger ? Colors.red : (isSelected ? const Color(0xFF1E824C) : Colors.black87),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          if (action != null) {
            action();
          } else {
            setState(() => _selectedIndex = index);
          }
        },
      ),
    );
  }
}