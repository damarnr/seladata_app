import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../widgets/custom_header.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('monitoring');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: StreamBuilder(
          stream: _dbRef.onValue,
          builder: (context, snapshot) {
            // Data default jika koneksi belum masuk
            Map<dynamic, dynamic> data = {
              'ph': 0.0,
              'tds': 0,
              'suhu_air': 0,
              'tinggi_air': 0,
            };

            if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
              data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomHeader(),
                  const SizedBox(height: 30),
                  _buildMainBanner(),
                  const SizedBox(height: 30),

                  // SEKSI KUALITAS AIR
                  const Text("Kualitas Air", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF263238))),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: _buildSensorCard(
                        icon: Icons.water_drop, 
                        title: "pH Level", 
                        value: data['ph'].toString(), 
                        unit: "pH", 
                        color: Colors.blue[50]!, 
                        iconColor: Colors.blue[700]!,
                        status: _getPHStatus(data['ph']),
                        statusColor: _getPHStatusColor(data['ph']),
                      )),
                      const SizedBox(width: 16),
                      Expanded(child: _buildSensorCard(
                        icon: Icons.bolt, 
                        title: "Nutrient", 
                        value: data['tds'].toString(), 
                        unit: "PPM", 
                        color: Colors.orange[50]!, 
                        iconColor: Colors.orange[700]!,
                        status: _getTDSStatus(data['tds']),
                        statusColor: _getTDSStatusColor(data['tds']),
                      )),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // SEKSI LINGKUNGAN (SEKARANG SUDAH OTOMATIS)
                  const Text("Lingkungan", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF263238))),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: _buildSensorCard(
                        icon: Icons.thermostat, 
                        title: "Suhu Air", 
                        value: data['suhu_air'].toString(), 
                        unit: "°C", 
                        color: Colors.red[50]!, 
                        iconColor: Colors.red[700]!,
                        status: _getSuhuStatus(data['suhu_air']), // Memanggil logika suhu
                        statusColor: _getSuhuStatusColor(data['suhu_air']),
                      )),
                      const SizedBox(width: 16),
                      Expanded(child: _buildSensorCard(
                        icon: Icons.waves, 
                        title: "Tinggi Air", 
                        value: data['tinggi_air'].toString(), 
                        unit: "%", 
                        color: Colors.cyan[50]!, 
                        iconColor: Colors.cyan[700]!,
                        status: _getTinggiStatus(data['tinggi_air']), // Memanggil logika tinggi air
                        statusColor: _getTinggiStatusColor(data['tinggi_air']),
                      )),
                    ],
                  ),
                  const SizedBox(height: 35),
                  const Text("Grafik Harian", 
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF263238))),
                  const SizedBox(height: 15),
                  _buildChartPlaceholder(),
                  const SizedBox(height: 100),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- LOGIKA STATUS SEMUA SENSOR ---

  String _getPHStatus(dynamic val) {
    double ph = double.tryParse(val.toString()) ?? 0.0;
    if (ph >= 5.5 && ph <= 6.5) return "Normal";
    return "Bahaya";
  }

  Color _getPHStatusColor(dynamic val) {
    double ph = double.tryParse(val.toString()) ?? 0.0;
    return (ph >= 5.5 && ph <= 6.5) ? Colors.green : Colors.red;
  }

  String _getTDSStatus(dynamic val) {
    double tds = double.tryParse(val.toString()) ?? 0.0;
    if (tds >= 800 && tds <= 1200) return "Normal";
    return "Cek Nutrisi";
  }

  Color _getTDSStatusColor(dynamic val) {
    double tds = double.tryParse(val.toString()) ?? 0.0;
    return (tds >= 800 && tds <= 1200) ? Colors.green : Colors.orange;
  }

  // Logika Suhu Air
  String _getSuhuStatus(dynamic val) {
    double suhu = double.tryParse(val.toString()) ?? 0.0;
    if (suhu >= 20 && suhu <= 28) return "Ideal";
    return "Panas";
  }

  Color _getSuhuStatusColor(dynamic val) {
    double suhu = double.tryParse(val.toString()) ?? 0.0;
    return (suhu >= 20 && suhu <= 28) ? Colors.green : Colors.red;
  }

  // Logika Tinggi Air
  String _getTinggiStatus(dynamic val) {
    double tinggi = double.tryParse(val.toString()) ?? 0.0;
    if (tinggi >= 50) return "Aman";
    return "Kritis";
  }

  Color _getTinggiStatusColor(dynamic val) {
    double tinggi = double.tryParse(val.toString()) ?? 0.0;
    return (tinggi >= 50) ? Colors.green : Colors.red;
  }

  // --- WIDGET PENDUKUNG ---

  Widget _buildMainBanner() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: const Color(0xFF1E824C), borderRadius: BorderRadius.circular(30)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("MASA TANAM: HARI KE-18", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          const Text("12 Hari Menuju Panen", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          LinearProgressIndicator(value: 18 / 30, backgroundColor: Colors.white.withOpacity(0.2), valueColor: const AlwaysStoppedAnimation<Color>(Colors.white), minHeight: 8),
          const SizedBox(height: 15),
          const Text("Data sensor diperbarui secara real-time dari Firebase.", style: TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }

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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(backgroundColor: color, radius: 18, child: Icon(icon, color: iconColor, size: 18)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF263238))),
              const SizedBox(width: 4),
              Text(unit, style: TextStyle(fontSize: 12, color: Colors.blueGrey[200], fontWeight: FontWeight.w600)),
            ],
          ),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.blueGrey[400], fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildChartPlaceholder() {
    return Container(
      height: 180, width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
      child: const Center(child: Text("SelaData Real-time System Ready", style: TextStyle(color: Colors.grey))),
    );
  }
}