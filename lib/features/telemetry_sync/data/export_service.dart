import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/models/verified_speed_record.dart';

/// CSV & JSON telemetry export service.
/// Reference: AGENT.md Section 9.6.
class ExportService {
  /// Generates CSV string and triggers system share sheet.
  Future<void> exportCsv({
    required List<VerifiedSpeedRecord> records,
    required String siteName,
  }) async {
    final rows = <List<dynamic>>[];
    final sessionDate = DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now());

    rows.add(['# CMP Speed Monitor Verified Records']);
    rows.add(['# Site Name: $siteName', 'Session Date: $sessionDate']);
    rows.add([
      'Track ID',
      'Vehicle Class',
      'Speed (km/h)',
      'Half-1 Speed (km/h)',
      'Half-2 Speed (km/h)',
      'Direction',
      'Distance (m)',
      'UTC Timestamp (ms)',
      'Local Time',
    ]);

    for (final r in records) {
      final localTime = DateFormat(
        'yyyy-MM-dd HH:mm:ss',
      ).format(DateTime.fromMillisecondsSinceEpoch(r.timestampUtcMs).toLocal());
      rows.add([
        r.trackId,
        r.vehicleClass.wireName,
        r.speedKmh.toStringAsFixed(2),
        r.speedHalf1Kmh.toStringAsFixed(2),
        r.speedHalf2Kmh.toStringAsFixed(2),
        r.direction,
        r.distanceM.toStringAsFixed(2),
        r.timestampUtcMs,
        localTime,
      ]);
    }

    final csvString = const ListToCsvConverter().convert(rows);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/cmp_speed_$sessionDate.csv');
    await file.writeAsString(csvString);

    await Share.shareXFiles([
      XFile(file.path),
    ], subject: 'CMP Speed Records ($siteName)');
  }

  /// Generates formatted JSON file and triggers system share sheet.
  Future<void> exportJson({
    required List<VerifiedSpeedRecord> records,
    required String siteName,
  }) async {
    final sessionDate = DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now());
    final exportData = {
      'site_name': siteName,
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'total_records': records.length,
      'records': records.map((r) => r.toTelemetryJson()).toList(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/cmp_speed_$sessionDate.json');
    await file.writeAsString(jsonString);

    await Share.shareXFiles([
      XFile(file.path),
    ], subject: 'CMP Speed Records JSON ($siteName)');
  }
}
