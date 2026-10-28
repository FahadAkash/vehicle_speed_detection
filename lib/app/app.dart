import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_speed_estimator/app/router.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_theme.dart';
import 'package:vehicle_speed_estimator/features/settings/domain/settings_notifier.dart';
import 'package:vehicle_speed_estimator/l10n/app_localizations.dart';

class CmpSpeedApp extends ConsumerWidget {
  const CmpSpeedApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(
      settingsNotifierProvider.select((s) => s.themeMode),
    );
    final locale = ref.watch(settingsNotifierProvider.select((s) => s.locale));

    return MaterialApp.router(
      title: 'CMP Speed Monitor',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      themeMode: themeMode,
      theme: CmpTheme.build(Brightness.light),
      darkTheme: CmpTheme.build(Brightness.dark),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        // Clamp text scale between 1.0 and 1.3 for HUD readability
        final clampedScale = mediaQuery.textScaler.clamp(
          minScaleFactor: 1.0,
          maxScaleFactor: 1.3,
        );
        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: clampedScale),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
