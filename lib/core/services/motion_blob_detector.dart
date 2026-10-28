import 'dart:math' as math;
import 'dart:typed_data';

import 'package:vehicle_speed_estimator/core/constants/vehicle_classes.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/models/yolo_detection.dart';

/// Multi-object motion segmentation and vehicle blob detector.
/// Converts raw camera luminance frames into localized vehicle detections
/// with unit-normalized 24-bin color/intensity histograms.
class MotionBlobDetector {
  const MotionBlobDetector();

  static const int gridW = 48;
  static const int gridH = 32;

  /// Downsamples raw camera frame into [currGrid] (48x32).
  void sampleGrid(
    Uint8List bytes,
    int width,
    int height,
    int bytesPerRow,
    Uint8List currGrid,
  ) {
    final stepX = width ~/ gridW;
    final stepY = height ~/ gridH;
    final stride = bytesPerRow > 0 ? bytesPerRow : width;
    if (stepX <= 0 || stepY <= 0) return;

    for (int gy = 0; gy < gridH; gy++) {
      final py = (gy * stepY) + (stepY ~/ 2);
      final rowOffset = py * stride;
      final gridRowOffset = gy * gridW;

      for (int gx = 0; gx < gridW; gx++) {
        final px = (gx * stepX) + (stepX ~/ 2);
        final idx = rowOffset + px;
        currGrid[gridRowOffset + gx] = idx < bytes.length ? bytes[idx] : 0;
      }
    }
  }

  /// Detects multiple vehicles by segmenting moving pixel clusters.
  List<YoloDetection> detectVehicles(
    Uint8List currGrid,
    Uint8List? prevGrid,
  ) {
    if (prevGrid == null) return const [];

    final colMotion = Int32List(gridW);
    final motionMask = Uint8List(gridW * gridH);

    // Focus on road region (rows 5 to 29, ignoring extreme sky & bottom margin)
    for (int gy = 5; gy < 30; gy++) {
      final rowOff = gy * gridW;
      for (int gx = 0; gx < gridW; gx++) {
        final idx = rowOff + gx;
        final diff = (currGrid[idx] - prevGrid[idx]).abs();
        if (diff > 18) {
          motionMask[idx] = 1;
          colMotion[gx]++;
        }
      }
    }

    // Cluster active columns into vehicle spans
    final clusters = <(int start, int end)>[];
    int? currentStart;
    int gap = 0;

    for (int gx = 1; gx < gridW - 1; gx++) {
      if (colMotion[gx] >= 2) {
        currentStart ??= gx;
        gap = 0;
      } else if (currentStart != null) {
        gap++;
        if (gap > 1 || gx == gridW - 2) {
          final end = gx - gap;
          if ((end - currentStart + 1) >= 2) {
            clusters.add((currentStart, end));
          }
          currentStart = null;
          gap = 0;
        }
      }
    }
    if (currentStart != null && (gridW - 2 - currentStart + 1) >= 2) {
      clusters.add((currentStart, gridW - 2));
    }

    final detections = <YoloDetection>[];

    for (final cluster in clusters) {
      final cStart = cluster.$1;
      final cEnd = cluster.$2;
      final wCols = cEnd - cStart + 1;

      // Filter out tiny noise (<3 columns = ~6% screen) or full-screen shifts (>25 columns)
      if (wCols < 3 || wCols > 25) continue;

      int minGy = gridH, maxGy = -1;
      int count = 0;

      for (int gy = 5; gy < 30; gy++) {
        final rowOff = gy * gridW;
        for (int gx = cStart; gx <= cEnd; gx++) {
          if (motionMask[rowOff + gx] == 1) {
            minGy = math.min(minGy, gy);
            maxGy = math.max(maxGy, gy);
            count++;
          }
        }
      }

      if (count < 8 || maxGy <= minGy) continue;
      final hRows = maxGy - minGy + 1;
      if (hRows < 3 || hRows > 24) continue;

      // Bounding box with 1-cell margin
      final left = (math.max(0, cStart - 1) / gridW).clamp(0.02, 0.95);
      final right = (math.min(gridW, cEnd + 2) / gridW).clamp(0.05, 0.98);
      final top = (math.max(0, minGy - 1) / gridH).clamp(0.05, 0.95);
      final bottom = (math.min(gridH, maxGy + 2) / gridH).clamp(0.10, 0.98);

      final boxW = right - left;
      final boxH = bottom - top;
      final ar = boxW / boxH;

      VehicleClass vClass = VehicleClass.car;
      if (ar < 0.65) {
        vClass = VehicleClass.motorcycle;
      } else if (boxW > 0.32 || boxH > 0.38) {
        vClass = VehicleClass.bus;
      } else if (ar >= 0.65 && ar < 1.15 && boxW < 0.22) {
        vClass = VehicleClass.cng;
      }

      final hist = _computeHistogram(currGrid, cStart, cEnd, minGy, maxGy);

      detections.add(
        YoloDetection(
          vehicleClass: vClass,
          confidence: 0.85,
          left: left,
          top: top,
          right: right,
          bottom: bottom,
          histogram: hist,
        ),
      );
    }

    return detections;
  }

  List<double> _computeHistogram(
    Uint8List grid,
    int x1,
    int x2,
    int y1,
    int y2,
  ) {
    final hist = List<double>.filled(24, 0.0);
    for (int gy = y1; gy <= y2; gy++) {
      final rowOff = gy * gridW;
      for (int gx = x1; gx <= x2; gx++) {
        final val = grid[rowOff + gx];
        final bin = (val * 24 ~/ 256).clamp(0, 23);
        hist[bin] += 1.0;
      }
    }

    double sumSq = 0.0;
    for (int i = 0; i < 24; i++) {
      sumSq += hist[i] * hist[i];
    }
    final norm = sumSq > 0 ? math.sqrt(sumSq) : 1.0;
    for (int i = 0; i < 24; i++) {
      hist[i] /= norm;
    }
    return hist;
  }
}

