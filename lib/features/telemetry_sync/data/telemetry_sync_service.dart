import 'package:dio/dio.dart';
import 'package:vehicle_speed_estimator/core/errors/failures.dart';
import 'package:vehicle_speed_estimator/core/errors/result.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/models/verified_speed_record.dart';

/// Lightweight HTTP telemetry sync service.
/// Reference: AGENT.md Section 5 Rule 6.
class TelemetrySyncService {
  TelemetrySyncService({Dio? dio, String? endpoint})
    : _dio = dio ?? Dio(),
      endpoint = endpoint ?? 'https://api.cmp.police.gov.bd/speed-telemetry/v1';

  final Dio _dio;
  final String endpoint;

  /// Syncs a batch of verified metadata payloads.
  Future<Result<int, SyncFailure>> syncRecords(
    List<VerifiedSpeedRecord> records,
  ) async {
    if (records.isEmpty) return Result.ok(0);

    try {
      final payloads = records.map((r) => r.toTelemetryJson()).toList();
      final response = await _dio.post<dynamic>(
        endpoint,
        data: {'records': payloads},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return Result.ok(records.length);
      } else {
        return Result.err(
          SyncFailure('Server returned ${response.statusCode}'),
        );
      }
    } catch (e) {
      return Result.err(SyncFailure('Failed to sync telemetry payload', e));
    }
  }
}
