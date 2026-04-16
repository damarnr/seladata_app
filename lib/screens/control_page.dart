// lib/screens/control_page.dart
import 'package:flutter/material.dart';
import '../widgets/custom_header.dart';

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  // Variabel State
  bool isAutoMode = false; // Mode Otomatis vs Manual
  bool isPompaOn = false;
  bool isFanOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. CUSTOM HEADER
              const CustomHeader(title: "SelaData"),
              const SizedBox(height: 30),

              // 2. KARTU SELEKSI MODE (Otomatis vs Manual)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isAutoMode ? const Color(0xFF1E824C) : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
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
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isAutoMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            isAutoMode 
                                ? "Sistem bekerja berdasarkan sensor" 
                                : "Kendali penuh di tangan Anda",
                            style: TextStyle(
                              fontSize: 12,
                              color: isAutoMode ? Colors.white70 : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: isAutoMode,
                      onChanged: (val) {
                        setState(() {
                          isAutoMode = val;
                        });
                      },
                      activeColor: Colors.white,
                      activeTrackColor: Colors.green[300],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 3. TITLE UNTUK MANUAL CONTROL
              Text(
                "Kontrol Manual",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[900],
                ),
              ),
              const SizedBox(height: 15),

              // 4. KONTROL HARDWARE (Terkunci jika Mode Auto)
              IgnorePointer(
                ignoring: isAutoMode, // Mematikan interaksi jika Auto Mode ON
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: isAutoMode ? 0.5 : 1.0, // Efek pudar jika terkunci
                  child: Column(
                    children: [
                      _buildControlCard(
                        icon: Icons.opacity,
                        title: "Pompa air",
                        state: isPompaOn ? "Aktif" : "Siaga",
                        color: const Color(0xFFD1FADF),
                        iconColor: Colors.green[800]!,
                        isOn: isPompaOn,
                        onChanged: (val) => setState(() => isPompaOn = val),
                      ),
                      const SizedBox(height: 20),
                      _buildControlCard(
                        icon: Icons.toys_outlined,
                        title: "Kipas Pendingin",
                        state: isFanOn ? "Aktif" : "Siaga",
                        color: const Color(0xFFFFE4D6),
                        iconColor: Colors.orange[800]!,
                        isOn: isFanOn,
                        onChanged: (val) => setState(() => isFanOn = val),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // 5. AUTOMATIONS SECTION (Hanya hiasan UI)
              Text(
                "Otomatisasi",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[900],
                ),
              ),
              const SizedBox(height: 15),
              _buildAutomationCard(
                icon: Icons.access_time,
                title: "Penyiraman Terjadwal",
                subtitle: "Setiap Hari • 08:00 • 15 Menit",
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget: Kartu Kontrol
  Widget _buildControlCard({
    required IconData icon,
    required String title,
    required String state,
    required Color color,
    required Color iconColor,
    required bool isOn,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundColor: color,
                radius: 25,
                child: Icon(icon, color: iconColor, size: 28),
              ),
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

  // Helper Widget: Kartu Automasi
  Widget _buildAutomationCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F4),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.green[800]),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: Colors.black54, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.black26),
        ],
      ),
    );
  }
}