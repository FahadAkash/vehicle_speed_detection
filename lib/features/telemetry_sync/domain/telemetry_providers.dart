import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/models/verified_speed_record.dart';
import 'package:vehicle_speed_estimator/features/telemetry_sync/data/app_database.dart';
import 'package:vehicle_speed_estimator/features/telemetry_sync/data/export_service.dart';
import 'package:vehicle_speed_estimator/features/telemetry_sync/data/telemetry_sync_service.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final recentRecordsProvider = StreamProvider<List<VerifiedSpeedRecord>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchRecentRecords(limit: 5);
});

final pendingSyncCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchPendingSyncCount();
});

final todayVerifiedCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchTodayVerifiedCount();
});

final syncServiceProvider = Provider<TelemetrySyncService>((ref) {
  return TelemetrySyncService();
});

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService();
});
