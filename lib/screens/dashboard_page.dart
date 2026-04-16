// lib/screens/dashboard_page.dart
import 'package:flutter/material.dart';
import '../widgets/custom_header.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

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
              // 1. HEADER
              const CustomHeader(),
              const SizedBox(height: 30),

              // 3. MAIN BANNER (Estimasi Panen & Progress)
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E824C),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "MASA TANAM: HARI KE-18", 
                          style: TextStyle(
                            color: Colors.white70, 
                            fontSize: 12, 
                            letterSpacing: 1.2, 
                            fontWeight: FontWeight.bold
                          )
                        ),
                        Icon(Icons.psychology_outlined, color: Colors.white.withOpacity(0.5), size: 20),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "12 Hari Menuju Panen",
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: 24, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 15),
                    // PROGRESS BAR: Visualisasi pertumbuhan
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: 18 / 30, // Contoh: Hari ke-18 dari total target 30 hari
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Tanaman tumbuh 15% lebih cepat karena suhu air yang terjaga ideal.",
                      style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // 4. WATER QUALITY SECTION (KRITIS)
              const Text("Kualitas Air", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF263238))),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildSensorCard(
                    icon: Icons.water_drop, 
                    title: "pH Level", 
                    value: "6.2", 
                    unit: "pH", 
                    color: Colors.blue[50]!, 
                    iconColor: Colors.blue[700]!,
                    status: "Normal",
                    statusColor: Colors.green,
                  )),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSensorCard(
                    icon: Icons.bolt, 
                    title: "Nutrient", 
                    value: "1.2", 
                    unit: "mS", 
                    color: Colors.orange[50]!, 
                    iconColor: Colors.orange[700]!,
                    status: "Low", // Contoh status peringatan
                    statusColor: Colors.orange,
                  )),
                ],
              ),
              const SizedBox(height: 25),

              // 5. ATMOSPHERE SECTION (LINGKUNGAN)
              const Text("Lingkungan", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF263238))),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildSensorCard(
                    icon: Icons.thermostat, 
                    title: "Temp", 
                    value: "24", 
                    unit: "°C", 
                    color: Colors.red[50]!, 
                    iconColor: Colors.red[700]!,
                    status: "Ideal",
                    statusColor: Colors.green,
                  )),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSensorCard(
                    icon: Icons.opacity, 
                    title: "Humidity", 
                    value: "65", 
                    unit: "%", 
                    color: Colors.cyan[50]!, 
                    iconColor: Colors.cyan[700]!,
                    status: "Good",
                    statusColor: Colors.green,
                  )),
                ],
              ),
              const SizedBox(height: 35),

              // 6. CHART SECTION
              const Text("Grafik Harian", 
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF263238))),
              const SizedBox(height: 15),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                child: const Center(child: Text("📊 grafik harian akan tampil disini", style: TextStyle(color: Colors.grey))),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // MODIFIKASI HELPER WIDGET SENSOR CARD
  Widget _buildSensorCard({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    required Color color,
    required Color iconColor,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Kartu: Ikon & Label Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundColor: color,
                radius: 18,
                child: Icon(icon, color: iconColor, size: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Data Utama
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF263238)),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: TextStyle(fontSize: 12, color: Colors.blueGrey[200], fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Text(
                title,
                style: TextStyle(fontSize: 12, color: Colors.blueGrey[400], fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}