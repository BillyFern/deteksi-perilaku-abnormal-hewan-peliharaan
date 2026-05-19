class InferenceResult {
  final String label;
  final double confidence;
  final int classIndex;
  final String modelVersion;

  // Performance metric
  final int preprocessTimeMs;
  final int inferenceTimeMs;
  final int totalTimeMs;
  final String? imagePath;

  InferenceResult({
    required this.label,
    required this.confidence,
    required this.classIndex,
    required this.modelVersion,

    required this.preprocessTimeMs,
    required this.inferenceTimeMs,
    required this.totalTimeMs,

    this.imagePath,
  });

  InferenceResult copyWithImage(String path) {
    return InferenceResult(
      label: label,
      confidence: confidence,
      classIndex: classIndex,
      modelVersion: modelVersion,
      preprocessTimeMs: preprocessTimeMs,
      inferenceTimeMs: inferenceTimeMs,
      totalTimeMs: totalTimeMs,
      imagePath: path,
    );
  }

}
