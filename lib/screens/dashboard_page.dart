import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../widgets/custom_header.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('monitoring');

  // Sensor yang sedang aktif ditampilkan di grafik
  String _activeSensor = 'suhu_air';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: StreamBuilder(
          stream: _dbRef.onValue,
          builder: (context, snapshot) {
            Map<dynamic, dynamic> data = {
              'ph': 0.0,
              'tds': 0,
              'suhu_air': 0,
              'tinggi_air': 0,
            };

            if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
              data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            }

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
                  _buildMainBanner(nilaiPh, nilaiSuhu, nilaiTinggiAir),
                  const SizedBox(height: 30),

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
                        value: double.parse(data['tds'].toString()).toStringAsFixed(0),
                        unit: "PPM",
                        color: Colors.orange[50]!,
                        iconColor: Colors.orange[700]!,
                        status: _getTDSStatus(data['tds']),
                        statusColor: _getTDSStatusColor(data['tds']),
                      )),
                    ],
                  ),
                  const SizedBox(height: 25),

                  const Text("Lingkungan",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF263238))),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: _buildSensorCard(
                        icon: Icons.thermostat,
                        title: "Suhu Air",
                        value: double.parse(data['suhu_air'].toString()).toStringAsFixed(1),
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

                  // Tombol pilih sensor — setState agar grafik berganti
                  _buildSensorSelector(),
                  const SizedBox(height: 12),

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

  // ─── Tombol pilih sensor ────────────────────────────────────────────────────
  Widget _buildSensorSelector() {
    final sensors = [
      {'key': 'suhu_air', 'label': 'Suhu', 'icon': Icons.thermostat},
      {'key': 'ph',       'label': 'pH',   'icon': Icons.science_outlined},
      {'key': 'tds',      'label': 'TDS',  'icon': Icons.bolt},
    ];

    return Row(
      children: sensors.map((s) {
        final bool isActive = _activeSensor == s['key'];
        final Color activeColor = _getSensorColor(s['key'] as String);
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _activeSensor = s['key'] as String),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isActive ? activeColor : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isActive ? activeColor : Colors.grey.shade200,
                  width: 1.5,
                ),
                boxShadow: isActive
                    ? [BoxShadow(color: activeColor.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 3))]
                    : [],
              ),
              child: Column(
                children: [
                  Icon(s['icon'] as IconData,
                      size: 18, color: isActive ? Colors.white : Colors.grey.shade500),
                  const SizedBox(height: 4),
                  Text(s['label'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isActive ? Colors.white : Colors.grey.shade500,
                      )),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Warna per sensor — konsisten dengan kartu sensor di atas
  Color _getSensorColor(String sensor) {
    switch (sensor) {
      case 'ph':
        return Colors.blue.shade700;
      case 'tds':
        return Colors.orange.shade700;
      case 'suhu_air':
      default:
        return const Color(0xFF1E824C);
    }
  }

  // ─── Konfigurasi threshold per sensor ──────────────────────────────────────
  // Diambil dari logika status yang sudah Anda definisikan di bawah
  Map<String, dynamic> _getSensorConfig(String sensor) {
    switch (sensor) {
      case 'ph':
        return {
          'firebaseKey': 'ph',
          'label': 'pH',
          'unit': '',
          'color': Colors.blue.shade700,
          'thresholdLow': 5.5,
          'thresholdHigh': 6.5,
          'yPadding': 0.5,
        };
      case 'tds':
        return {
          'firebaseKey': 'tds',
          'label': 'TDS',
          'unit': 'ppm',
          'color': Colors.orange.shade700,
          'thresholdLow': 800.0,
          'thresholdHigh': 1200.0,
          'yPadding': 80.0,
        };
      case 'suhu_air':
      default:
        return {
          'firebaseKey': 'suhu_air',
          'label': 'Suhu Air',
          'unit': '°C',
          'color': const Color(0xFF1E824C),
          'thresholdLow': 20.0,
          'thresholdHigh': 28.0,
          'yPadding': 2.0,
        };
    }
  }

  // ─── Grafik utama ───────────────────────────────────────────────────────────
  Widget _buildChartPlaceholder() {
    final config = _getSensorConfig(_activeSensor);
    final Color sensorColor = config['color'] as Color;
    final double thresholdLow = config['thresholdLow'] as double;
    final double thresholdHigh = config['thresholdHigh'] as double;
    final double yPadding = config['yPadding'] as double;
    final String firebaseKey = config['firebaseKey'] as String;
    final String unit = config['unit'] as String;

    return Container(
      height: 280,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 16, 15, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: StreamBuilder(
        stream: FirebaseDatabase.instance.ref('riwayat_sensor').limitToLast(25).onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: sensorColor));
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(
              child: Text("Menunggu data riwayat...", style: TextStyle(color: Colors.grey)),
            );
          }

          Map<dynamic, dynamic> rawData =
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          List<Map<String, dynamic>> historyList = [];

          rawData.forEach((key, value) {
            final rawVal = value[firebaseKey];
            if (rawVal == null) return;
            final parsed = double.tryParse(rawVal.toString());
            if (parsed == null) return;
            historyList.add({
              'nilai': parsed,
              'timestamp': (value['timestamp'] is int)
                  ? value['timestamp']
                  : DateTime.now().millisecondsSinceEpoch,
            });
          });

          historyList.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

          if (historyList.length < 2) {
            return const Center(child: Text("Mengumpulkan data..."));
          }

          // Buat spots
          List<FlSpot> spots = List.generate(
            historyList.length,
            (i) => FlSpot(i.toDouble(), historyList[i]['nilai']),
          );

          // ── Rentang Y dinamis — kunci agar perubahan kecil terlihat ──────
          final List<double> allValues =
              historyList.map<double>((e) => e['nilai'] as double).toList();
          final double dataMin = allValues.reduce(min);
          final double dataMax = allValues.reduce(max);
          final double yMin =
              (min(dataMin, thresholdLow) - yPadding).floorToDouble();
          final double yMax =
              (max(dataMax, thresholdHigh) + yPadding).ceilToDouble();

          final double currentValue = allValues.last;
          final bool isNormal =
              currentValue >= thresholdLow && currentValue <= thresholdHigh;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: nilai terkini + badge status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${currentValue.toStringAsFixed(2)}${ unit.isNotEmpty ? ' $unit' : ''}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: sensorColor,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isNormal
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
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
              ),
              const SizedBox(height: 8),

              // Legenda threshold
              Row(
                children: [
                  _buildLegendItem(color: Colors.red.shade300, label: 'Batas atas', dashed: true),
                  const SizedBox(width: 12),
                  _buildLegendItem(color: Colors.blue.shade300, label: 'Batas bawah', dashed: true),
                ],
              ),
              const SizedBox(height: 6),

              // Grafik
              Expanded(
                child: LineChart(
                  LineChartData(
                    minY: yMin,
                    maxY: yMax,

                    // Tooltip saat grafik ditekan
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (_) => sensorColor,
                        getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                          return touchedBarSpots
                              .where((s) => s.barIndex == 0)
                              .map((barSpot) {
                            return LineTooltipItem(
                              '${barSpot.y.toStringAsFixed(2)}${unit.isNotEmpty ? ' $unit' : ''}\n',
                              const TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold),
                              children: [
                                TextSpan(
                                  text: DateFormat('HH:mm').format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        historyList[barSpot.x.toInt()]['timestamp']),
                                  ),
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                      fontWeight: FontWeight.normal),
                                ),
                              ],
                            );
                          }).toList();
                        },
                      ),
                    ),

                    lineBarsData: [
                      // Dataset 1: nilai sensor aktual
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: sensorColor,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        // Titik merah jika di luar batas normal
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            final bool abnormal = spot.y < thresholdLow ||
                                spot.y > thresholdHigh;
                            return FlDotCirclePainter(
                              radius: abnormal ? 3.5 : 2,
                              color: abnormal ? Colors.red.shade300 : Colors.white,
                              strokeWidth: 2,
                              strokeColor:
                                  abnormal ? Colors.red.shade600 : sensorColor,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: sensorColor.withOpacity(0.1),
                        ),
                      ),

                      // Dataset 2: garis batas atas (merah putus-putus)
                      LineChartBarData(
                        spots: [
                          FlSpot(0, thresholdHigh),
                          FlSpot((historyList.length - 1).toDouble(), thresholdHigh),
                        ],
                        isCurved: false,
                        color: Colors.red.shade300,
                        barWidth: 1.5,
                        dotData: const FlDotData(show: false),
                        dashArray: [6, 4],
                      ),

                      // Dataset 3: garis batas bawah (biru putus-putus)
                      LineChartBarData(
                        spots: [
                          FlSpot(0, thresholdLow),
                          FlSpot((historyList.length - 1).toDouble(), thresholdLow),
                        ],
                        isCurved: false,
                        color: Colors.blue.shade300,
                        barWidth: 1.5,
                        dotData: const FlDotData(show: false),
                        dashArray: [6, 4],
                      ),
                    ],

                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),

                      // Sumbu Y kiri: mengikuti rentang dinamis
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 36,
                          interval: (yMax - yMin) / 4,
                          getTitlesWidget: (value, meta) {
                            if (value == meta.min || value == meta.max) {
                              return const Text('');
                            }
                            final String label = value % 1 == 0
                                ? '${value.toInt()}'
                                : value.toStringAsFixed(1);
                            return Text(label,
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.grey));
                          },
                        ),
                      ),

                      // Sumbu X bawah: label jam setiap 6 titik
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            int index = value.toInt();
                            if (index % 6 != 0 &&
                                index != historyList.length - 1) {
                              return const Text('');
                            }
                            DateTime time = DateTime.fromMillisecondsSinceEpoch(
                                historyList[index]['timestamp']);
                            return Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text(
                                DateFormat('HH:mm').format(time),
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
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: Colors.grey.withOpacity(0.1),
                        strokeWidth: 1,
                      ),
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

  // Widget legenda kecil di bawah header grafik
  Widget _buildLegendItem({
    required Color color,
    required String label,
    bool dashed = false,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 10,
          child: CustomPaint(
            painter: _DashedLinePainter(color: color, dashed: dashed),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  // ─── Logika status semua sensor (tidak diubah dari kode asli) ───────────────

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

  String _getSuhuStatus(dynamic val) {
    double suhu = double.tryParse(val.toString()) ?? 0.0;
    if (suhu >= 20 && suhu <= 28) return "Ideal";
    return "Panas";
  }

  Color _getSuhuStatusColor(dynamic val) {
    double suhu = double.tryParse(val.toString()) ?? 0.0;
    return (suhu >= 20 && suhu <= 28) ? Colors.green : Colors.red;
  }

  String _getTinggiStatus(dynamic val) {
    double tinggi = double.tryParse(val.toString()) ?? 0.0;
    if (tinggi >= 50) return "Aman";
    return "Kritis";
  }

  Color _getTinggiStatusColor(dynamic val) {
    double tinggi = double.tryParse(val.toString()) ?? 0.0;
    return (tinggi >= 50) ? Colors.green : Colors.red;
  }

  // ─── Widget banner (tidak diubah dari kode asli) ────────────────────────────

  Widget _buildMainBanner(double ph, double suhuUdara, double tinggiAir) {
    Color bannerColor = const Color(0xFF1E824C);
    String statusTitle = "KONDISI OPTIMAL";
    String statusMessage = "Data sensor stabil. Lingkungan ideal untuk pertumbuhan.";
    IconData statusIcon = Icons.eco;

    if (tinggiAir < 20.0) {
      bannerColor = Colors.red.shade700;
      statusTitle = "AIR KRITIS!";
      statusMessage = "Tinggi air tandon di bawah 20%. Segera isi ulang agar pompa tidak rusak.";
      statusIcon = Icons.water_drop_outlined;
    } else if (ph < 5.5 || ph > 6.5) {
      bannerColor = Colors.orange.shade800;
      statusTitle = "pH ABNORMAL";
      statusMessage = "Nilai pH ($ph) di luar ambang batas. Periksa kepekatan larutan nutrisi!";
      statusIcon = Icons.science_outlined;
    } else if (suhuUdara < 20.0 || suhuUdara > 28.0) {
      bannerColor = Colors.orange.shade800;
      statusTitle = "SUHU EKSTREM";
      statusMessage = "Suhu saat ini ($suhuUdara°C). Pastikan sirkulasi udara di area tanam baik.";
      statusIcon = Icons.thermostat_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: BoxDecoration(
        color: bannerColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: bannerColor.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: Colors.white, size: 42),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(statusTitle,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0)),
                const SizedBox(height: 6),
                Text(statusMessage,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 13, height: 1.4)),
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
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6)),
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
                  radius: 18,
                  child: Icon(icon, color: iconColor, size: 18)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Text(status,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF263238))),
              const SizedBox(width: 4),
              Text(unit,
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.blueGrey[200],
                      fontWeight: FontWeight.w600)),
            ],
          ),
          Text(title,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.blueGrey[400],
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─── Painter untuk garis legenda putus-putus ─────────────────────────────────
class _DashedLinePainter extends CustomPainter {
  final Color color;
  final bool dashed;
  const _DashedLinePainter({required this.color, this.dashed = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    if (!dashed) {
      canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);
      return;
    }

    double x = 0;
    const double dashWidth = 4;
    const double gapWidth = 3;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset(x + dashWidth, size.height / 2),
        paint,
      );
      x += dashWidth + gapWidth;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}