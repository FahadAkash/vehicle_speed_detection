// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'CMP Speed Monitor';

  @override
  String get appSubtitle => 'Chattogram Metropolitan Police';

  @override
  String get estimatedSpeed => 'Estimated speed';

  @override
  String get continueButton => 'Continue';

  @override
  String get backButton => 'Back';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get saveButton => 'Save';

  @override
  String get retryButton => 'Retry';

  @override
  String get startNewSession => 'Start New Session';

  @override
  String get verifiedToday => 'Verified today';

  @override
  String get lastSession => 'Last session';

  @override
  String get recentVerified => 'Recent verified vehicles';

  @override
  String get noRecordsYet => 'No verified records yet';

  @override
  String get recordsPendingSync => 'records pending sync';

  @override
  String get allRecordsSynced => 'All records synced to server';

  @override
  String get sessionSetupTitle => 'Session Setup';

  @override
  String get siteNameLabel => 'Site name (Required)';

  @override
  String get siteNameHint => 'e.g., GEC Circle, Lalkhan Bazar';

  @override
  String get speedLimitLabel => 'Speed limit (km/h, Optional)';

  @override
  String get speedLimitHint => 'e.g., 60';

  @override
  String get roadTypeLabel => 'Road type';

  @override
  String get oneWayRoad => 'One-way road';

  @override
  String get twoWayRoad => 'Two-way road';

  @override
  String get savedSitesTitle => 'Saved sites';

  @override
  String get noSavedSites => 'No saved sites found';

  @override
  String get calibrateDistanceTitle => 'Calibrate distance';

  @override
  String get pinA => 'Pin A';

  @override
  String get pinB => 'Pin B';

  @override
  String get dropPin => 'Drop Pin';

  @override
  String get undoPin => 'Undo';

  @override
  String get distanceGood => 'Good distance';

  @override
  String get distanceTooShort => 'Distance too short (min 15 m)';

  @override
  String get distanceLongSpan =>
      'Long span — ensure both landmarks are visible';

  @override
  String get fallbackLink => 'Can\'t see landmarks? Use camera height method';

  @override
  String get mapOfflineWarning => 'Map unavailable — use offline fallback';

  @override
  String get alignGatesTitle => 'Align Gates';

  @override
  String get gateA => 'Gate A';

  @override
  String get gateB => 'Gate B';

  @override
  String get gateMAuto => 'Gate M (Auto midpoint)';

  @override
  String get alignHint =>
      'Align Gate A and Gate B with the same landmarks marked on the map.';

  @override
  String get confirmGates => 'Confirm gates';

  @override
  String get resetGates => 'Reset gates';

  @override
  String get stopMonitoring => 'Stop';

  @override
  String get armed => 'ARMED';

  @override
  String get paused => 'PAUSED';

  @override
  String get resume => 'Resume';

  @override
  String get steady => 'Steady';

  @override
  String get moving => 'Moving';

  @override
  String get cameraShakeWarning => 'Camera moved — hold steady';

  @override
  String get latestVerified => 'Latest verified';

  @override
  String get diagnostics => 'Diagnostics';

  @override
  String get rejectedFaults => 'Rejected faults';

  @override
  String get droppedFrames => 'Dropped frames';

  @override
  String get activeTracksCount => 'Active tracks';

  @override
  String get logsTitle => 'Verified Logs';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get exportJson => 'Export JSON';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get themeDark => 'Dark Theme';

  @override
  String get themeLight => 'Light Theme';

  @override
  String get banglaDigits => 'Use Bangla digits';

  @override
  String get diagnosticsMode => 'Diagnostics mode';

  @override
  String get disclaimerTitle => 'Legal Disclaimer';

  @override
  String get disclaimerBody =>
      'This app estimates vehicle speed using phone camera optics and AI. Unless validated by competent legal authorities and properly calibrated, results are estimates only and must not be used as certified legal evidence. The app does not record raw video or perform facial/license-plate recognition.';
}
