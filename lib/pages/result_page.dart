import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/inference_controller.dart';
import 'result_definitions.dart';
import 'dart:io';

const double rejectionThreshold = 0.40;

class ResultPage extends StatefulWidget {
  const ResultPage({super.key});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
    @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showResultDisclaimer();
    });
  }

  void _showResultDisclaimer() {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text("Catatan Penting"),
        content: Text(
          "Hasil ini merupakan prediksi AI dengan tingkat akurasi sekitar 80%.\n\n"
          "Jika Anda merasa kondisi hewan tidak normal, "
          "silakan konsultasikan dengan dokter hewan.",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<InferenceController>().state;

    if (state.status != InferenceStatus.success || state.result == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final result = state.result!;
    final imageFile = result.imagePath != null ? File(result.imagePath!) : null;

    if (result.confidence < rejectionThreshold) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Hasil Deteksi"),
          backgroundColor: Colors.lightBlue.shade300,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.orange),
                const SizedBox(height: 24),
                const Text(
                  "Model Tidak Yakin",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Tingkat keyakinan di bawah 40%.\n"
                  "Silakan ambil foto yang lebih jelas, "
                  "lebih dekat, dan dengan latar belakang yang sederhana.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue.shade300,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      context.read<InferenceController>().reset();
                      Navigator.pop(context);
                    },
                    child: const Text("Coba Lagi"),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final config = resultDefinitions[result.label];

    if (config == null) {
      return const Scaffold(body: Center(child: Text("Result not supported")));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.lightBlue.shade300,
        foregroundColor: Colors.white,
        title: const Text("Hasil Deteksi"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The image that was just taken
              if (imageFile != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    imageFile,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              /// RESULT CARD
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: config.color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: config.color.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(config.icon, size: 36, color: config.color),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            config.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// DESCRIPTION
              const Text(
                "Penjelasan",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(config.description, style: const TextStyle(fontSize: 15)),

              const SizedBox(height: 28),

              /// PERFORMANCE METRICS
              const Text(
                "Performance Metrics",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      "Model Version: ${result.modelVersion}",
                      style: const TextStyle(fontSize: 15),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Preprocessing Time: ${result.preprocessTimeMs} ms",
                      style: const TextStyle(fontSize: 15),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Inference Time: ${result.inferenceTimeMs} ms",
                      style: const TextStyle(fontSize: 15),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Total Time: ${result.totalTimeMs} ms",
                      style: const TextStyle(fontSize: 15),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Estimated FPS: ${(1000 / result.totalTimeMs).toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              /// ACTIONS
              const Text(
                "Rekomendasi",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              ...config.actions.map(
                (action) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.lightBlue,
                      side: BorderSide(color: Colors.lightBlue.shade300),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final uri = Uri.parse(action.url);
                      if (!await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      )) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Tidak dapat membuka link")),
                        );
                      }
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: Text(action.label),
                  ),
                ),
              ),

              /// BACK BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue.shade300,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    context.read<InferenceController>().reset();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Kembali ke Beranda",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
