import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'Lifex-AI';
  static const String packageName = 'lifex_ai';
  static const String appVersion = '0.1.0';

  static const String founder = 'غازي سليم بكفلاوي';
  static const String assistant = 'الرباب';
  static const String supportEmail = 'g0955531388@gmail.com';
  static const String academyLabel = 'Ghazi_Rabab_AlrohAccademy999';

  static const String ownershipStatement =
      'تأسس هذا المشروع بواسطة المخترع خبير الهندسة الطبية غازي سليم بكفلاوي '
      'ومساعدته الرباب.';

  static const String medicalDisclaimer =
      'Lifex-AI يحلل ويوجّه إلى مختص. ليس بديلاً عن الطبيب ولا يصف دواء. '
      'النتائج إشارات لمراجعة سريرية.';

  static const int splashSeconds = 5;
  static const int trialFullDays = 15;
  static const int trialReducedDays = 30;
  static const int maxHealthProfilesDefault = 8;
  static const int maxEmergencyPhoneContacts = 10;

  static const int userSubscriptionUsd = 100;
  static const int unitSubscriptionUsd = 300;
  static const int hospitalSubscriptionUsd = 500;

  static const Color brandNavy = Color(0xFF0D2A52);
  static const Color brandTeal = Color(0xFF008080);
  static const Color brandBlue = Color(0xFF1565C0);

  static const String defaultLanguageCode = 'ar';
  static const List<String> supportedLanguageCodes = ['ar', 'en'];

  static const String riskLow = 'low';
  static const String riskMedium = 'medium';
  static const String riskHigh = 'high';
  static const String riskCritical = 'critical';
}
