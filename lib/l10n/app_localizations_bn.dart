// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appName => 'সিএমপি স্পিড মনিটর';

  @override
  String get appSubtitle => 'চট্টগ্রাম মহানগর পুলিশ';

  @override
  String get estimatedSpeed => 'আনুমানিক গতি';

  @override
  String get continueButton => 'পরবর্তী';

  @override
  String get backButton => 'পেছনে';

  @override
  String get cancelButton => 'বাতিল';

  @override
  String get saveButton => 'সংরক্ষণ';

  @override
  String get retryButton => 'পুনরায় চেষ্টা করুন';

  @override
  String get startNewSession => 'নতুন সেশন শুরু করুন';

  @override
  String get verifiedToday => 'আজ যাচাইকৃত';

  @override
  String get lastSession => 'সর্বশেষ সেশন';

  @override
  String get recentVerified => 'সাম্প্রতিক যাচাইকৃত যানবাহন';

  @override
  String get noRecordsYet => 'এখনও কোনো গতি রেকর্ড নেই';

  @override
  String get recordsPendingSync => 'রেকর্ড সিঙ্ক বাকি';

  @override
  String get allRecordsSynced => 'সব রেকর্ড সার্ভারে সিঙ্ক হয়েছে';

  @override
  String get sessionSetupTitle => 'সেশন সেটআপ';

  @override
  String get siteNameLabel => 'সাইটের নাম (বাধ্যতামূলক)';

  @override
  String get siteNameHint => 'যেমন: জিইসি মোড়, লালখান বাজার';

  @override
  String get speedLimitLabel => 'গতির সীমা (কিমি/ঘণ্টা, ঐচ্ছিক)';

  @override
  String get speedLimitHint => 'যেমন: ৬০';

  @override
  String get roadTypeLabel => 'রাস্তার ধরন';

  @override
  String get oneWayRoad => 'একমুখী রাস্তা';

  @override
  String get twoWayRoad => 'দ্বিমুখী রাস্তা';

  @override
  String get savedSitesTitle => 'সংরক্ষিত সাইটসমূহ';

  @override
  String get noSavedSites => 'কোনো সংরক্ষিত সাইট পাওয়া যায়নি';

  @override
  String get calibrateDistanceTitle => 'দূরত্ব পরিমাপ';

  @override
  String get pinA => 'পিন এ';

  @override
  String get pinB => 'পিন বি';

  @override
  String get dropPin => 'পিন বসান';

  @override
  String get undoPin => 'মুছুন';

  @override
  String get distanceGood => 'সঠিক দূরত্ব';

  @override
  String get distanceTooShort => 'দূরত্ব খুব কম (কমপক্ষে ১৫ মিটার)';

  @override
  String get distanceLongSpan => 'দীর্ঘ ব্যবধান — উভয় চিহ্ন নিশ্চিত করুন';

  @override
  String get fallbackLink =>
      'চিহ্ন দেখতে পাচ্ছেন না? ক্যামেরা উচ্চতা পদ্ধতি ব্যবহার করুন';

  @override
  String get mapOfflineWarning =>
      'ম্যাপ লোড করা যায়নি — অফলাইন বিকল্প নির্বাচন করুন';

  @override
  String get alignGatesTitle => 'গেট সারিবদ্ধকরণ';

  @override
  String get gateA => 'গেট এ';

  @override
  String get gateB => 'গেট বি';

  @override
  String get gateMAuto => 'গেট এম (স্বয়ংক্রিয় মধ্যবিন্দু)';

  @override
  String get alignHint =>
      'ম্যাপে চিহ্নিত দুটি ল্যান্ডমার্কের সাথে গেট এ এবং গেট বি মিলিয়ে নিন।';

  @override
  String get confirmGates => 'গেট নিশ্চিত করুন';

  @override
  String get resetGates => 'পুনরায় সেট করুন';

  @override
  String get stopMonitoring => 'মনিটর সমাপ্ত করুন';

  @override
  String get armed => 'সক্রিয়';

  @override
  String get paused => 'স্থগিত';

  @override
  String get resume => 'চালু করুন';

  @override
  String get steady => 'স্থির';

  @override
  String get moving => 'ক্যামেরা নড়ছে';

  @override
  String get cameraShakeWarning => 'ক্যামেরা নড়ে গেছে — ফোনটি স্থির রাখুন';

  @override
  String get latestVerified => 'সর্বশেষ যাচাইকৃত';

  @override
  String get diagnostics => 'ডায়াগনস্টিকস';

  @override
  String get rejectedFaults => 'প্রত্যাখ্যাত ত্রুটি';

  @override
  String get droppedFrames => 'ড্রপ ফ্রেম';

  @override
  String get activeTracksCount => 'সক্রিয় ট্র্যাকিং';

  @override
  String get logsTitle => 'যাচাইকৃত লগ';

  @override
  String get exportCsv => 'CSV রপ্তানি';

  @override
  String get exportJson => 'JSON রপ্তানি';

  @override
  String get settingsTitle => 'সেটিংস';

  @override
  String get language => 'ভাষা';

  @override
  String get theme => 'থিম';

  @override
  String get themeDark => 'ডার্ক থিম';

  @override
  String get themeLight => 'লাইট থিম';

  @override
  String get banglaDigits => 'বাংলা সংখ্যা ব্যবহার করুন';

  @override
  String get diagnosticsMode => 'ডায়াগনস্টিক মোড';

  @override
  String get disclaimerTitle => 'আইনি অস্বীকৃতি ও শর্তাবলী';

  @override
  String get disclaimerBody =>
      'এই অ্যাপটি ফোনের ক্যামেরা ও কৃত্রিম বুদ্ধিমত্তা ব্যবহার করে যানবাহনের গতি অনুমান করে। উপযুক্ত আইনি কর্তৃপক্ষের অনুমোদন ও সঠিক ক্যালিব্রেশন ছাড়া এটি সরাসরি আদালতের প্রমাণ হিসেবে ব্যবহার করা যাবে না। অ্যাপটিতে কোনো মুখমণ্ডল বা লাইসেন্স প্লেট শনাক্ত করা হয় না।';
}
