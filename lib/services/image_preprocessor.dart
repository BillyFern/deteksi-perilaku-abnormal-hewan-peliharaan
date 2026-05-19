import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

class ImagePreprocessor {
  static const int imageSize = 224;

  static const List<double> mean = [0.485, 0.456, 0.406];
  static const List<double> std = [0.229, 0.224, 0.225];

  static Future<Map<String, dynamic>> preprocess(
    File imageFile,
  ) async {

    final stopwatch = Stopwatch()..start();

    final bytes = await imageFile.readAsBytes();

    final image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception("Failed to decode image");
    }

    final resized = img.copyResize(
      image,
      width: imageSize,
      height: imageSize,
    );

    final Float32List input =
        Float32List(imageSize * imageSize * 3);

    int index = 0;

    // HWC format
    for (int y = 0; y < imageSize; y++) {
      for (int x = 0; x < imageSize; x++) {

        final pixel = resized.getPixel(x, y);

        final r = pixel.r / 255.0;
        final g = pixel.g / 255.0;
        final b = pixel.b / 255.0;

        input[index++] = (r - mean[0]) / std[0];
        input[index++] = (g - mean[1]) / std[1];
        input[index++] = (b - mean[2]) / std[2];
      }
    }

    stopwatch.stop();

    return {
      'tensor': input,
      'timeMs': stopwatch.elapsedMilliseconds,
    };
  }
}