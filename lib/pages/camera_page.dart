import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/inference_controller.dart';
import '../models/inference_result.dart';

const double rejectionThreshold = 0.40;

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage>
    with WidgetsBindingObserver {
  CameraController? _controller;

  bool _isCameraReady = false;
  bool _isInitializing = false;
  bool _isDisposed = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickFromGallery(BuildContext context) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) return;

    final file = File(image.path);

    if (!context.mounted) return;

    await context.read<InferenceController>().runInference(file);

    if (!context.mounted) return;

    Navigator.pushNamed(context, '/result');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  /// ============================
  /// CAMERA INITIALIZATION
  /// ============================
  Future<void> _initCamera() async {
    if (_isInitializing || _isDisposed) return;

    _isInitializing = true;
    debugPrint("Starting camera init");

    try {
      final cameras = await availableCameras();
      if (_isDisposed || cameras.isEmpty) return;

      final backCamera = cameras.first;
      debugPrint("Using camera: ${backCamera.name}");

      final controller = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      _controller = controller;

      debugPrint("Initializing controller...");
      await controller.initialize();

      if (!mounted || _isDisposed) return;

      setState(() {
        _isCameraReady = true;
      });

      debugPrint("Camera initialized!");
    } catch (e, stack) {
      debugPrint("Camera error: $e");
      debugPrint("$stack");
    } finally {
      _isInitializing = false;
    }
  }

  /// ============================
  /// APP LIFECYCLE HANDLING
  /// ============================
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null) return;

    if (state == AppLifecycleState.paused) {
      debugPrint("App paused → disposing camera");
      _controller?.dispose();
      _controller = null;
      _isCameraReady = false;
    } else if (state == AppLifecycleState.resumed) {
      debugPrint("App resumed → reinitializing camera");
      _initCamera();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  /// ============================
  /// UI
  /// ============================
  @override
  Widget build(BuildContext context) {
    final inferenceState = context.watch<InferenceController>().state;
    final isLoading = inferenceState.status == InferenceStatus.loading;

    if (inferenceState.status == InferenceStatus.error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(inferenceState.errorMessage ?? "Inference failed"),
            backgroundColor: Colors.red,
          ),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Camera")),
      body: _isCameraReady && _controller != null
          ? Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Center(
                        child: CameraPreview(_controller!),
                      ),

                      if (isLoading) const _LoadingOverlay(),

                      if (inferenceState.status ==
                          InferenceStatus.success)
                        _ResultOverlay(
                          result: inferenceState.result!,
                          onViewDetails: () {
                            Navigator.pushNamed(context, '/result');
                          },
                        ),

                      if (inferenceState.status ==
                          InferenceStatus.error)
                        _ErrorOverlay(
                          message: inferenceState.errorMessage ??
                              "Inference failed",
                          onRetry: () {
                            context
                                .read<InferenceController>()
                                .reset();
                          },
                        ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed:
                        (!_isCameraReady || isLoading)
                            ? null
                            : _captureImage,
                    child: Text(
                      isLoading ? "Processing..." : "Capture",
                    ),
                  ),
                  
                ),
                TextButton.icon(
                  onPressed: () => _pickFromGallery(context),
                  icon: const Icon(Icons.photo),
                  label: const Text("Pilih dari Galeri"),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  /// ============================
  /// IMAGE CAPTURE
  /// ============================
  Future<void> _captureImage() async {
    final controller = _controller;

    if (controller == null) return;
    if (!controller.value.isInitialized) return;
    if (controller.value.isTakingPicture) return;

    try {
      final image = await controller.takePicture();
      debugPrint("Image saved at: ${image.path}");

      if (!mounted) return;

      context
          .read<InferenceController>()
          .runInference(File(image.path));
    } catch (e, stack) {
      debugPrint("Capture error: $e");
      debugPrint("$stack");
    }
  }
}

/// ============================
/// OVERLAYS
/// ============================
class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 12),
            Text(
              "Running inference...",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultOverlay extends StatelessWidget {
  final InferenceResult result;
  final VoidCallback onViewDetails;

  const _ResultOverlay({
    required this.result,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRejected = result.confidence < rejectionThreshold;

    return Container(
      color: Colors.black.withOpacity(0.75),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isRejected
                      ? "Model Tidak Yakin"
                      : "Detection Result",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                if (!isRejected) ...[
                  Text(
                    result.label,
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Confidence: ${(result.confidence * 100).toStringAsFixed(2)}%",
                  ),
                ] else ...[
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Confidence: ${(result.confidence * 100).toStringAsFixed(2)}%",
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Tingkat keyakinan di bawah 40%.\n"
                    "Silakan ambil foto lebih dekat,\n"
                    "lebih jelas, dan dengan latar sederhana.",
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 24),

                if (!isRejected)
                  ElevatedButton(
                    onPressed: onViewDetails,
                    child: const Text("View Details"),
                  ),

                TextButton(
                  onPressed: () {
                    context.read<InferenceController>().reset();
                  },
                  child: const Text("Try Again"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorOverlay extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorOverlay({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message,
                style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}
