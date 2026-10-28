import 'dart:math' as math;
import 'dart:typed_data';

/// Extracts 8-bin normalized RGB color histograms from raw image buffers.
/// Reference: AGENT.md Section 4 & Section 5 Rule 4.
/// Zero Flutter imports for isolate safety and testability.
abstract final class RgbHistogramExtractor {
  static const int binsPerChannel = 8;
  static const int totalBins = binsPerChannel * 3; // 24 bins

  /// Extracts a 24-bin normalized histogram from the inner 50% core of a bounding box.
  /// Expects RGBA or RGB bytes with image dimensions.
  static List<double> extractCoreHistogram({
    required Uint8List rgbBytes,
    required int imageWidth,
    required int imageHeight,
    required double normLeft,
    required double normTop,
    required double normRight,
    required double normBottom,
    int bytesPerPixel = 4, // 4 for RGBA/BGRA, 3 for RGB
  }) {
    final hist = List<double>.filled(totalBins, 0.0);

    // Inner 50% core computation
    final width = normRight - normLeft;
    final height = normBottom - normTop;
    final coreLeft = (normLeft + width * 0.25).clamp(0.0, 1.0);
    final coreRight = (normRight - width * 0.25).clamp(0.0, 1.0);
    final coreTop = (normTop + height * 0.25).clamp(0.0, 1.0);
    final coreBottom = (normBottom - height * 0.25).clamp(0.0, 1.0);

    final startX = (coreLeft * imageWidth).floor().clamp(0, imageWidth - 1);
    final endX = (coreRight * imageWidth).ceil().clamp(0, imageWidth);
    final startY = (coreTop * imageHeight).floor().clamp(0, imageHeight - 1);
    final endY = (coreBottom * imageHeight).ceil().clamp(0, imageHeight);

    int sampleCount = 0;
    // Step by 2 for speed on mobile
    for (int y = startY; y < endY; y += 2) {
      final rowOffset = y * imageWidth * bytesPerPixel;
      for (int x = startX; x < endX; x += 2) {
        final pixelOffset = rowOffset + (x * bytesPerPixel);
        if (pixelOffset + 2 >= rgbBytes.length) break;

        final r = rgbBytes[pixelOffset];
        final g = rgbBytes[pixelOffset + 1];
        final b = rgbBytes[pixelOffset + 2];

        final rBin = (r * binsPerChannel ~/ 256).clamp(0, binsPerChannel - 1);
        final gBin = (g * binsPerChannel ~/ 256).clamp(0, binsPerChannel - 1);
        final bBin = (b * binsPerChannel ~/ 256).clamp(0, binsPerChannel - 1);

        hist[rBin] += 1.0;
        hist[binsPerChannel + gBin] += 1.0;
        hist[binsPerChannel * 2 + bBin] += 1.0;
        sampleCount++;
      }
    }

    if (sampleCount == 0) return hist;

    // Normalize to unit vector for cosine similarity
    double sumSquares = 0.0;
    for (int i = 0; i < totalBins; i++) {
      sumSquares += hist[i] * hist[i];
    }
    final norm = math.sqrt(sumSquares);
    if (norm > 1e-6) {
      for (int i = 0; i < totalBins; i++) {
        hist[i] /= norm;
      }
    }

    return hist;
  }

  /// Computes cosine similarity between two unit histograms (range 0.0 to 1.0).
  static double cosineSimilarity(List<double> histA, List<double> histB) {
    if (histA.length != totalBins || histB.length != totalBins) return 0.0;
    double dot = 0.0;
    for (int i = 0; i < totalBins; i++) {
      dot += histA[i] * histB[i];
    }
    return dot.clamp(0.0, 1.0);
  }
}
