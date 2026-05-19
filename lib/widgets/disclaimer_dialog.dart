import 'package:flutter/material.dart';

class DisclaimerDialog extends StatelessWidget {
  final VoidCallback onAccept;

  const DisclaimerDialog({super.key, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Pemberitahuan Penting"),
      content: const Text(
        "Model AI ini hanya memiliki akurasi sekitar 80%.\n\n"
        "Hasil Deteksi tidak boleh dianggap sebagai diagnosis medis.\n\n"
        "Jika Anda mencurigai hewan Anda sakit atau dalam kondisi berbahaya, "
        "segera konsultasikan dengan dokter hewan profesional.",
      ),
      actions: [
        ElevatedButton(
          onPressed: onAccept,
          child: const Text("Saya Mengerti"),
        ),
      ],
    );
  }
}