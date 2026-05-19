import 'package:flutter/material.dart';
import 'result_config.dart';

const Map<String, ResultConfig> resultDefinitions = {
  "Kucing - Normal": ResultConfig(
    title: "Perilaku Normal",
    description:
        "Kucing menunjukkan perilaku yang normal dan sehat. Tidak ada indikasi masalah perilaku.",
    color: Colors.green,
    icon: Icons.pets,
    actions: [
      ResultAction(
        label: "Tips Merawat Kucing Sehat",
        url: "https://www.aspca.org/pet-care/cat-care",
      ),
    ],
  ),

  "Kucing - Agresif": ResultConfig(
    title: "Perilaku Agresif",
    description:
        "Perilaku agresif pada kucing dapat disebabkan oleh stres, rasa takut, atau masalah kesehatan.",
    color: Colors.red,
    icon: Icons.warning,
    actions: [
      ResultAction(
        label: "Mengatasi Agresi pada Kucing",
        url: "https://hellosehat.com/sehat/informasi-kesehatan/kucing-marah/",
      ),
    ],
  ),

  "Kucing - Takut": ResultConfig(
    title: "Kucing Ketakutan",
    description:
        "Kucing tampak ketakutan atau cemas. Lingkungan yang bising atau perubahan mendadak bisa menjadi penyebab.",
    color: Colors.orange,
    icon: Icons.visibility_off,
    actions: [
      ResultAction(
        label: "Cara Menenangkan Kucing",
        url: "https://www.halodoc.com/artikel/bagaimana-cara-mengatasi-kucing-yang-sedang-stres",
      ),
    ],
  ),

  "Kucing - Sakit": ResultConfig(
    title: "Indikasi Sakit",
    description:
        "Perilaku kucing menunjukkan kemungkinan adanya gangguan kesehatan. Segeralah hubungi dokter hewan terdekat anda!",
    color: Colors.deepOrange,
    icon: Icons.local_hospital,
    actions: [
      ResultAction(
        label: "Tanda Kucing Sakit",
        url: "https://hellosehat.com/sehat/informasi-kesehatan/penyakit-pada-kucing/",
      ),
    ],
  ),

  "Anjing - Normal": ResultConfig(
    title: "Perilaku Normal",
    description:
        "Anjing menunjukkan perilaku yang normal dan stabil.",
    color: Colors.green,
    icon: Icons.pets,
    actions: [
      ResultAction(
        label: "Perawatan Anjing Sehat",
        url: "https://www.akc.org/dog-owners/",
      ),
    ],
  ),

  "Anjing - Agresif": ResultConfig(
    title: "Perilaku Agresif",
    description:
        "Perilaku agresif pada anjing bisa berbahaya dan memerlukan perhatian khusus.",
    color: Colors.red,
    icon: Icons.warning_amber,
    actions: [
      ResultAction(
        label: "Mengatasi Agresi Anjing",
        url: "https://hellosehat.com/sehat/informasi-kesehatan/anjing-agresif/",
      ),
    ],
  ),

  "Anjing - Takut": ResultConfig(
    title: "Anjing Ketakutan",
    description:
        "Anjing menunjukkan tanda ketakutan atau kecemasan.",
    color: Colors.orange,
    icon: Icons.remove_red_eye,
    actions: [
      ResultAction(
        label: "Mengurangi Kecemasan Anjing",
        url: "https://www.animalhumanesociety.org/resource/help-your-anxious-or-fearful-dog-gain-confidence",
      ),
    ],
  ),

  "Anjing - Sakit": ResultConfig(
    title: "Indikasi Sakit",
    description:
        "Perilaku anjing menunjukkan kemungkinan masalah kesehatan. Segeralah hubungi dokter hewan terdekat anda!",
    color: Colors.deepOrange,
    icon: Icons.local_hospital,
    actions: [
      ResultAction(
        label: "Tanda Anjing Sakit",
        url: "https://www.halodoc.com/artikel/ketahui-7-cara-tepat-merawat-anjing-yang-sakit",
      ),
    ],
  ),
};
