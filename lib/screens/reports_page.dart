import 'dart:math'; // Diperlukan untuk fungsi min dan max data grafik
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart'; // Import Firebase
import 'package:fl_chart/fl_chart.dart'; // Import fl_chart untuk Grafik
import 'package:intl/intl.dart'; // Import intl untuk Format Tanggal/Jam
import '../widgets/custom_header.dart';

// =============================================================================
// MODEL KONFIGURASI SENSOR (IDENTIK DENGAN DASHBOARD ANDA)
// =============================================================================
class SensorConfig {
  final String firebaseKey;    // key di riwayat_sensor
  final String label;
  final String unit;
  final Color lineColor;
  final double thresholdLow;
  final double thresholdHigh;
  final double yPadding;       // padding atas-bawah agar grafik tidak gepeng

  const SensorConfig({
    required this.firebaseKey,
    required this.label,
    required this.unit,
    required this.lineColor,
    required this.thresholdLow,
    required this.thresholdHigh,
    this.yPadding = 2.0,
  });
}

// Konfigurasi tiap sensor — Threshold disesuaikan dengan kebutuhan tanaman SelaData
const Map<String, SensorConfig> sensorConfigs = {
  'suhu': SensorConfig(
    firebaseKey: 'suhu_air', // Sesuai dengan pengiriman dari ESP32 Anda
    label: 'Suhu',
    unit: '°C',
    lineColor: Color(0xFF1E824C),
    thresholdLow: 20,
    thresholdHigh: 28,
    yPadding: 2,
  ),
  'ph': SensorConfig(
    firebaseKey: 'ph',
    label: 'pH',
    unit: '',
    lineColor: Color(0xFF7F77DD),
    thresholdLow: 5.5,
    thresholdHigh: 6.5,
    yPadding: 0.5,
  ),
  'tds': SensorConfig(
    firebaseKey: 'tds',
    label: 'TDS',
    unit: 'ppm',
    lineColor: Color(0xFF185FA5),
    thresholdLow: 560,
    thresholdHigh: 840,
    yPadding: 50,
  ),
};

// =============================================================================
// HALAMAN UTAMA REPORT
// =============================================================================
class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final DatabaseReference _logsRef = FirebaseDatabase.instance.ref('logs');

  // FUNGSI KONFIRMASI HAPUS LOG AKTIVITAS
  void _showDeleteConfirmation(String logId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Hapus Aktivitas?"),
        content: const Text("Data ini akan dihapus permanen dari riwayat SelaData."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              _logsRef.child(logId).remove();
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Aktivitas berhasil dihapus")),
              );
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

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
              const CustomHeader(title: "SelaData"),
              const SizedBox(height: 20),
              
              Text(
                "Data History",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[900]),
              ),
              const SizedBox(height: 4),
              const Text("Analisis historis tanaman Anda", style: TextStyle(fontSize: 15, color: Colors.black54)),
              
              const SizedBox(height: 20),

              const Text("Stabilitas pH Mingguan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              
              // MEMANGGIL WIDGET GRAFIK MINGGUAN (Contoh memanggil 'ph')
              // Anda bisa menggantinya dengan 'suhu' atau 'tds' sesuai kebutuhan halaman
              _buildChartWidget(sensor: 'ph'),

              const SizedBox(height: 30),

              const Text("Aktivitas Terkini", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),

              // STREAM LIST AKTIVITAS LOG
              StreamBuilder(
                stream: _logsRef.orderByChild('timestamp').limitToLast(20).onValue,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                    Map<dynamic, dynamic> logsMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                    List<MapEntry<dynamic, dynamic>> logsList = logsMap.entries.toList();
                    
                    // Urutkan berdasarkan waktu terbaru (timestamp)
                    logsList.sort((a, b) => (b.value['timestamp'] ?? 0).compareTo(a.value['timestamp'] ?? 0));

                    return Column(
                      children: logsList.map((entry) {
                        return _buildLogTile(
                          entry.key, 
                          entry.value['device'] ?? "Unknown",
                          entry.value['action'] ?? "-",
                          entry.value['time'] ?? "-",
                          _getColorByDevice(entry.value['device']),
                        );
                      }).toList(),
                    );
                  } else {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text("Belum ada aktivitas tercatat", style: TextStyle(color: Colors.grey)),
                      ),
                    );
                  }
                },
              ),
              
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorByDevice(String? device) {
    if (device == "Pompa Air") return Colors.blue;
    if (device == "Kipas") return Colors.orange;
    return Colors.green;
  }

  // =============================================================================
  // WIDGET UTAMA GRAFIK MINGGUAN (LOGIKA DINAMIS SENSOR CONFIG)
  // =============================================================================
  Widget _buildChartWidget({required String sensor}) {
    final config = sensorConfigs[sensor]!;

    return Container(
      height: 280,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: StreamBuilder(
        // SKALA MINGGUAN: Diambil hingga 150 log data terakhir untuk membaca tren seminggu
        stream: FirebaseDatabase.instance
            .ref('riwayat_sensor')
            .limitToLast(150)
            .onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: config.lineColor));
          }
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("Menunggu data...", style: TextStyle(color: Colors.grey)));
          }

          // ── Parse data ──────────────────────────────────────────────────────
          final raw = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          final List<Map<String, dynamic>> history = [];

          raw.forEach((key, value) {
            final sensorVal = value[config.firebaseKey];
            if (sensorVal == null) return;
            history.add({
              'nilai': double.tryParse(sensorVal.toString()) ?? 0.0,
              'timestamp': (value['timestamp'] is int)
                  ? value['timestamp']
                  : DateTime.now().millisecondsSinceEpoch,
            });
          });

          history.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
          if (history.length < 2) {
            return const Center(child: Text("Mengumpulkan data..."));
          }

          // ── Hitung rentang Y secara dinamis ─────────────────────────────────
          final values = history.map<double>((e) => e['nilai'] as double).toList();
          final dataMin = values.reduce((a, b) => a < b ? a : b);
          final dataMax = values.reduce((a, b) => a > b ? a : b);
          
          final yMin = (min(dataMin, config.thresholdLow) - config.yPadding).floorToDouble();
          final yMax = (max(dataMax, config.thresholdHigh) + config.yPadding).ceilToDouble();

          // ── Buat spots ───────────────────────────────────────────────────────
          final List<FlSpot> spots = List.generate(
            history.length,
            (i) => FlSpot(i.toDouble(), history[i]['nilai']),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildChartHeader(config, values.last),
              const SizedBox(height: 8),
              Expanded(
                child: LineChart(
                  LineChartData(
                    minY: yMin,
                    maxY: yMax,

                    // ── Tooltip Interaktif Skala Mingguan ──────────────────────
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (_) => config.lineColor,
                        getTooltipItems: (touchedSpots) => touchedSpots
                            .where((s) => s.barIndex == 0)
                            .map((s) {
                              int idx = s.x.toInt();
                              if (idx < 0 || idx >= history.length) return null;

                              DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(history[idx]['timestamp']);
                              String formattedDate = DateFormat('dd MMM, HH:mm').format(dateTime);

                              return LineTooltipItem(
                                '${s.y.toStringAsFixed(2)} ${config.unit}\n',
                                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                children: [
                                  TextSpan(
                                    text: formattedDate,
                                    style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.normal),
                                  ),
                                ],
                              );
                            })
                            .toList(),
                      ),
                    ),

                    lineBarsData: [
                      // ── Dataset 1: Nilai Riwayat Sensor ────────────────────
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: config.lineColor,
                        barWidth: 2.5,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            final isAbnormal = spot.y < config.thresholdLow || spot.y > config.thresholdHigh;
                            return FlDotCirclePainter(
                              radius: isAbnormal ? 3.5 : 2,
                              color: isAbnormal ? Colors.red.shade400 : Colors.white,
                              strokeWidth: 2,
                              strokeColor: isAbnormal ? Colors.red.shade600 : config.lineColor,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: config.lineColor.withOpacity(0.08),
                        ),
                      ),

                      // ── Dataset 2: Garis Batas Atas (Dotted Merah) ───────────
                      LineChartBarData(
                        spots: [
                          FlSpot(0, config.thresholdHigh),
                          FlSpot((history.length - 1).toDouble(), config.thresholdHigh),
                        ],
                        isCurved: false,
                        color: Colors.red.shade300,
                        barWidth: 1.5,
                        dotData: const FlDotData(show: false),
                        dashArray: [6, 4],
                      ),

                      // ── Dataset 3: Garis Batas Bawah (Dotted Biru) ───────────
                      LineChartBarData(
                        spots: [
                          FlSpot(0, config.thresholdLow),
                          FlSpot((history.length - 1).toDouble(), config.thresholdLow),
                        ],
                        isCurved: false,
                        color: Colors.blue.shade300,
                        barWidth: 1.5,
                        dotData: const FlDotData(show: false),
                        dashArray: [6, 4],
                      ),
                    ],

                    // ── Axis Skala Mingguan ────────────────────────────────────
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 36,
                          getTitlesWidget: (value, meta) {
                            if (value == meta.min || value == meta.max) {
                              return const Text('');
                            }
                            return Text(
                              value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          // Sumbu X otomatis membagi area grafik rapi menjadi 5 bagian hari
                          interval: (history.length / 5).clamp(1, double.infinity),
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= history.length) {
                              return const Text('');
                            }

                            final t = DateTime.fromMillisecondsSinceEpoch(history[idx]['timestamp']);
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                // Format Skala Mingguan: Nama Hari & Tanggal (Contoh: Sel 19)
                                DateFormat('E dd').format(t),
                                style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: (yMax - yMin) / 4,
                      getDrawingHorizontalLine: (_) =>
                          FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1),
                    ),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─── Header: Nilai Terkini + Badge Status ──────────────────────────────────
  Widget _buildChartHeader(SensorConfig config, double currentValue) {
    final isNormal = currentValue >= config.thresholdLow && currentValue <= config.thresholdHigh;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${currentValue.toStringAsFixed(2)} ${config.unit}',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: config.lineColor),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isNormal ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isNormal ? '● Normal' : '● Di luar batas',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isNormal ? Colors.green.shade700 : Colors.red.shade600,
            ),
          ),
        ),
      ],
    );
  }

  // ─── KOTAK AKTIVITAS LIST (LOG TILE) ───────────────────────────────────────
  Widget _buildLogTile(String logId, String title, String desc, String time, Color color) {
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
          Container(width: 4, height: 40, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(time, style: TextStyle(color: Colors.blueGrey[300], fontSize: 11)),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                onPressed: () => _showDeleteConfirmation(logId),
              ),
            ],
          ),
        ],
      ),
    );
  }
}