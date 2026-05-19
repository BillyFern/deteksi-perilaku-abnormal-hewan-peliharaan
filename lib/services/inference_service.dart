import '/models/inference_result.dart';
import 'dart:typed_data';

abstract class InferenceService {
  Future<InferenceResult> infer(Float32List input, int preprocessTImeMs);
}


