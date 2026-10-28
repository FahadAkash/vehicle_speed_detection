import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_speed_estimator/core/constants/vehicle_classes.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_theme.dart';
import 'package:vehicle_speed_estimator/core/widgets/distance_badge.dart';
import 'package:vehicle_speed_estimator/core/widgets/speed_chip.dart';
import 'package:vehicle_speed_estimator/core/widgets/status_pill.dart';
import 'package:vehicle_speed_estimator/core/widgets/verified_feed_tile.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/models/verified_speed_record.dart';

Widget _wrap(Widget child, {Brightness brightness = Brightness.dark}) {
  return MaterialApp(
    theme: CmpTheme.build(brightness),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('Shared Widgets Catalog', () {
    testWidgets(
      'SpeedChip renders verified green within limit and red over limit',
      (tester) async {
        // Within limit
        await tester.pumpWidget(
          _wrap(const SpeedChip(speedKmh: 45.0, speedLimitKmh: 60.0)),
        );
        expect(find.text('45 km/h'), findsOneWidget);
        expect(find.byIcon(Icons.warning_rounded), findsNothing);

        // Over limit
        await tester.pumpWidget(
          _wrap(const SpeedChip(speedKmh: 75.0, speedLimitKmh: 60.0)),
        );
        expect(find.text('75 km/h'), findsOneWidget);
        expect(find.byIcon(Icons.warning_rounded), findsOneWidget);

        // No limit set
        await tester.pumpWidget(_wrap(const SpeedChip(speedKmh: 80.0)));
        expect(find.text('80 km/h'), findsOneWidget);
        expect(find.byIcon(Icons.warning_rounded), findsNothing);
      },
    );

    testWidgets('DistanceBadge renders correct status for <15m, >=15m, >50m', (
      tester,
    ) async {
      // Too short (<15m)
      await tester.pumpWidget(_wrap(const DistanceBadge(distanceM: 10.0)));
      expect(find.textContaining('10.0 m'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);

      // Recommended range (>=15m and <=50m)
      await tester.pumpWidget(_wrap(const DistanceBadge(distanceM: 30.4)));
      expect(find.textContaining('30.4 m'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);

      // Long span (>50m)
      await tester.pumpWidget(_wrap(const DistanceBadge(distanceM: 65.0)));
      expect(find.textContaining('65.0 m'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('StatusPill renders ARMED, PAUSED and SYNCING correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const StatusPill(status: MonitoringStatus.armed)),
      );
      expect(find.text('সক্রিয় / ARMED'), findsOneWidget);

      await tester.pumpWidget(
        _wrap(const StatusPill(status: MonitoringStatus.paused)),
      );
      expect(find.text('স্থগিত / PAUSED'), findsOneWidget);

      await tester.pumpWidget(
        _wrap(const StatusPill(status: MonitoringStatus.syncing)),
      );
      expect(find.text('সিঙ্ক হচ্ছে / SYNCING'), findsOneWidget);
    });

    testWidgets('VerifiedFeedTile renders class, speed, and time', (
      tester,
    ) async {
      const record = VerifiedSpeedRecord(
        trackId: 104,
        vehicleClass: VehicleClass.cng,
        speedKmh: 42.65,
        speedHalf1Kmh: 43.10,
        speedHalf2Kmh: 42.21,
        direction: 'A_TO_B',
        distanceM: 30.0,
        timestampUtcMs: 1700000000000,
        isSynced: true,
      );

      await tester.pumpWidget(_wrap(const VerifiedFeedTile(record: record)));
      expect(find.text('সিএনজি'), findsOneWidget);
      expect(find.textContaining('42.'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_done), findsOneWidget);
    });
  });
}
