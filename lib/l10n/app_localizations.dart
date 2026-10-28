import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In bn, this message translates to:
  /// **'সিএমপি স্পিড মনিটর'**
  String get appName;

  /// No description provided for @appSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'চট্টগ্রাম মহানগর পুলিশ'**
  String get appSubtitle;

  /// No description provided for @estimatedSpeed.
  ///
  /// In bn, this message translates to:
  /// **'আনুমানিক গতি'**
  String get estimatedSpeed;

  /// No description provided for @continueButton.
  ///
  /// In bn, this message translates to:
  /// **'পরবর্তী'**
  String get continueButton;

  /// No description provided for @backButton.
  ///
  /// In bn, this message translates to:
  /// **'পেছনে'**
  String get backButton;

  /// No description provided for @cancelButton.
  ///
  /// In bn, this message translates to:
  /// **'বাতিল'**
  String get cancelButton;

  /// No description provided for @saveButton.
  ///
  /// In bn, this message translates to:
  /// **'সংরক্ষণ'**
  String get saveButton;

  /// No description provided for @retryButton.
  ///
  /// In bn, this message translates to:
  /// **'পুনরায় চেষ্টা করুন'**
  String get retryButton;

  /// No description provided for @startNewSession.
  ///
  /// In bn, this message translates to:
  /// **'নতুন সেশন শুরু করুন'**
  String get startNewSession;

  /// No description provided for @verifiedToday.
  ///
  /// In bn, this message translates to:
  /// **'আজ যাচাইকৃত'**
  String get verifiedToday;

  /// No description provided for @lastSession.
  ///
  /// In bn, this message translates to:
  /// **'সর্বশেষ সেশন'**
  String get lastSession;

  /// No description provided for @recentVerified.
  ///
  /// In bn, this message translates to:
  /// **'সাম্প্রতিক যাচাইকৃত যানবাহন'**
  String get recentVerified;

  /// No description provided for @noRecordsYet.
  ///
  /// In bn, this message translates to:
  /// **'এখনও কোনো গতি রেকর্ড নেই'**
  String get noRecordsYet;

  /// No description provided for @recordsPendingSync.
  ///
  /// In bn, this message translates to:
  /// **'রেকর্ড সিঙ্ক বাকি'**
  String get recordsPendingSync;

  /// No description provided for @allRecordsSynced.
  ///
  /// In bn, this message translates to:
  /// **'সব রেকর্ড সার্ভারে সিঙ্ক হয়েছে'**
  String get allRecordsSynced;

  /// No description provided for @sessionSetupTitle.
  ///
  /// In bn, this message translates to:
  /// **'সেশন সেটআপ'**
  String get sessionSetupTitle;

  /// No description provided for @siteNameLabel.
  ///
  /// In bn, this message translates to:
  /// **'সাইটের নাম (বাধ্যতামূলক)'**
  String get siteNameLabel;

  /// No description provided for @siteNameHint.
  ///
  /// In bn, this message translates to:
  /// **'যেমন: জিইসি মোড়, লালখান বাজার'**
  String get siteNameHint;

  /// No description provided for @speedLimitLabel.
  ///
  /// In bn, this message translates to:
  /// **'গতির সীমা (কিমি/ঘণ্টা, ঐচ্ছিক)'**
  String get speedLimitLabel;

  /// No description provided for @speedLimitHint.
  ///
  /// In bn, this message translates to:
  /// **'যেমন: ৬০'**
  String get speedLimitHint;

  /// No description provided for @roadTypeLabel.
  ///
  /// In bn, this message translates to:
  /// **'রাস্তার ধরন'**
  String get roadTypeLabel;

  /// No description provided for @oneWayRoad.
  ///
  /// In bn, this message translates to:
  /// **'একমুখী রাস্তা'**
  String get oneWayRoad;

  /// No description provided for @twoWayRoad.
  ///
  /// In bn, this message translates to:
  /// **'দ্বিমুখী রাস্তা'**
  String get twoWayRoad;

  /// No description provided for @savedSitesTitle.
  ///
  /// In bn, this message translates to:
  /// **'সংরক্ষিত সাইটসমূহ'**
  String get savedSitesTitle;

  /// No description provided for @noSavedSites.
  ///
  /// In bn, this message translates to:
  /// **'কোনো সংরক্ষিত সাইট পাওয়া যায়নি'**
  String get noSavedSites;

  /// No description provided for @calibrateDistanceTitle.
  ///
  /// In bn, this message translates to:
  /// **'দূরত্ব পরিমাপ'**
  String get calibrateDistanceTitle;

  /// No description provided for @pinA.
  ///
  /// In bn, this message translates to:
  /// **'পিন এ'**
  String get pinA;

  /// No description provided for @pinB.
  ///
  /// In bn, this message translates to:
  /// **'পিন বি'**
  String get pinB;

  /// No description provided for @dropPin.
  ///
  /// In bn, this message translates to:
  /// **'পিন বসান'**
  String get dropPin;

  /// No description provided for @undoPin.
  ///
  /// In bn, this message translates to:
  /// **'মুছুন'**
  String get undoPin;

  /// No description provided for @distanceGood.
  ///
  /// In bn, this message translates to:
  /// **'সঠিক দূরত্ব'**
  String get distanceGood;

  /// No description provided for @distanceTooShort.
  ///
  /// In bn, this message translates to:
  /// **'দূরত্ব খুব কম (কমপক্ষে ১৫ মিটার)'**
  String get distanceTooShort;

  /// No description provided for @distanceLongSpan.
  ///
  /// In bn, this message translates to:
  /// **'দীর্ঘ ব্যবধান — উভয় চিহ্ন নিশ্চিত করুন'**
  String get distanceLongSpan;

  /// No description provided for @fallbackLink.
  ///
  /// In bn, this message translates to:
  /// **'চিহ্ন দেখতে পাচ্ছেন না? ক্যামেরা উচ্চতা পদ্ধতি ব্যবহার করুন'**
  String get fallbackLink;

  /// No description provided for @mapOfflineWarning.
  ///
  /// In bn, this message translates to:
  /// **'ম্যাপ লোড করা যায়নি — অফলাইন বিকল্প নির্বাচন করুন'**
  String get mapOfflineWarning;

  /// No description provided for @alignGatesTitle.
  ///
  /// In bn, this message translates to:
  /// **'গেট সারিবদ্ধকরণ'**
  String get alignGatesTitle;

  /// No description provided for @gateA.
  ///
  /// In bn, this message translates to:
  /// **'গেট এ'**
  String get gateA;

  /// No description provided for @gateB.
  ///
  /// In bn, this message translates to:
  /// **'গেট বি'**
  String get gateB;

  /// No description provided for @gateMAuto.
  ///
  /// In bn, this message translates to:
  /// **'গেট এম (স্বয়ংক্রিয় মধ্যবিন্দু)'**
  String get gateMAuto;

  /// No description provided for @alignHint.
  ///
  /// In bn, this message translates to:
  /// **'ম্যাপে চিহ্নিত দুটি ল্যান্ডমার্কের সাথে গেট এ এবং গেট বি মিলিয়ে নিন।'**
  String get alignHint;

  /// No description provided for @confirmGates.
  ///
  /// In bn, this message translates to:
  /// **'গেট নিশ্চিত করুন'**
  String get confirmGates;

  /// No description provided for @resetGates.
  ///
  /// In bn, this message translates to:
  /// **'পুনরায় সেট করুন'**
  String get resetGates;

  /// No description provided for @stopMonitoring.
  ///
  /// In bn, this message translates to:
  /// **'মনিটর সমাপ্ত করুন'**
  String get stopMonitoring;

  /// No description provided for @armed.
  ///
  /// In bn, this message translates to:
  /// **'সক্রিয়'**
  String get armed;

  /// No description provided for @paused.
  ///
  /// In bn, this message translates to:
  /// **'স্থগিত'**
  String get paused;

  /// No description provided for @resume.
  ///
  /// In bn, this message translates to:
  /// **'চালু করুন'**
  String get resume;

  /// No description provided for @steady.
  ///
  /// In bn, this message translates to:
  /// **'স্থির'**
  String get steady;

  /// No description provided for @moving.
  ///
  /// In bn, this message translates to:
  /// **'ক্যামেরা নড়ছে'**
  String get moving;

  /// No description provided for @cameraShakeWarning.
  ///
  /// In bn, this message translates to:
  /// **'ক্যামেরা নড়ে গেছে — ফোনটি স্থির রাখুন'**
  String get cameraShakeWarning;

  /// No description provided for @latestVerified.
  ///
  /// In bn, this message translates to:
  /// **'সর্বশেষ যাচাইকৃত'**
  String get latestVerified;

  /// No description provided for @diagnostics.
  ///
  /// In bn, this message translates to:
  /// **'ডায়াগনস্টিকস'**
  String get diagnostics;

  /// No description provided for @rejectedFaults.
  ///
  /// In bn, this message translates to:
  /// **'প্রত্যাখ্যাত ত্রুটি'**
  String get rejectedFaults;

  /// No description provided for @droppedFrames.
  ///
  /// In bn, this message translates to:
  /// **'ড্রপ ফ্রেম'**
  String get droppedFrames;

  /// No description provided for @activeTracksCount.
  ///
  /// In bn, this message translates to:
  /// **'সক্রিয় ট্র্যাকিং'**
  String get activeTracksCount;

  /// No description provided for @logsTitle.
  ///
  /// In bn, this message translates to:
  /// **'যাচাইকৃত লগ'**
  String get logsTitle;

  /// No description provided for @exportCsv.
  ///
  /// In bn, this message translates to:
  /// **'CSV রপ্তানি'**
  String get exportCsv;

  /// No description provided for @exportJson.
  ///
  /// In bn, this message translates to:
  /// **'JSON রপ্তানি'**
  String get exportJson;

  /// No description provided for @settingsTitle.
  ///
  /// In bn, this message translates to:
  /// **'সেটিংস'**
  String get settingsTitle;

  /// No description provided for @language.
  ///
  /// In bn, this message translates to:
  /// **'ভাষা'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In bn, this message translates to:
  /// **'থিম'**
  String get theme;

  /// No description provided for @themeDark.
  ///
  /// In bn, this message translates to:
  /// **'ডার্ক থিম'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In bn, this message translates to:
  /// **'লাইট থিম'**
  String get themeLight;

  /// No description provided for @banglaDigits.
  ///
  /// In bn, this message translates to:
  /// **'বাংলা সংখ্যা ব্যবহার করুন'**
  String get banglaDigits;

  /// No description provided for @diagnosticsMode.
  ///
  /// In bn, this message translates to:
  /// **'ডায়াগনস্টিক মোড'**
  String get diagnosticsMode;

  /// No description provided for @disclaimerTitle.
  ///
  /// In bn, this message translates to:
  /// **'আইনি অস্বীকৃতি ও শর্তাবলী'**
  String get disclaimerTitle;

  /// No description provided for @disclaimerBody.
  ///
  /// In bn, this message translates to:
  /// **'এই অ্যাপটি ফোনের ক্যামেরা ও কৃত্রিম বুদ্ধিমত্তা ব্যবহার করে যানবাহনের গতি অনুমান করে। উপযুক্ত আইনি কর্তৃপক্ষের অনুমোদন ও সঠিক ক্যালিব্রেশন ছাড়া এটি সরাসরি আদালতের প্রমাণ হিসেবে ব্যবহার করা যাবে না। অ্যাপটিতে কোনো মুখমণ্ডল বা লাইসেন্স প্লেট শনাক্ত করা হয় না।'**
  String get disclaimerBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
