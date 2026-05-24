import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart'; 
import '../widgets/custom_header.dart';

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  final DatabaseReference _controlRef = FirebaseDatabase.instance.ref('control');

  // MENYESUAIKAN PENGIRIMAN LOGS: Hanya mendeteksi Pompa Air dan Mode
  void _updateFirebase(String key, dynamic value) {
    _controlRef.child(key).set(value);

    String deviceName = key == 'pompa' ? "Pompa Air" : "Mode";
    String action = value == 1 ? "Dinyalakan" : "Dimatikan";
    
    if (key != 'mode_auto' && key != 'tds_target_low' && key != 'tds_target_high' && key != 'waktu_tanam') { 
      DatabaseReference logRef = FirebaseDatabase.instance.ref('logs').push();
      logRef.set({
        'device': deviceName,
        'action': action,
        'time': "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}",
        'timestamp': ServerValue.timestamp,
      });
    }
  }

  // OTOMASI ADAPTIF NUTRISI: Tetap aktif berdasarkan Hari Setelah Tanam (HST)
  void _checkAndApplyAutoPreset({
    required int hst, 
    required bool isAutoMode, 
    required double currentLow, 
    required double currentHigh
  }) {
    if (!isAutoMode) return;

    int recommendedLow = 600;
    int recommendedHigh = 800;

    if (hst < 7) {
      recommendedLow = 400;       
      recommendedHigh = 550;
    } else if (hst < 14) {
      recommendedLow = 600;       
      recommendedHigh = 750;
    } else if (hst < 25) {
      recommendedLow = 800;       
      recommendedHigh = 950;
    } else {
      recommendedLow = 1000;      
      recommendedHigh = 1200;
    }

    if (currentLow.toInt() != recommendedLow || currentHigh.toInt() != recommendedHigh) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controlRef.update({
          'tds_target_low': recommendedLow,
          'tds_target_high': recommendedHigh,
        });
      });
    }
  }

  // MODAL SIKLUS TANAM BARU
  void _showResetSiklusDialog() {
    final TextEditingController umurController = TextEditingController(text: "10"); 

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.gavel_rounded, color: Color(0xFF1E824C)),
            SizedBox(width: 10),
            Text("Siklus Tanam Baru", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Berapa umur bibit selada saat dipindahkan ke modul hidroponik saat ini?"),
            const SizedBox(height: 15),
            TextField(
              controller: umurController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Umur Bibit (Hari)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                prefixIcon: const Icon(Icons.shutter_speed),
                suffixText: "Hari",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E824C),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              int umurBibit = int.tryParse(umurController.text) ?? 0;
              
              int milidetikPerHari = 24 * 60 * 60 * 1000;
              int waktuSekarang = DateTime.now().millisecondsSinceEpoch;
              int waktuTanamLogis = waktuSekarang - (umurBibit * milidetikPerHari);

              _updateFirebase('waktu_tanam', waktuTanamLogis);
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Siklus berhasil diatur! Dimulai dari $umurBibit HST.")),
              );
            },
            child: const Text("Mulai Siklus", style: TextStyle(color: Colors.white)),
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
        child: StreamBuilder(
          stream: _controlRef.onValue,
          builder: (context, snapshot) {
            bool isAutoMode = false;
            bool isPompaOn = false;
            double tdsTargetLow = 600;
            double tdsTargetHigh = 800;
            int waktuTanam = DateTime.now().millisecondsSinceEpoch;

            if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
              Map<dynamic, dynamic> data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
              isAutoMode = (data['mode_auto'] ?? 0) == 1;
              isPompaOn = (data['pompa'] ?? 0) == 1;
              tdsTargetLow = double.tryParse(data['tds_target_low'].toString()) ?? 600;
              tdsTargetHigh = double.tryParse(data['tds_target_high'].toString()) ?? 800;
              waktuTanam = data['waktu_tanam'] ?? DateTime.now().millisecondsSinceEpoch;
            }

            // HITUNG UMUR TANAMAN
            int waktuSekarang = DateTime.now().millisecondsSinceEpoch;
            int hst = ((waktuSekarang - waktuTanam) / (24 * 60 * 60 * 1000)).floor();
            if (hst < 0) hst = 0;

            // PENCOCOKAN AMBANG NUTRISI OTOMATIS
            _checkAndApplyAutoPreset(
              hst: hst,
              isAutoMode: isAutoMode,
              currentLow: tdsTargetLow,
              currentHigh: tdsTargetHigh,
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomHeader(title: "SelaData"),
                  const SizedBox(height: 30),

                  // 1. KARTU SELEKSI MODE (AUTOMATIC VS MANUAL)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isAutoMode ? const Color(0xFF1E824C) : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isAutoMode ? Colors.white24 : const Color(0xFFD1FADF),
                          radius: 25,
                          child: Icon(
                            isAutoMode ? Icons.auto_awesome : Icons.touch_app,
                            color: isAutoMode ? Colors.white : const Color(0xFF1E824C),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isAutoMode ? "Mode Otomatis Aktif" : "Mode Manual Aktif",
                                style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold,
                                  color: isAutoMode ? Colors.white : Colors.black87,
                                ),
                              ),
                              Text(
                                isAutoMode ? "Sistem bekerja berdasarkan sensor" : "Kendali penuh di tangan Anda",
                                style: TextStyle(fontSize: 12, color: isAutoMode ? Colors.white70 : Colors.black45),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: isAutoMode,
                          onChanged: (val) => _updateFirebase('mode_auto', val ? 1 : 0),
                          activeColor: Colors.white,
                          activeTrackColor: Colors.green[300],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 2. KARTU MONITORING SIKLUS TANAM (HST)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Siklus Tanam SelaData", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("$hst HST", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green[900])),
                                const Text("Hari Setelah Tanam", style: TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(15)),
                              child: Text(
                                hst < 7 ? "Bibit Awal" : (hst < 14 ? "Vegetatif" : (hst < 25 ? "Pembesaran" : "Siap Panen")),
                                style: TextStyle(color: Colors.green.shade800, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.green.shade300),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            icon: const Icon(Icons.refresh, size: 18, color: Color(0xFF1E824C)),
                            label: const Text("Atur Ulang Siklus Tanam", style: TextStyle(color: Color(0xFF1E824C), fontSize: 13, fontWeight: FontWeight.bold)),
                            onPressed: _showResetSiklusDialog,
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 3. AMBANG NUTRISI OTOMATIS (RANGE SLIDER)
                  Text("Aturan Nutrisi Otomatis", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])),
                  const SizedBox(height: 15),
                  
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: isAutoMode ? 0.7 : 1.0, 
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Batas Ambang PPM", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Icon(isAutoMode ? Icons.auto_awesome : Icons.tune, color: Colors.green[800], size: 24),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Rentang Target: ${tdsTargetLow.toInt()} PPM - ${tdsTargetHigh.toInt()} PPM",
                            style: const TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                          const SizedBox(height: 15),
                          
                          IgnorePointer(
                            ignoring: isAutoMode,
                            child: RangeSlider(
                              values: RangeValues(tdsTargetLow, tdsTargetHigh),
                              min: 300,   
                              max: 1500,  
                              divisions: 24, 
                              activeColor: const Color(0xFF185FA5),
                              inactiveColor: Colors.grey[200],
                              labels: RangeLabels('${tdsTargetLow.toInt()} PPM', '${tdsTargetHigh.toInt()} PPM'),
                              onChanged: (RangeValues newValues) {
                                if (newValues.end - newValues.start >= 100) {
                                  _controlRef.child('tds_target_low').set(newValues.start.toInt());
                                  _controlRef.child('tds_target_high').set(newValues.end.toInt());
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            isAutoMode 
                                ? "*Sistem mendeteksi $hst HST. Rentang nutrisi telah disesuaikan secara otomatis."
                                : "*Mode Otomatis MATI. Anda bisa menggeser slider untuk mengatur batas nutrisi manual.",
                            style: TextStyle(
                              fontSize: 11, 
                              color: isAutoMode ? Colors.green[700] : Colors.grey, 
                              fontStyle: FontStyle.italic,
                              fontWeight: isAutoMode ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 4. KONTROL MANUAL PERANGKAT (HANYA POMPA AIR)
                  Text("Kontrol Manual Perangkat", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])),
                  const SizedBox(height: 15),

                  IgnorePointer(
                    ignoring: isAutoMode, 
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: isAutoMode ? 0.5 : 1.0,
                      child: Column(
                        children: [
                          _buildControlCard(
                            icon: Icons.opacity,
                            title: "Pompa air",
                            state: isPompaOn ? "Aktif" : "Siaga",
                            color: const Color(0xFFD1FADF),
                            iconColor: Colors.green[800]!,
                            isOn: isPompaOn,
                            onChanged: (val) => _updateFirebase('pompa', val ? 1 : 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildControlCard({
    required IconData icon, required String title, required String state,
    required Color color, required Color iconColor, required bool isOn,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(backgroundColor: color, radius: 25, child: Icon(icon, color: iconColor, size: 28)),
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
          Text("Status: $state", style: const TextStyle(color: Colors.black45, fontSize: 14)),
        ],
      ),
    );
  }
}