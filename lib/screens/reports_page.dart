// lib/screens/reports_page.dart
import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

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
              // 1. HEADER (Sama dengan page lain agar serasi)
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

              // 2. TITLE
              Text(
                "Data Reports",
                style: TextStyle(
                    fontSize: 28, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.green[900]),
              ),
              const SizedBox(height: 4),
              const Text(
                "Historical analysis of your crops",
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
              const SizedBox(height: 30),

              // 3. CHART PLACEHOLDER (Visual Utama)
              const Text("Weekly pH Stability", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.stacked_line_chart, size: 50, color: Colors.green),
                      SizedBox(height: 10),
                      Text("Graph Visualization Placeholder", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // 4. LOGS / HISTORY LIST
              const Text("Recent Activities", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              _buildLogTile("Water Pump", "Auto-on: Water level low", "08:00 AM", Colors.blue),
              _buildLogTile("Nutrient System", "Dosage: 1.2 mS applied", "09:30 AM", Colors.orange),
              _buildLogTile("Exhaust Fan", "Auto-off: Temp stabilized", "11:15 AM", Colors.red),
              
              const SizedBox(height: 100), // Space agar tidak tertutup nav bar
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk daftar riwayat aktivitas
  Widget _buildLogTile(String title, String desc, String time, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(time, style: TextStyle(color: Colors.blueGrey[300], fontSize: 12)),
        ],
      ),
    );
  }
}