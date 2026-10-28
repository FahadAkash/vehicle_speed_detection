import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsState {
  const SettingsState({
    this.locale = const Locale('bn'),
    this.themeMode = ThemeMode.dark,
    this.useBanglaDigits = true,
    this.diagnosticsMode = false,
    this.syncEndpoint = 'https://api.cmp.police.gov.bd/speed-telemetry/v1',
  });

  final Locale locale;
  final ThemeMode themeMode;
  final bool useBanglaDigits;
  final bool diagnosticsMode;
  final String syncEndpoint;

  SettingsState copyWith({
    Locale? locale,
    ThemeMode? themeMode,
    bool? useBanglaDigits,
    bool? diagnosticsMode,
    String? syncEndpoint,
  }) {
    return SettingsState(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
      useBanglaDigits: useBanglaDigits ?? this.useBanglaDigits,
      diagnosticsMode: diagnosticsMode ?? this.diagnosticsMode,
      syncEndpoint: syncEndpoint ?? this.syncEndpoint,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() => const SettingsState();

  void setLocale(Locale locale) {
    state = state.copyWith(locale: locale);
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

  void toggleBanglaDigits(bool value) {
    state = state.copyWith(useBanglaDigits: value);
  }

  void toggleDiagnostics(bool value) {
    state = state.copyWith(diagnosticsMode: value);
  }

  void setSyncEndpoint(String endpoint) {
    state = state.copyWith(syncEndpoint: endpoint);
  }
}

final settingsNotifierProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);
