// lib/screens/reports_page.dart
import 'package:flutter/material.dart';
import '../widgets/custom_header.dart'; // 1. IMPORT WIDGET CUSTOM

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
              // 2. GANTI HEADER LAMA DENGAN CUSTOM HEADER
              // Kita gunakan title "SelaData" agar serasi di semua tab
              const CustomHeader(title: "SelaData"), 

              const SizedBox(height: 20),

              // 2. TITLE
              Text(
                "Data History",
                style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.green[900]),
              ),
              const SizedBox(height: 4),
              const Text(
                "Analisis historis tanaman Anda",
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
              const SizedBox(height: 20),

              // 3. CHART PLACEHOLDER (Visual Utama)
              const Text("Stabilitas pH Mingguan", 
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
                      Text("Visualisasi Grafik", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // 4. LOGS / HISTORY LIST
              const Text("Aktivitas Terkini", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              _buildLogTile("Pompa Air", "Otomatis menyala: Level air rendah", "08:00 AM", Colors.blue),
              _buildLogTile("Sistem Nutrisi", "Dosis: 1,2 mS diterapkan", "09:30 AM", Colors.orange),
              _buildLogTile("Kipas Exhaust", "Mati Otomatis: Suhu Stabil", "11:15 AM", Colors.red),
              
              const SizedBox(height: 100), 
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