// lib/widgets/custom_header.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async'; // WAJIB DITAMBAHKAN UNTUK FUNGSI TIMER
import '../main.dart'; // IMPORT main.dart agar bisa akses scaffoldKey

class CustomHeader extends StatelessWidget {
  final String title;
  final bool showStatus;

  const CustomHeader({
    super.key, 
    this.title = "SelaData", 
    this.showStatus = true
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () {
            // GUNAKAN KUNCI UNTUK BUKA DRAWER
            scaffoldKey.currentState?.openDrawer();
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/header.png',
                  height: 45,
                  errorBuilder: (context, error, stackTrace) => 
                      const Icon(Icons.eco, color: Color(0xFF1E824C), size: 30),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E824C),
                  ),
                ),
              ],
            ),
          ),
        ),

        // STATUS ESP: Sekarang memanggil Widget Timer Pintar di bawah
        if (showStatus) const IndikatorStatusAlat(),
      ],
    );
  }
}

// --- WIDGET BARU UNTUK MEMANTAU DETAK JANTUNG (LAST_PING) ---
class IndikatorStatusAlat extends StatefulWidget {
  const IndikatorStatusAlat({Key? key}) : super(key: key);

  @override
  State<IndikatorStatusAlat> createState() => _IndikatorStatusAlatState();
}

class _IndikatorStatusAlatState extends State<IndikatorStatusAlat> {
  int _waktuPingTerakhir = 0;
  late Timer _timerDetakJantung;

  @override
  void initState() {
    super.initState();
    // 1. Dengarkan detak jantung (last_ping) dari Firebase
    FirebaseDatabase.instance.ref('monitoring/last_ping').onValue.listen((event) {
      if (event.snapshot.value != null && mounted) {
        setState(() {
          _waktuPingTerakhir = int.parse(event.snapshot.value.toString());
        });
      }
    });

    // 2. Jalankan Timer setiap 3 detik untuk mengecek selisih waktu
    _timerDetakJantung = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) setState(() {}); // Render ulang UI
    });
  }

  @override
  void dispose() {
    _timerDetakJantung.cancel(); // Matikan timer jika pindah layar untuk hemat RAM
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 3. Logika Penentuan Online/Offline (Batas Toleransi 15 Detik)
    int waktuSaatIni = DateTime.now().millisecondsSinceEpoch;
    bool isOnline = (waktuSaatIni - _waktuPingTerakhir) < 15000;

    // 4. Pengaturan Warna Dinamis mengikuti hasil isOnline
    String statusText = isOnline ? "ESP32 Online" : "ESP32 Offline";
    Color bgColor = isOnline ? const Color(0xFFD1FADF) : const Color(0xFFFEE4E2);
    Color textColor = isOnline ? Colors.green[900]! : Colors.red[900]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}