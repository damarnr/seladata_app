// lib/widgets/custom_header.dart
import 'package:flutter/material.dart';
import '../main.dart'; // 1. IMPORT main.dart agar bisa akses scaffoldKey

class CustomHeader extends StatelessWidget {
  final String title;
  final bool showStatus;

  const CustomHeader({
    super.key, 
    this.title = "SelaData", 
    this.showStatus = true
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () {
            // 2. GUNAKAN KUNCI UNTUK BUKA DRAWER
            scaffoldKey.currentState?.openDrawer();
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/header.png',
                  height: 45,
                  errorBuilder: (context, error, stackTrace) => 
                      const Icon(Icons.eco, color: Color(0xFF1E824C), size: 30),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E824C),
                  ),
                ),
              ],
            ),
          ),
        ),

        // STATUS ESP: Tetap di ujung kanan
        if (showStatus)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FADF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "ESP32 Online",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.green[900],
              ),
            ),
          ),
      ],
    );
  }
}