// lib/screens/control_page.dart
import 'package:flutter/material.dart';

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  bool isPompaOn = true;
  bool isFanOn = false;
  bool isLightOn = true;
  double lightBrightness = 0.85;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Warna background yang lebih clean
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align text ke kiri
            children: [
              // 1. HEADER (Logo & ESP Status)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                  const Text(
                    "🌱 SelaData",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E824C)),
                  ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FADF),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      "ESP32 Online",
                      style: TextStyle(
                          fontSize: 13, 
                          fontWeight: FontWeight.w600, 
                          color: Colors.green[900]),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 30),

              // 2. TITLE SECTION
              Text(
                "System Controls",
                style: TextStyle(
                    fontSize: 28, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.green[900]),
              ),
              const SizedBox(height: 4),
              const Text(
                "Manage your ecosystem in real-time",
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
              const SizedBox(height: 30),

              // 3. CONTROL CARDS
              _buildControlCard(
                icon: Icons.opacity,
                title: "Water Pump",
                state: isPompaOn ? "Active" : "Standby",
                color: const Color(0xFFD1FADF),
                iconColor: Colors.green[800]!,
                isOn: isPompaOn,
                onChanged: (val) => setState(() => isPompaOn = val),
              ),
              const SizedBox(height: 20),
              
              _buildControlCard(
                icon: Icons.toys_outlined, // Icon Fan
                title: "Exhaust Fan",
                state: isFanOn ? "Active" : "Standby",
                color: const Color(0xFFFFE4D6),
                iconColor: Colors.orange[800]!,
                isOn: isFanOn,
                onChanged: (val) => setState(() => isFanOn = val),
              ),
              const SizedBox(height: 30),

              // 4. AUTOMATIONS SECTION
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Automations",
                    style: TextStyle(
                        fontSize: 22, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.blueGrey[900]),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FADF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.add, size: 18, color: Colors.green[900]),
                        const SizedBox(width: 4),
                        Text("New Rule", style: TextStyle(color: Colors.green[900], fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 5. AUTOMATION CARDS
              _buildAutomationCard(
                icon: Icons.access_time,
                title: "Scheduled Watering",
                subtitle: "Daily • 08:00 AM • 15 Minutes",
                isActive: true,
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

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
          Text("Current State: $state", style: const TextStyle(color: Colors.black45, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildAutomationCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isActive,
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