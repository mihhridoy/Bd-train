// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'বিডি ট্রেন ৩ডি লাইভ ট্র্যাকিং';

  @override
  String get navMap => 'মানচিত্র';

  @override
  String get navRoutes => 'রুট';

  @override
  String get navTrains => 'ট্রেন';

  @override
  String get navSettings => 'সেটিংস';

  @override
  String get searchHint => 'স্টেশন বা স্থান খুঁজুন';

  @override
  String get searchPrompt => 'বাংলা বা ইংরেজিতে স্টেশন বা স্থানের নাম লিখুন';

  @override
  String noResults(String query) {
    return '“$query” এর জন্য কোনো ফলাফল নেই';
  }

  @override
  String get kindStation => 'স্টেশন';

  @override
  String get kindCity => 'শহর';

  @override
  String get kindTown => 'উপশহর';

  @override
  String get kindSuburb => 'এলাকা';

  @override
  String get kindVillage => 'গ্রাম';

  @override
  String get kindOther => 'স্থান';

  @override
  String get junction => 'জংশন';

  @override
  String get terminus => 'শেষ স্টেশন';

  @override
  String get connectedStations => 'সংযুক্ত স্টেশন';

  @override
  String get coordinates => 'স্থানাঙ্ক';

  @override
  String nearestStationTo(String name, String distance) {
    return 'নিকটতম স্টেশন: $name · $distance';
  }

  @override
  String get banglaNameUnavailable => 'এই ডেটাসেটে বাংলা নাম নেই';

  @override
  String get nameFromDataset => 'নাম OpenStreetMap স্থান-ডেটা থেকে মেলানো';

  @override
  String get nameCurated => 'নাম অ্যাপের নির্বাচিত তালিকা থেকে';

  @override
  String get nearbyBridges => 'কাছের সেতু';

  @override
  String get routeFromHere => 'এখান থেকে রুট';

  @override
  String get routeToHere => 'এখানে রুট';

  @override
  String get showOnMap => 'মানচিত্রে দেখুন';

  @override
  String get share => 'শেয়ার';

  @override
  String shareStationText(String name, String lat, String lng) {
    return '$name রেলস্টেশন — $lat, $lng';
  }

  @override
  String get routeFrom => 'শুরু';

  @override
  String get routeTo => 'গন্তব্য';

  @override
  String get selectStation => 'স্টেশন বাছুন';

  @override
  String get swap => 'অদলবদল';

  @override
  String get findRoute => 'রুট খুঁজুন';

  @override
  String get clearRoute => 'রুট মুছুন';

  @override
  String get routeDistance => 'রেলপথের দূরত্ব';

  @override
  String get routeStations => 'পথের স্টেশন';

  @override
  String get routeBridges => 'পথের সেতু';

  @override
  String get routeNoPath => 'কোনো সংযুক্ত রেলপথ পাওয়া যায়নি।';

  @override
  String get routeNote =>
      'বান্ডল করা রেললাইনের জ্যামিতি ধরে সবচেয়ে ছোট পথ। এটি সময়সূচি নয় এবং নির্দিষ্ট ট্রেনের পথ থেকে ভিন্ন হতে পারে।';

  @override
  String routeActive(String from, String to) {
    return 'রুট: $from → $to';
  }

  @override
  String stopsCount(String count) {
    return '$countটি স্টেশন';
  }

  @override
  String bridgeLength(String length) {
    return 'দৈর্ঘ্য $length';
  }

  @override
  String get unnamedBridge => 'নামহীন সেতু';

  @override
  String get layers => 'মানচিত্রের স্তর';

  @override
  String get layerRoads => 'সড়ক';

  @override
  String get layerPlaces => 'স্থান';

  @override
  String get layerBridges => 'সেতু';

  @override
  String get layerLabels => 'স্টেশনের নাম';

  @override
  String get layerTiles => 'অনলাইন বেস ম্যাপ';

  @override
  String get layerTilesOff =>
      'কনফিগার করা নেই। অফলাইন ভেক্টর ম্যাপ ব্যবহৃত হচ্ছে।';

  @override
  String get myLocation => 'আমার অবস্থান';

  @override
  String get locationWhyTitle => 'আপনার অবস্থান ব্যবহার করবেন?';

  @override
  String get locationWhyBody =>
      'আপনার অবস্থান একবার, এই ডিভাইসেই ব্যবহার হবে—মানচিত্র কেন্দ্রে আনতে ও নিকটতম রেলস্টেশন খুঁজতে। এটি সংরক্ষণ বা কোথাও পাঠানো হয় না।';

  @override
  String get allow => 'এগিয়ে যান';

  @override
  String get cancel => 'বাতিল';

  @override
  String get close => 'বন্ধ';

  @override
  String get locationDenied =>
      'অবস্থানের অনুমতি দেওয়া হয়নি। আপনি তবুও স্টেশন খুঁজতে পারবেন।';

  @override
  String get locationDeniedForever =>
      'অবস্থান বন্ধ করা আছে। এই সুবিধা ব্যবহারে সিস্টেম সেটিংসে চালু করুন।';

  @override
  String get locationServiceOff => 'ডিভাইসের লোকেশন সার্ভিস বন্ধ আছে।';

  @override
  String get locationFailed => 'আপনার অবস্থান পাওয়া যায়নি।';

  @override
  String get openSettings => 'সেটিংস খুলুন';

  @override
  String nearestToYou(String name, String distance) {
    return 'আপনার নিকটতম স্টেশন: $name ($distance)';
  }

  @override
  String get trainsTitle => 'ট্রেন';

  @override
  String get tabTracking => 'ট্র্যাকিং';

  @override
  String get tabTimetable => 'সময়সূচি';

  @override
  String get trackingNotConfiguredTitle => 'লাইভ ট্র্যাকিং সংযুক্ত নেই';

  @override
  String get trackingNotConfiguredBody =>
      'এই অ্যাপে এখনও কোনো লাইভ ট্রেন ডেটা উৎস নেই, তাই বাস্তব ট্রেনের অবস্থান দেখানো হচ্ছে না। বাস্তব ফিডের জন্য মালিকের দেওয়া ব্যাকএন্ড প্রয়োজন। আপনি স্পষ্টভাবে চিহ্নিত সিমুলেটেড ট্রেন দিয়ে ইন্টারফেস দেখে নিতে পারেন।';

  @override
  String get startDemo => 'ডেমো মোড চালু করুন';

  @override
  String get stopDemo => 'ডেমো মোড বন্ধ করুন';

  @override
  String get demoBadge => 'ডেমো';

  @override
  String get demoBanner =>
      'ডেমো মোড — সিমুলেটেড ট্রেন। এগুলো বাস্তব ট্রেনের অবস্থান নয়।';

  @override
  String demoSpeed(String scale) {
    return 'সিমুলেশন বাস্তব সময়ের চেয়ে $scale গুণ দ্রুত চলছে।';
  }

  @override
  String updatedAt(String time) {
    return 'হালনাগাদ $time';
  }

  @override
  String staleBanner(String seconds) {
    return '$seconds সেকেন্ড ধরে হালনাগাদ নেই — তথ্য পুরনো হতে পারে।';
  }

  @override
  String get pauseFeed => 'ফিড থামান (পুরনো-তথ্য অবস্থা পরীক্ষা)';

  @override
  String get resumeFeed => 'ফিড চালু করুন';

  @override
  String get trainsLoading => 'প্রথম হালনাগাদের অপেক্ষায়…';

  @override
  String get trainsEmpty => 'কোনো ট্রেনের তথ্য নেই।';

  @override
  String get trainsError => 'ট্রেনের তথ্য পড়া যায়নি।';

  @override
  String trainSpeed(String speed) {
    return '$speed কিমি/ঘণ্টা (সিমুলেটেড)';
  }

  @override
  String trainProgress(String percent) {
    return 'যাত্রার $percent%';
  }

  @override
  String get hornPlay => 'হর্ন বাজান';

  @override
  String get timetablePartialNotice =>
      'আংশিক সময়সূচির নমুনা (সময়সূচি নং ৫৪ সূত্র, কার্যকর ১০-০৩-২০২৫)। কেবল প্রান্তিক স্টেশন ও সময় লেখা হয়েছে; এটি সম্পূর্ণ বা যাচাইকৃত সূচি নয়। ভ্রমণের আগে বাংলাদেশ রেলওয়ের সঙ্গে নিশ্চিত হোন।';

  @override
  String offDay(String day) {
    return 'সাপ্তাহিক বন্ধ: $day';
  }

  @override
  String get noOffDay => 'সাপ্তাহিক বন্ধ নেই';

  @override
  String get nextDayArrival => 'পরের দিন';

  @override
  String get viewOnMap => 'মানচিত্রে রেলপথ দেখুন';

  @override
  String get notOnMap => 'একটি প্রান্তিক স্টেশন মানচিত্র-ডেটায় নেই';

  @override
  String get svcIntercity => 'আন্তঃনগর';

  @override
  String get svcMail => 'মেইল/এক্সপ্রেস';

  @override
  String get svcInternational => 'আন্তর্জাতিক';

  @override
  String get svcOther => 'অন্যান্য';

  @override
  String get verificationPartial => 'আংশিক অনুলিপি — যাচাইকৃত নয়';

  @override
  String get settingsTitle => 'সেটিংস';

  @override
  String get language => 'ভাষা';

  @override
  String get bangla => 'বাংলা';

  @override
  String get english => 'English';

  @override
  String get theme => 'থিম';

  @override
  String get themeSystem => 'সিস্টেম';

  @override
  String get themeLight => 'হালকা';

  @override
  String get themeDark => 'গাঢ়';

  @override
  String get soundEffects => 'শব্দ';

  @override
  String get soundEffectsDesc => 'ডেমো মোডে ট্রেনের হর্ন।';

  @override
  String get mapOverlays => 'মানচিত্রের ওভারলে';

  @override
  String get networkTitle => 'নেটওয়ার্ক';

  @override
  String get offlineNote =>
      'রেল মানচিত্র, স্টেশন, স্থান ও সড়ক অ্যাপেই আছে এবং অফলাইনে চলে। শুধু ঐচ্ছিক অনলাইন বেস ম্যাপ ও ভবিষ্যতের লাইভ ফিডের জন্য ইন্টারনেট লাগে।';

  @override
  String get openNetworkSettings => 'নেটওয়ার্ক সেটিংস খুলুন';

  @override
  String get networkSettingsFailed => 'নেটওয়ার্ক সেটিংস খোলা যায়নি।';

  @override
  String get about => 'পরিচিতি ও ডেটা';

  @override
  String get dataAttribution => 'মানচিত্রের ডেটা';

  @override
  String datasetSummary(
    String stations,
    String segments,
    String bridges,
    String places,
    String roads,
  ) {
    return '$stationsটি স্টেশন · $segmentsটি অংশ · $bridgesটি সেতু · $placesটি স্থান · $roadsটি সড়ক';
  }

  @override
  String datasetGenerated(String date) {
    return 'রেল ডেটাসেট তৈরি $date';
  }

  @override
  String banglaCoverage(String have, String total) {
    return '$totalটির মধ্যে $haveটি স্টেশনের বাংলা নাম আছে; বাকিগুলো ইংরেজিতে দেখানো হয়।';
  }

  @override
  String parseIssues(String count) {
    return '$countটি ডেটা রেকর্ড বাদ পড়েছে';
  }

  @override
  String get disclaimer =>
      'স্বতন্ত্র পুনর্নির্মাণ। বাংলাদেশ রেলওয়ের সঙ্গে সম্পর্কিত নয়। কোনো রিয়েল-টাইম ট্রেনের তথ্য নেই।';

  @override
  String get loading => 'রেল ডেটা লোড হচ্ছে…';

  @override
  String get loadError => 'রেল ডেটা লোড করা যায়নি।';

  @override
  String get retry => 'আবার চেষ্টা করুন';

  @override
  String get mapAttribution => '© OpenStreetMap অবদানকারীরা (ODbL)';

  @override
  String get vectorMapNote => 'অফলাইন ভেক্টর মানচিত্র';

  @override
  String get zoomIn => 'বড় করুন';

  @override
  String get zoomOut => 'ছোট করুন';

  @override
  String connectionsCount(String count) {
    return '$countটি সংযোগ';
  }

  @override
  String get routeStationsNote =>
      'যেসব স্টেশন রেলপথ থেকে ২৫০ মিটারের মধ্যে। জ্যামিতি থেকে নেওয়া, সময়সূচি থেকে নয়।';
}
