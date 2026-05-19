import 'dart:math' as math;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/inference_result.dart';
import 'inference_service.dart';

class TFLiteInferenceService implements InferenceService {
  late final Interpreter _interpreter;
  final List<String> labels;

  TFLiteInferenceService({
    required this.labels,
  });

  int modelLoadTimeMs = 0;
  Future<void> load() async {
    final stopwatch = Stopwatch()..start();

    _interpreter = await Interpreter.fromAsset(
      'assets/model/model.tflite',
      options: InterpreterOptions()..threads = 4,
    );

    stopwatch.stop();

    modelLoadTimeMs = stopwatch.elapsedMilliseconds;
  }

  /// Softmax for converting logits -> probabilities
  List<double> _softmax(List<double> logits) {
    final maxLogit = logits.reduce((a, b) => a > b ? a : b);

    final exps = logits.map((x) => math.exp(x - maxLogit)).toList();
    final sum = exps.reduce((a, b) => a + b);

    return exps.map((x) => x / sum).toList();
  }

  @override
  Future<InferenceResult> infer(Float32List input, int preprocessTimeMs,) async {
    final inputTensor = input.reshape([1, 224, 224, 3]);

    final output =
        List.filled(labels.length, 0.0).reshape([1, labels.length]);

    final totalWatch = Stopwatch()..start();

    final inferenceWatch = Stopwatch()..start();

    _interpreter.run(inputTensor, output);

    inferenceWatch.stop();

    // Raw logits
    final logits = List<double>.from(output[0]);

    // Convert logits -> probabilities
    final probs = _softmax(logits);

    int bestIndex = 0;
    double bestScore = probs[0];

    for (int i = 1; i < probs.length; i++) {
      if (probs[i] > bestScore) {
        bestScore = probs[i];
        bestIndex = i;
      }
    }

    totalWatch.stop();
    return InferenceResult(
      label: labels[bestIndex],
      confidence: bestScore, // ALWAYS 0.0–1.0 now
      classIndex: bestIndex,
      modelVersion: 'tflite-v1',

      preprocessTimeMs: preprocessTimeMs,
      inferenceTimeMs: inferenceWatch.elapsedMilliseconds,
      totalTimeMs: totalWatch.elapsedMilliseconds,
    );
  }

  void dispose() {
    _interpreter.close();
  }
}
