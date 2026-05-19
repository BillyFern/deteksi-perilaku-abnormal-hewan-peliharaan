import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/inference_controller.dart';
import 'services/tflite_inference_service.dart';

import 'pages/camera_page.dart';
import 'pages/main_page.dart';
import 'pages/result_page.dart';

// Navigator routes
const String homeRoute = '/';
const String resultRoute = '/result';
const String cameraRoute = '/camera';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final tfliteService = TFLiteInferenceService(
    labels: const [
      'Kucing - Agresif',
      'Kucing - Normal',
      'Kucing - Takut',
      'Kucing - Sakit',
      'Anjing - Agresif',
      'Anjing - Normal',
      'Anjing - Takut',
      'Anjing - Sakit',
    ],
  );

  await tfliteService.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => InferenceController(tfliteService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Deteksi Perilaku Hewan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8ED6FF),
        ),
        useMaterial3: true,
      ),
      initialRoute: homeRoute,
      routes: {
        homeRoute: (_) => const MainShell(),
        resultRoute: (_) => const ResultPage(),
        cameraRoute: (_) => const CameraPage(),
      },
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void switchTab(int index) {
    setState(() => _currentIndex = index);
  }

  late final List<Widget> _pages = [
    MyHomePage(onOpenCamera: () => switchTab(1)),
    const CameraPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: switchTab,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Deteksi',
          ),
        ],
      ),
    );
  }
}
