import 'package:vehicle_speed_estimator/core/constants/app_constants.dart';
import 'package:vehicle_speed_estimator/core/utils/rgb_histogram_extractor.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/logic/speed_math_engine.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/models/tracked_vehicle_state.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/models/verified_speed_record.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/models/virtual_gate.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/models/yolo_detection.dart';

/// Pure-Dart Multi-Object Tracker with 4-Layer Zero-Mismatch Defense.
/// Reference: AGENT.md Section 5 Rule 4.
class RobustVehicleTracker {
  int _nextTrackId = 1;
  final List<TrackedVehicleState> _tracks = [];

  List<TrackedVehicleState> get activeTracks => List.unmodifiable(_tracks);

  /// Main per-frame tracking step executed in background Isolate.
  List<VerifiedSpeedRecord> processFrame({
    required List<YoloDetection> detections,
    required int frameTimeUs,
    required List<VirtualGate> gates,
    required SpeedMathEngine mathEngine,
    required double distanceM,
    required double currentGyro,
    required int currentUtcMs,
    String siteName = '',
    double? speedLimitKmh,
  }) {
    final highConf = <YoloDetection>[];
    final lowConf = <YoloDetection>[];

    for (final det in detections) {
      if (det.confidence >= AppConstants.highConfThreshold) {
        highConf.add(det);
      } else if (det.confidence >= AppConstants.lowConfThreshold) {
        lowConf.add(det);
      }
    }

    final matchedTrackIndices = <int>{};
    final matchedDetIndices = <int>{};
    final verifiedList = <VerifiedSpeedRecord>[];

    // Stage 1: High-confidence matching with class lock and color similarity lock
    for (int tIdx = 0; tIdx < _tracks.length; tIdx++) {
      final track = _tracks[tIdx];
      final (pLeft, pTop, pRight, pBottom) = track.predictBoxAt(frameTimeUs);

      int bestDetIdx = -1;
      double bestIoU = 0.20; // Minimum IoU threshold

      for (int dIdx = 0; dIdx < highConf.length; dIdx++) {
        if (matchedDetIndices.contains(dIdx)) continue;
        final det = highConf[dIdx];

        // Defense 1: Strict class lock
        if (det.vehicleClass != track.vehicleClass) continue;

        // Defense 3: 8-bin RGB histogram lock (cosine similarity >= 0.65)
        if (track.colorHistogram.isNotEmpty && det.histogram.isNotEmpty) {
          final sim = RgbHistogramExtractor.cosineSimilarity(
            track.colorHistogram,
            det.histogram,
          );
          if (sim < AppConstants.colorSimilarityMin) continue;
        }

        // Defense 2: Constant-velocity predicted IoU
        final iou = det.computeIoU(pLeft, pTop, pRight, pBottom);
        if (iou > bestIoU) {
          bestIoU = iou;
          bestDetIdx = dIdx;
        }
      }

      if (bestDetIdx != -1) {
        matchedTrackIndices.add(tIdx);
        matchedDetIndices.add(bestDetIdx);
        _updateTrackWithDetection(
          tIdx,
          highConf[bestDetIdx],
          frameTimeUs,
          gates,
          mathEngine,
          distanceM,
          currentGyro,
          currentUtcMs,
          siteName,
          speedLimitKmh,
          verifiedList,
        );
      }
    }

    // Stage 2: ByteTrack low-confidence recovery for unmatched tracks
    for (int tIdx = 0; tIdx < _tracks.length; tIdx++) {
      if (matchedTrackIndices.contains(tIdx)) continue;
      final track = _tracks[tIdx];
      final (pLeft, pTop, pRight, pBottom) = track.predictBoxAt(frameTimeUs);

      int bestLowIdx = -1;
      double bestIoU = 0.20;

      for (int lIdx = 0; lIdx < lowConf.length; lIdx++) {
        final det = lowConf[lIdx];
        if (det.vehicleClass != track.vehicleClass) continue;

        final iou = det.computeIoU(pLeft, pTop, pRight, pBottom);
        if (iou > bestIoU) {
          bestIoU = iou;
          bestLowIdx = lIdx;
        }
      }

      if (bestLowIdx != -1) {
        matchedTrackIndices.add(tIdx);
        _updateTrackWithDetection(
          tIdx,
          lowConf[bestLowIdx],
          frameTimeUs,
          gates,
          mathEngine,
          distanceM,
          currentGyro,
          currentUtcMs,
          siteName,
          speedLimitKmh,
          verifiedList,
        );
      }
    }

    // Handle coasting for unmatched tracks
    for (int tIdx = _tracks.length - 1; tIdx >= 0; tIdx--) {
      if (!matchedTrackIndices.contains(tIdx)) {
        final track = _tracks[tIdx];
        final nextCoast = track.coastFrames + 1;
        if (nextCoast > AppConstants.maxCoastFrames) {
          _tracks.removeAt(tIdx);
        } else {
          final (pLeft, pTop, pRight, pBottom) = track.predictBoxAt(
            frameTimeUs,
          );
          _tracks[tIdx] = track.copyWith(
            left: pLeft,
            top: pTop,
            right: pRight,
            bottom: pBottom,
            coastFrames: nextCoast,
          );
        }
      }
    }

    // Spawn new tracks for unmatched high-confidence detections
    for (int dIdx = 0; dIdx < highConf.length; dIdx++) {
      if (!matchedDetIndices.contains(dIdx)) {
        final det = highConf[dIdx];
        _tracks.add(
          TrackedVehicleState(
            trackId: _nextTrackId++,
            vehicleClass: det.vehicleClass,
            left: det.left,
            top: det.top,
            right: det.right,
            bottom: det.bottom,
            vx: 0.0,
            vy: 0.0,
            colorHistogram: det.histogram,
            firstSeenTimeUs: frameTimeUs,
            lastSeenTimeUs: frameTimeUs,
            prevGroundContact: det.groundContactPoint,
          ),
        );
      }
    }

    return verifiedList;
  }

  void _updateTrackWithDetection(
    int tIdx,
    YoloDetection det,
    int frameTimeUs,
    List<VirtualGate> gates,
    SpeedMathEngine mathEngine,
    double distanceM,
    double currentGyro,
    int currentUtcMs,
    String siteName,
    double? speedLimitKmh,
    List<VerifiedSpeedRecord> verifiedList,
  ) {
    final track = _tracks[tIdx];
    final dtSec = (frameTimeUs - track.lastSeenTimeUs) / 1000000.0;
    final currCenter = det.centerX;
    final prevCenter = track.centerX;

    final rawVx = dtSec > 0 ? (currCenter - prevCenter) / dtSec : track.vx;
    final rawVy = dtSec > 0 ? (det.centerY - track.centerY) / dtSec : track.vy;
    final smoothedVx = (0.7 * track.vx) + (0.3 * rawVx);
    final smoothedVy = (0.7 * track.vy) + (0.3 * rawVy);

    int? nextGateA = track.gateATimeUs;
    int? nextGateM = track.gateMTimeUs;
    int? nextGateB = track.gateBTimeUs;

    final pPrev = track.groundContactPoint;
    final pCurr = det.groundContactPoint;

    for (final gate in gates) {
      final crossUs = mathEngine.checkGateCrossing(
        prevPoint: pPrev,
        currPoint: pCurr,
        prevTimeUs: track.lastSeenTimeUs,
        currTimeUs: frameTimeUs,
        gate: gate,
      );

      if (crossUs != null) {
        final gName = gate.name.toLowerCase();
        if (gName.contains('a') && nextGateA == null) nextGateA = crossUs;
        if (gName.contains('m') && nextGateM == null) nextGateM = crossUs;
        if (gName.contains('b') && nextGateB == null) nextGateB = crossUs;
      }
    }

    var updatedTrack = track.copyWith(
      left: det.left,
      top: det.top,
      right: det.right,
      bottom: det.bottom,
      vx: smoothedVx,
      vy: smoothedVy,
      colorHistogram: det.histogram.isNotEmpty
          ? det.histogram
          : track.colorHistogram,
      lastSeenTimeUs: frameTimeUs,
      gateATimeUs: nextGateA,
      gateMTimeUs: nextGateM,
      gateBTimeUs: nextGateB,
      coastFrames: 0,
      prevGroundContact: pCurr,
    );

    if (!updatedTrack.isVerified &&
        nextGateA != null &&
        nextGateM != null &&
        nextGateB != null) {
      final record = mathEngine.evaluateSpeedRecord(
        track: updatedTrack,
        distanceM: distanceM,
        maxGyroObserved: currentGyro,
        timestampUtcMs: currentUtcMs,
        siteName: siteName,
        speedLimitKmh: speedLimitKmh,
      );

      if (record != null) {
        updatedTrack = updatedTrack.copyWith(
          isVerified: true,
          verifiedSpeedKmh: record.speedKmh,
          verifiedDirection: record.direction,
        );
        verifiedList.add(record);
      }
    }

    _tracks[tIdx] = updatedTrack;
  }
}
