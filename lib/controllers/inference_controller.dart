import '/models/inference_result.dart';
import '/services/inference_service.dart';
import 'package:flutter/foundation.dart';
import '/services/image_preprocessor.dart';
import 'package:flutter/material.dart';
import 'dart:io';

enum InferenceStatus {
  idle,
  loading,
  success,
  error,
}


class InferenceState {
  final InferenceStatus status;
  final InferenceResult? result;
  final String? errorMessage;

  const InferenceState({
    required this.status,
    this.result,
    this.errorMessage,
  });

  factory InferenceState.idle() {
    return const InferenceState(status: InferenceStatus.idle);
  }

  factory InferenceState.loading() {
    return const InferenceState(status: InferenceStatus.loading);
  }

  factory InferenceState.success(InferenceResult result) {
    return InferenceState(
      status: InferenceStatus.success,
      result: result,
    );
  }

  factory InferenceState.error(String message) {
    return InferenceState(
      status: InferenceStatus.error,
      errorMessage: message,
    );
  }
}


class InferenceController extends ChangeNotifier {
  final InferenceService inferenceService;

  InferenceState _state = InferenceState.idle();
  InferenceState get state => _state;

  InferenceController(this.inferenceService);

  Future<void> runInference(File image) async {
    _state = InferenceState.loading();
    notifyListeners();

    try {
      final preprocessResult = await ImagePreprocessor.preprocess(image);
      final inputTensor = preprocessResult['tensor'];
      final preprocessTime = preprocessResult['timeMs'];

      final rawResult = await inferenceService.infer(inputTensor, preprocessTime);

      final enrichedResult = rawResult.copyWithImage(image.path);

      _state = InferenceState.success(enrichedResult);
    } catch (e) {
      _state = InferenceState.error(e.toString());
    }

    notifyListeners();
  }

  void reset() {
    _state = InferenceState.idle();
    notifyListeners();
  }
}
