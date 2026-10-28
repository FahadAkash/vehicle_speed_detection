import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehicle_speed_estimator/features/calibration/domain/calibration_notifier.dart';
import 'package:vehicle_speed_estimator/features/calibration/presentation/gate_alignment_screen.dart';
import 'package:vehicle_speed_estimator/features/calibration/presentation/satellite_pin_screen.dart';
import 'package:vehicle_speed_estimator/features/home/presentation/home_screen.dart';
import 'package:vehicle_speed_estimator/features/session_setup/presentation/session_setup_screen.dart';
import 'package:vehicle_speed_estimator/features/settings/presentation/settings_screen.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/presentation/live_monitor_screen.dart';
import 'package:vehicle_speed_estimator/features/telemetry_sync/presentation/verified_logs_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/session/setup',
        builder: (context, state) => const SessionSetupScreen(),
      ),
      GoRoute(
        path: '/calibration/map',
        builder: (context, state) => const SatellitePinScreen(),
      ),
      GoRoute(
        path: '/calibration/gates',
        redirect: (context, state) {
          final calState = ref.read(calibrationNotifierProvider);
          if (!calState.isCalibrationValid) {
            return '/calibration/map';
          }
          return null;
        },
        builder: (context, state) => const GateAlignmentScreen(),
      ),
      GoRoute(
        path: '/monitor',
        redirect: (context, state) {
          final calState = ref.read(calibrationNotifierProvider);
          if (!calState.isCalibrationValid) {
            return '/calibration/map';
          }
          if (!calState.areGatesConfirmed) {
            return '/calibration/gates';
          }
          return null;
        },
        builder: (context, state) => const LiveMonitorScreen(),
      ),
      GoRoute(
        path: '/logs',
        builder: (context, state) => const VerifiedLogsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
