import 'package:vehicle_speed_estimator/core/constants/vehicle_classes.dart';
import 'package:vehicle_speed_estimator/core/utils/geometry_utils.dart';

/// Single vehicle bounding box detection from YOLOv8n.
class YoloDetection {
  const YoloDetection({
    required this.vehicleClass,
    required this.confidence,
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
    this.histogram = const [],
  });

  final VehicleClass vehicleClass;
  final double confidence;
  final double left;
  final double top;
  final double right;
  final double bottom;
  final List<double> histogram;

  double get width => right - left;
  double get height => bottom - top;
  double get centerX => left + (width / 2.0);
  double get centerY => top + (height / 2.0);

  /// Ground contact point: center-x and bottom of bounding box.
  Vec2 get groundContactPoint => Vec2(centerX, bottom);

  /// Calculates Intersection-over-Union with another bounding box.
  double computeIoU(double oLeft, double oTop, double oRight, double oBottom) {
    final x1 = left > oLeft ? left : oLeft;
    final y1 = top > oTop ? top : oTop;
    final x2 = right < oRight ? right : oRight;
    final y2 = bottom < oBottom ? bottom : oBottom;

    final interWidth = (x2 - x1).clamp(0.0, 1.0);
    final interHeight = (y2 - y1).clamp(0.0, 1.0);
    final interArea = interWidth * interHeight;

    final areaA = width * height;
    final areaB = (oRight - oLeft) * (oBottom - oTop);
    final unionArea = areaA + areaB - interArea;

    if (unionArea <= 1e-9) return 0.0;
    return (interArea / unionArea).clamp(0.0, 1.0);
  }
}
