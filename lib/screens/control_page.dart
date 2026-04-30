import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart'; // 1. Import Firebase
import '../widgets/custom_header.dart';

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  // 2. Referensi ke folder 'control' di Firebase
  final DatabaseReference _controlRef = FirebaseDatabase.instance.ref('control');

  // FUNGSI PENYESUAIAN: Mengirim data kontrol DAN mencatat riwayat (logs)
  void _updateFirebase(String key, dynamic value) {
    // A. Update status kontrol perangkat
    _controlRef.child(key).set(value);

    // B. LOGIKA RIWAYAT: Mencatat aktivitas ke folder 'logs'
    String deviceName = key == 'pompa' ? "Pompa Air" : (key == 'kipas' ? "Kipas" : "Mode");
    String action = value == 1 ? "Dinyalakan" : "Dimatikan";
    
    // Kita hanya mencatat log untuk Pompa dan Kipas (bukan perubahan mode)
    if (key != 'mode_auto') { 
      // Membuat ID unik otomatis menggunakan .push()
      DatabaseReference logRef = FirebaseDatabase.instance.ref('logs').push();
      logRef.set({
        'device': deviceName,
        'action': action,
        // Format waktu jam:menit (misal 08:05)
        'time': "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}",
        'timestamp': ServerValue.timestamp, // Penting untuk pengurutan di halaman Reports
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: StreamBuilder( // 3. StreamBuilder agar UI sinkron dengan Firebase
          stream: _controlRef.onValue,
          builder: (context, snapshot) {
            // Nilai default jika Firebase kosong
            bool isAutoMode = false;
            bool isPompaOn = false;
            bool isFanOn = false;

            if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
              Map<dynamic, dynamic> data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
              // Konversi 0/1 dari Firebase ke bool untuk Switch
              isAutoMode = (data['mode_auto'] ?? 0) == 1;
              isPompaOn = (data['pompa'] ?? 0) == 1;
              isFanOn = (data['kipas'] ?? 0) == 1;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomHeader(title: "SelaData"),
                  const SizedBox(height: 30),

                  // KARTU SELEKSI MODE (Otomatis vs Manual)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isAutoMode ? const Color(0xFF1E824C) : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isAutoMode ? Colors.white24 : const Color(0xFFD1FADF),
                          radius: 25,
                          child: Icon(
                            isAutoMode ? Icons.auto_awesome : Icons.touch_app,
                            color: isAutoMode ? Colors.white : const Color(0xFF1E824C),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isAutoMode ? "Mode Otomatis Aktif" : "Mode Manual Aktif",
                                style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold,
                                  color: isAutoMode ? Colors.white : Colors.black87,
                                ),
                              ),
                              Text(
                                isAutoMode ? "Sistem bekerja berdasarkan sensor" : "Kendali penuh di tangan Anda",
                                style: TextStyle(fontSize: 12, color: isAutoMode ? Colors.white70 : Colors.black45),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: isAutoMode,
                          onChanged: (val) => _updateFirebase('mode_auto', val ? 1 : 0),
                          activeColor: Colors.white,
                          activeTrackColor: Colors.green[300],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  Text("Kontrol Manual", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])),
                  const SizedBox(height: 15),

                  // KONTROL HARDWARE (Terkunci jika Mode Auto)
                  IgnorePointer(
                    ignoring: isAutoMode, 
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: isAutoMode ? 0.5 : 1.0,
                      child: Column(
                        children: [
                          _buildControlCard(
                            icon: Icons.opacity,
                            title: "Pompa air",
                            state: isPompaOn ? "Aktif" : "Siaga",
                            color: const Color(0xFFD1FADF),
                            iconColor: Colors.green[800]!,
                            isOn: isPompaOn,
                            onChanged: (val) => _updateFirebase('pompa', val ? 1 : 0),
                          ),
                          const SizedBox(height: 20),
                          _buildControlCard(
                            icon: Icons.toys_outlined,
                            title: "Kipas Pendingin",
                            state: isFanOn ? "Aktif" : "Siaga",
                            color: const Color(0xFFFFE4D6),
                            iconColor: Colors.orange[800]!,
                            isOn: isFanOn,
                            onChanged: (val) => _updateFirebase('kipas', val ? 1 : 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildControlCard({
    required IconData icon, required String title, required String state,
    required Color color, required Color iconColor, required bool isOn,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(backgroundColor: color, radius: 25, child: Icon(icon, color: iconColor, size: 28)),
              Switch(
                value: isOn,
                onChanged: onChanged,
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFF1E824C),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey[300],
              ),
            ],
          ),
          const SizedBox(height: 25),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text("Status: $state", style: const TextStyle(color: Colors.black45, fontSize: 14)),
        ],
      ),
    );
  }
}