import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:vehicle_speed_estimator/core/constants/vehicle_classes.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/models/yolo_detection.dart';

/// Hardware-accelerated on-device neural network detector.
/// Runs INT8 quantized SSD MobileNet model on camera frames.
/// Strictly filters out non-vehicles and spurious noise.
class TfliteVehicleDetector {
  TfliteVehicleDetector([this._interpreter]);

  Interpreter? _interpreter;
  bool get isReady => _interpreter != null;

  void initializeFromBuffer(Uint8List modelBytes) {
    try {
      _interpreter = Interpreter.fromBuffer(
        modelBytes,
        options: InterpreterOptions()..threads = 4,
      );
      debugPrint('[TfliteVehicleDetector] Initialized neural network successfully.');
    } catch (e) {
      debugPrint('[TfliteVehicleDetector] Failed to initialize: $e');
    }
  }

  void close() {
    _interpreter?.close();
    _interpreter = null;
  }

  List<YoloDetection> detectVehicles({
    required Uint8List yPlaneBytes,
    required int width,
    required int height,
    int bytesPerRow = 0,
  }) {
    if (_interpreter == null) return const [];

    const inputSize = 300;
    final inputBytes = Uint8List(1 * inputSize * inputSize * 3);
    final stride = bytesPerRow > 0 ? bytesPerRow : width;
    final stepX = width / inputSize;
    final stepY = height / inputSize;

    int inIdx = 0;
    for (int y = 0; y < inputSize; y++) {
      final py = (y * stepY).toInt().clamp(0, height - 1);
      final rowOffset = py * stride;
      for (int x = 0; x < inputSize; x++) {
        final px = (x * stepX).toInt().clamp(0, width - 1);
        final pixelIdx = rowOffset + px;
        final lum = pixelIdx < yPlaneBytes.length ? yPlaneBytes[pixelIdx] : 0;
        inputBytes[inIdx++] = lum;
        inputBytes[inIdx++] = lum;
        inputBytes[inIdx++] = lum;
      }
    }

    final outputBoxes = List.generate(
      1,
      (_) => List.generate(10, (_) => List<double>.filled(4, 0.0)),
    );
    final outputClasses = List.generate(1, (_) => List<double>.filled(10, 0.0));
    final outputScores = List.generate(1, (_) => List<double>.filled(10, 0.0));
    final numDetections = List<double>.filled(1, 0.0);

    final outputs = {
      0: outputBoxes,
      1: outputClasses,
      2: outputScores,
      3: numDetections,
    };

    try {
      _interpreter!.runForMultipleInputs([inputBytes], outputs);
    } catch (e) {
      debugPrint('[TfliteVehicleDetector] Inference error: $e');
      return const [];
    }

    final count = numDetections[0].toInt().clamp(0, 10);
    final results = <YoloDetection>[];

    for (int i = 0; i < count; i++) {
      final score = outputScores[0][i];
      if (score < 0.45) continue;

      final rawClass = outputClasses[0][i].toInt();
      final vClass = _mapCocoClass(rawClass);
      if (vClass == null) continue;

      final box = outputBoxes[0][i];
      final top = box[0].clamp(0.0, 1.0);
      final left = box[1].clamp(0.0, 1.0);
      final bottom = box[2].clamp(0.0, 1.0);
      final right = box[3].clamp(0.0, 1.0);

      final boxW = right - left;
      final boxH = bottom - top;
      if (boxW < 0.04 || boxH < 0.04 || boxW > 0.95 || boxH > 0.95) continue;

      results.add(
        YoloDetection(
          vehicleClass: vClass,
          confidence: score,
          left: left,
          top: top,
          right: right,
          bottom: bottom,
          histogram: List.filled(24, 1.0 / math.sqrt(24.0)),
        ),
      );
    }

    return results;
  }

  static VehicleClass? _mapCocoClass(int classId) {
    switch (classId) {
      case 2:
      case 3:
        return VehicleClass.car;
      case 1:
      case 4:
        return VehicleClass.motorcycle;
      case 5:
      case 6:
        return VehicleClass.bus;
      case 7:
      case 8:
        return VehicleClass.truck;
      default:
        return null;
    }
  }
}
