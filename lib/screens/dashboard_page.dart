import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../widgets/custom_header.dart'; // Pastikan path ini sesuai dengan struktur folder Anda

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

            // --- EKSTRAKSI DATA UNTUK BANNER ---
            // Mengambil data dari map 'data' dan mengubahnya menjadi tipe double
            double nilaiPh = double.tryParse(data['ph'].toString()) ?? 0.0;
            double nilaiSuhu = double.tryParse(data['suhu_air'].toString()) ?? 0.0;
            double nilaiTinggiAir = double.tryParse(data['tinggi_air'].toString()) ?? 0.0;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomHeader(),
                  const SizedBox(height: 30),
                  
                  // Memanggil widget banner dengan data yang sudah diekstrak
                  _buildMainBanner(nilaiPh, nilaiSuhu, nilaiTinggiAir),
                  
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

                  // SEKSI LINGKUNGAN 
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
                        status: _getSuhuStatus(data['suhu_air']), 
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
                        status: _getTinggiStatus(data['tinggi_air']), 
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

  // Widget Banner Dinamis
  Widget _buildMainBanner(double ph, double suhuUdara, double tinggiAir) {
    // 1. Variabel Default (Kondisi Normal)
    Color bannerColor = const Color(0xFF1E824C); // Hijau
    String statusTitle = "KONDISI OPTIMAL";
    String statusMessage = "Data sensor stabil. Lingkungan ideal untuk pertumbuhan.";
    IconData statusIcon = Icons.eco; // Ikon daun untuk kondisi normal

    // 2. Logika Kondisional (Rule-Based)
    if (tinggiAir < 20.0) {
      // Prioritas 1: Kritis (Merah) jika air tandon habis
      bannerColor = Colors.red.shade700;
      statusTitle = "AIR KRITIS!";
      statusMessage = "Tinggi air tandon di bawah 20%. Segera isi ulang agar pompa tidak rusak.";
      statusIcon = Icons.water_drop_outlined; // Ikon tetesan air
    } else if (ph < 5.5 || ph > 6.5) {
      // Prioritas 2: Peringatan (Kuning/Oranye) jika pH di luar batas
      bannerColor = Colors.orange.shade800;
      statusTitle = "pH ABNORMAL";
      statusMessage = "Nilai pH ($ph) di luar ambang batas. Periksa kepekatan larutan nutrisi!";
      statusIcon = Icons.science_outlined; // Ikon tabung reaksi/kimia
    } else if (suhuUdara < 20.0 || suhuUdara > 28.0) {
      // Prioritas 3: Peringatan fluktuasi suhu
      bannerColor = Colors.orange.shade800;
      statusTitle = "SUHU EKSTREM";
      statusMessage = "Suhu saat ini ($suhuUdara°C). Pastikan sirkulasi udara di area tanam baik.";
      statusIcon = Icons.thermostat_outlined; // Ikon termometer
    }

    // 3. Tampilan Antarmuka (UI) Baru
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: BoxDecoration(
        color: bannerColor, 
        borderRadius: BorderRadius.circular(24), // Sedikit diperkecil agar lebih elegan
        boxShadow: [
          BoxShadow(
            color: bannerColor.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ]
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Ikon Status Besar di Kiri
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2), // Efek transparan membaur dengan latar
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: Colors.white, size: 42),
          ),
          const SizedBox(width: 18),
          
          // Teks Status di Kanan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusTitle, 
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 20, 
                    fontWeight: FontWeight.w900, // Dibuat sangat tebal agar mencolok
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  statusMessage, 
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 13, 
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
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
      height: 240, // Sedikit lebih tinggi agar lebih lega
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
        ]
      ),
      child: StreamBuilder(
        // 1. TINGKATKAN DETAIL: Ambil 20-30 data terakhir agar tren lebih terlihat jelas
        stream: FirebaseDatabase.instance.ref('riwayat_sensor').limitToLast(25).onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF1E824C)));
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("Menunggu data riwayat...", style: TextStyle(color: Colors.grey)));
          }

          Map<dynamic, dynamic> rawData = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          List<Map<String, dynamic>> historyList = [];

          rawData.forEach((key, value) {
            historyList.add({
              'suhu': double.parse(value['suhu'].toString()),
              'timestamp': (value['timestamp'] is int) ? value['timestamp'] : DateTime.now().millisecondsSinceEpoch,
            });
          });

          historyList.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

          List<FlSpot> spots = [];
          for (int i = 0; i < historyList.length; i++) {
            spots.add(FlSpot(i.toDouble(), historyList[i]['suhu']));
          }

          if (spots.length < 2) return const Center(child: Text("Mengumpulkan data..."));

          return LineChart(
            LineChartData(
              minY: 15, 
              maxY: 35,
              // 2. FITUR DETAIL: Tambahkan Tooltip saat grafik ditekan
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (LineBarSpot touchedSpot) => const Color(0xFF1E824C),
                  getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                    return touchedBarSpots.map((barSpot) {
                      final flSpot = barSpot;
                      return LineTooltipItem(
                        '${flSpot.y} °C\n',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                            text: DateFormat('HH:mm').format(
                              DateTime.fromMillisecondsSinceEpoch(historyList[flSpot.x.toInt()]['timestamp'])
                            ),
                            style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.normal),
                          ),
                        ],
                      );
                    }).toList();
                  },
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: const Color(0xFF1E824C),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  // 3. DETAIL VISUAL: Tampilkan titik kecil pada setiap data
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                      radius: 2,
                      color: Colors.white,
                      strokeWidth: 2,
                      strokeColor: const Color(0xFF1E824C),
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: const Color(0xFF1E824C).withOpacity(0.1),
                  ),
                ),
              ],
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                // Sumbu Y (Kiri): Tampilkan angka suhu agar lebih detail
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value == 20 || value == 25 || value == 30) {
                        return Text('${value.toInt()}°', style: const TextStyle(fontSize: 10, color: Colors.grey));
                      }
                      return const Text('');
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      // Tampilkan label jam setiap 5 data agar tidak sesak
                      if (index % 5 == 0 || index == historyList.length - 1) {
                        DateTime time = DateTime.fromMillisecondsSinceEpoch(historyList[index]['timestamp']);
                        return Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(DateFormat('HH:mm').format(time), 
                            style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 5,
                getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
            ),
          );
        },
      ),
    );
  }
}