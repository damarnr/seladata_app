// lib/screens/dashboard_page.dart
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Serasi dengan ControlPage
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align kiri agar konsisten
            children: [
              // 1. HEADER (Logo & ESP Status) - Meniru persis ControlPage
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

              // 2. TITLE SECTION
              Text(
                "Active Environment",
                style: TextStyle(
                    fontSize: 28, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.green[900]),
              ),
              const SizedBox(height: 4),
              const Text(
                "Your Hydroponic System is Thriving",
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
              const SizedBox(height: 30),

              // 3. MAIN BANNER
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E824C),
                  borderRadius: BorderRadius.circular(30), // Radius serasi (30)
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("SYSTEM STATUS", 
                      style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text(
                      "Optimal Growth Stage",
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Semua sensor menunjukkan kondisi terbaik untuk pertumbuhan selada saat ini.",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              const Text("Latest Readings", 
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF263238))),
              const SizedBox(height: 20),

              // 4. SENSOR CARDS (Menggunakan Grid agar rapi)
              // Di dalam Column dashboard_page.dart
                GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.0, // Cobalah nilai 1.0 atau 1.1 sesuai selera
                children: [
                  _buildSensorCard(icon: Icons.water_drop, title: "pH Level", value: "6.2", unit: "pH", color: Colors.blue[50]!, iconColor: Colors.blue[700]!),
                  _buildSensorCard(icon: Icons.thermostat, title: "Temp", value: "24", unit: "°C", color: Colors.red[50]!, iconColor: Colors.red[700]!),
                  _buildSensorCard(icon: Icons.opacity, title: "Humidity", value: "65", unit: "%", color: Colors.cyan[50]!, iconColor: Colors.cyan[700]!),
                  _buildSensorCard(icon: Icons.bolt, title: "Nutrient", value: "1.2", unit: "mS", color: Colors.orange[50]!, iconColor: Colors.orange[700]!),
                ],
              ),
              const SizedBox(height: 30),

              // 5. CHART SECTION
              const Text("Temperature Trend", 
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
                child: const Center(child: Text("📊 Weekly Chart Visualization", style: TextStyle(color: Colors.grey))),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget Sensor Card yang diserasikan dengan gaya ControlPage
// lib/screens/dashboard_page.dart

// lib/screens/dashboard_page.dart

Widget _buildSensorCard({
  required IconData icon,
  required String title,
  required String value,
  required String unit,
  required Color color,
  required Color iconColor,
}) {
  return Container(
    padding: const EdgeInsets.all(18), // Padding yang pas
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28), // Radius sudut yang halus
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 12,
          offset: const Offset(0, 6),
        )
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Baris 1: Ikon
        CircleAvatar(
          backgroundColor: color,
          radius: 20,
          child: Icon(icon, color: iconColor, size: 20),
        ),
        
        // Baris 2: Data (Angka & Label)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Angka Sensor (Value) - Diperbesar
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 30, // Ukuran angka lebih besar sesuai permintaan
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF263238),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blueGrey[200],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            // Nama Sensor (Title)
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.blueGrey[400],
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
}