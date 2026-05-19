import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/disclaimer_dialog.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.onOpenCamera});

  final VoidCallback onOpenCamera;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('seen_disclaimer') ?? false;

    if (!seen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => DisclaimerDialog(
            onAccept: () async {
              await prefs.setBool('seen_disclaimer', true);
              Navigator.pop(context);
            },
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ===== HEADER =====
          Container(
            height: 200,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8ED6FF), Color(0xFFB8E6FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Sistem Deteksi",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Perilaku Abnormal\nHewan Peliharaan",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "Deteksi perilaku hewan menggunakan\nkecerdasan buatan",
                          style: TextStyle(fontSize: 11, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.pets, size: 48, color: Colors.white),
                ],
              ),
            ),
          ),

          const Spacer(),

          // ===== MAIN ACTION =====
          GestureDetector(
            onTap: widget.onOpenCamera,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFF8ED6FF),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                    color: Colors.black.withOpacity(0.15),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 56,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Cek Perilaku Hewan Anda",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 8),

          const Text(
            "Ambil foto hewan peliharaan Anda\nuntuk mendeteksi perilaku abnormal",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),

          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
