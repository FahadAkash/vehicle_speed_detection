import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:vehicle_speed_estimator/app/router.dart';

void main() {
  group('Router Redirect Guards', () {
    testWidgets(
      '/calibration/gates redirects to /calibration/map if distance < 15m',
      (tester) async {
        late GoRouter router;

        await tester.pumpWidget(
          ProviderScope(
            child: Consumer(
              builder: (context, ref, child) {
                router = ref.watch(routerProvider);
                return MaterialApp.router(routerConfig: router);
              },
            ),
          ),
        );

        // Attempt navigation to /calibration/gates while distance is 0.0m
        router.go('/calibration/gates');
        await tester.pumpAndSettle();

        // Guard redirects back to /calibration/map
        expect(router.state.uri.path, equals('/calibration/map'));
      },
    );

    testWidgets(
      '/monitor redirects to /calibration/map if calibration is unconfigured',
      (tester) async {
        late GoRouter router;

        await tester.pumpWidget(
          ProviderScope(
            child: Consumer(
              builder: (context, ref, child) {
                router = ref.watch(routerProvider);
                return MaterialApp.router(routerConfig: router);
              },
            ),
          ),
        );

        router.go('/monitor');
        await tester.pumpAndSettle();

        // Guard redirects to /calibration/map
        expect(router.state.uri.path, equals('/calibration/map'));
      },
    );
  });
}
