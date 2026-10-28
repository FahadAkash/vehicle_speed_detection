import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:vehicle_speed_estimator/core/constants/vehicle_classes.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/models/verified_speed_record.dart';

/// Pure SQLite persistence layer using official sqlite3 bindings.
/// Reference: AGENT.md Section 2 & Section 5 Rule 6.
class AppDatabase {
  AppDatabase([Database? db]) : _db = db {
    if (_db != null) _initTables(_db!);
  }

  Database? _db;
  final _changeStream = StreamController<void>.broadcast();

  Future<Database> _getDb() async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'cmp_speed_monitor.db');
    _db = sqlite3.open(dbPath);
    _initTables(_db!);
    return _db!;
  }

  void _initTables(Database db) {
    db.execute('''
      CREATE TABLE IF NOT EXISTS verified_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        track_id INTEGER NOT NULL,
        vehicle_class TEXT NOT NULL,
        speed_kmh REAL NOT NULL,
        speed_half1_kmh REAL NOT NULL,
        speed_half2_kmh REAL NOT NULL,
        direction TEXT NOT NULL,
        distance_m REAL NOT NULL,
        timestamp_utc_ms INTEGER NOT NULL,
        site_name TEXT NOT NULL,
        speed_limit_kmh REAL,
        is_synced INTEGER NOT NULL DEFAULT 0
      );
    ''');
    db.execute('''
      CREATE TABLE IF NOT EXISTS saved_sites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        distance_m REAL NOT NULL,
        pin_a_lat REAL,
        pin_a_lon REAL,
        pin_b_lat REAL,
        pin_b_lon REAL,
        speed_limit_kmh REAL,
        is_two_way INTEGER NOT NULL DEFAULT 0
      );
    ''');
  }

  Stream<List<VerifiedSpeedRecord>> watchRecentRecords({
    int limit = 10,
  }) async* {
    yield await getRecentRecords(limit);
    await for (final _ in _changeStream.stream) {
      yield await getRecentRecords(limit);
    }
  }

  Future<List<VerifiedSpeedRecord>> getRecentRecords(int limit) async {
    final db = await _getDb();
    final results = db.select(
      'SELECT * FROM verified_records ORDER BY timestamp_utc_ms DESC LIMIT ?',
      [limit],
    );
    return results.map(_rowToRecord).toList();
  }

  Future<List<VerifiedSpeedRecord>> getAllRecords() async {
    final db = await _getDb();
    final results = db.select(
      'SELECT * FROM verified_records ORDER BY timestamp_utc_ms DESC',
    );
    return results.map(_rowToRecord).toList();
  }

  Future<List<VerifiedSpeedRecord>> getPendingSyncRecords() async {
    final db = await _getDb();
    final results = db.select(
      'SELECT * FROM verified_records WHERE is_synced = 0',
    );
    return results.map(_rowToRecord).toList();
  }

  Future<int> insertRecord(VerifiedSpeedRecord record) async {
    final db = await _getDb();
    db.execute(
      '''
      INSERT INTO verified_records (
        track_id, vehicle_class, speed_kmh, speed_half1_kmh, speed_half2_kmh,
        direction, distance_m, timestamp_utc_ms, site_name, speed_limit_kmh, is_synced
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''',
      [
        record.trackId,
        record.vehicleClass.wireName,
        record.speedKmh,
        record.speedHalf1Kmh,
        record.speedHalf2Kmh,
        record.direction,
        record.distanceM,
        record.timestampUtcMs,
        record.siteName,
        record.speedLimitKmh,
        record.isSynced ? 1 : 0,
      ],
    );
    final id = db.lastInsertRowId;
    _changeStream.add(null);
    return id;
  }

  Future<void> markAsSynced(int trackId) async {
    final db = await _getDb();
    db.execute('UPDATE verified_records SET is_synced = 1 WHERE track_id = ?', [
      trackId,
    ]);
    _changeStream.add(null);
  }

  Stream<int> watchPendingSyncCount() async* {
    yield await _getPendingSyncCount();
    await for (final _ in _changeStream.stream) {
      yield await _getPendingSyncCount();
    }
  }

  Future<int> _getPendingSyncCount() async {
    final db = await _getDb();
    final rows = db.select(
      'SELECT COUNT(*) as count FROM verified_records WHERE is_synced = 0',
    );
    return rows.first['count'] as int;
  }

  Stream<int> watchTodayVerifiedCount() async* {
    yield await _getTodayVerifiedCount();
    await for (final _ in _changeStream.stream) {
      yield await _getTodayVerifiedCount();
    }
  }

  Future<int> _getTodayVerifiedCount() async {
    final db = await _getDb();
    final now = DateTime.now();
    final startOfDayMs = DateTime(
      now.year,
      now.month,
      now.day,
    ).millisecondsSinceEpoch;
    final rows = db.select(
      'SELECT COUNT(*) as count FROM verified_records WHERE timestamp_utc_ms >= ?',
      [startOfDayMs],
    );
    return rows.first['count'] as int;
  }

  VerifiedSpeedRecord _rowToRecord(Row row) {
    return VerifiedSpeedRecord(
      trackId: row['track_id'] as int,
      vehicleClass: VehicleClass.fromString(row['vehicle_class'] as String),
      speedKmh: (row['speed_kmh'] as num).toDouble(),
      speedHalf1Kmh: (row['speed_half1_kmh'] as num).toDouble(),
      speedHalf2Kmh: (row['speed_half2_kmh'] as num).toDouble(),
      direction: row['direction'] as String,
      distanceM: (row['distance_m'] as num).toDouble(),
      timestampUtcMs: row['timestamp_utc_ms'] as int,
      siteName: row['site_name'] as String,
      speedLimitKmh: row['speed_limit_kmh'] != null
          ? (row['speed_limit_kmh'] as num).toDouble()
          : null,
      isSynced: (row['is_synced'] as int) == 1,
    );
  }

  void close() {
    _changeStream.close();
    _db?.dispose();
  }
}
