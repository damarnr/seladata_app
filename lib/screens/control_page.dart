// lib/screens/control_page.dart
import 'package:flutter/material.dart';

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  // State untuk switch (simulasi)
  bool isPompaOn = true;
  bool isFanOn = false;
  bool isLightOn = true;
  double lightBrightness = 0.85; // 85%

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan SafeArea agar header tidak tertutup status bar HP
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- BAGIAN HEADER (LOGO & STATUS) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "🌱 SelaData",
                    style: TextStyle(
                        fontSize: 22, 
                        fontWeight: FontWeight.bold, 
                        color: Color(0xFF1E824C)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.circle, size: 8, color: Colors.green),
                        SizedBox(width: 6),
                        Text("ESP32 Online", 
                            style: TextStyle(
                                fontSize: 12, 
                                fontWeight: FontWeight.bold, 
                                color: Colors.green)),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 25), // Jarak ke Spanduk
              // -------------------------------------

              // 1. Spanduk Hijau (Banner)
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E824C),
                  borderRadius: BorderRadius.circular(20),
                  // Menambahkan shadow tipis agar lebih modern
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("System Controls",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text(
                      "Manage your ecosystem in real-time.",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // 2. Daftar Kontrol Manual
              _buildControlCard(
                icon: Icons.water_drop,
                title: "Water Pump",
                subtitle: "Current State: ${isPompaOn ? 'Active' : 'Standby'}",
                color: Colors.blue.shade400,
                isOn: isPompaOn,
                onChanged: (value) {
                  setState(() {
                    isPompaOn = value;
                  });
                },
              ),
              const SizedBox(height: 15),

              _buildControlCard(
                icon: Icons.mode_fan_off_outlined,
                title: "Exhaust Fan",
                subtitle: "Current State: ${isFanOn ? 'Active' : 'Standby'}",
                color: Colors.orange.shade400,
                isOn: isFanOn,
                onChanged: (value) {
                  setState(() {
                    isFanOn = value;
                  });
                },
              ),
              const SizedBox(height: 15),

              // 3. Kontrol Spesial dengan Slider (Grow Lights)
              _buildLightControlCard(),
              const SizedBox(height: 25),

              // 4. Bagian Automations (Simulation)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Automations",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: const Text("New Rule", style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.green.shade50,
                      foregroundColor: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              
              _buildAutomationCard(
                icon: Icons.schedule,
                title: "Scheduled Watering",
                time: "Daily • 08:00 AM",
                details: "15 Minutes duration",
                isActive: true,
              ),
              const SizedBox(height: 100), // Spasi bawah agar tidak tertutup nav bar
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget helper tetap sama seperti sebelumnya ---
  Widget _buildControlCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isOn,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            radius: 20,
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Switch(
            value: isOn,
            onChanged: onChanged,
            activeColor: const Color(0xFF1E824C),
          ),
        ],
      ),
    );
  }

  Widget _buildLightControlCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.green.shade50,
                radius: 20,
                child: const Icon(Icons.lightbulb_outline, color: Colors.green),
              ),
              const SizedBox(width: 20),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Grow Lights", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    Text("Dimmable LED Array", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              Switch(
                value: isLightOn,
                onChanged: (value) => setState(() => isLightOn = value),
                activeColor: const Color(0xFF1E824C),
              ),
            ],
          ),
          if (isLightOn) ...[
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("BRIGHTNESS", style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1.1)),
                Text("${(lightBrightness * 100).toInt()}%", style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
            Slider(
              value: lightBrightness,
              onChanged: (value) => setState(() => lightBrightness = value),
              activeColor: const Color(0xFF1E824C),
              inactiveColor: Colors.green.shade50,
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildAutomationCard({
    required IconData icon,
    required String title,
    required String time,
    required String details,
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey.shade100,
            radius: 20,
            child: Icon(icon, color: Colors.black54),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(details, style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
        ],
      ),
    );
  }
}