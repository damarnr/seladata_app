import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart'; // Import Firebase
import '../widgets/custom_header.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final DatabaseReference _logsRef = FirebaseDatabase.instance.ref('logs');

  // FUNGSI KONFIRMASI HAPUS
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
              // Menghapus data spesifik berdasarkan ID unik di Firebase
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
              _buildChartBox(),

              const SizedBox(height: 30),

              const Text("Aktivitas Terkini", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),

              // STREAM LIST AKTIVITAS
              StreamBuilder(
                stream: _logsRef.orderByChild('timestamp').limitToLast(20).onValue,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                    Map<dynamic, dynamic> logsMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                    
                    // Mengambil entries agar kita mendapatkan Key (ID) dan Value (Data)
                    List<MapEntry<dynamic, dynamic>> logsList = logsMap.entries.toList();
                    
                    // Urutkan berdasarkan waktu terbaru (timestamp)
                    logsList.sort((a, b) => (b.value['timestamp'] ?? 0).compareTo(a.value['timestamp'] ?? 0));

                    return Column(
                      children: logsList.map((entry) {
                        return _buildLogTile(
                          entry.key, // ID Unik Firebase
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

  Widget _buildChartBox() {
    return Container(
      height: 220, width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.stacked_line_chart, size: 50, color: Colors.green),
            Text("Grafik stabilitas real-time", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildLogTile(String logId, String title, String desc, String time, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
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
              // TOMBOL HAPUS BARU
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