import 'package:chatter_bee/feature/Profile/controller/pro_status_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class LanguageController extends GetxController {
  static LanguageController get to => Get.find();

  final proController = ProStatusController.to;

  final List<Map<String, String>> supportedLanguages = [
    {'name': 'English',  'code': 'en', 'country': 'US', 'flag': '🇺🇸'},
    {'name': 'Español',  'code': 'es', 'country': 'ES', 'flag': '🇪🇸'},
  ];
  bool isRTL() {
    const rtlLanguages = ['ar', 'he', 'fa', 'ur'];
    return rtlLanguages.contains(currentLocale.value.languageCode);
  }
  var currentLocale = const Locale('en', 'US').obs;

  bool get isPro => proController.isProUser.value;

  @override
  void onInit() {
    super.onInit();

    // React when Pro status changes
    ever(proController.isProUser, (_) {
      _handleProChange();
    });

    _loadDefaultLanguage();
  }

  void _loadDefaultLanguage() {
    currentLocale.value = const Locale('en', 'US');
    Get.updateLocale(currentLocale.value);
  }

  void _handleProChange() {
    if (!isPro) {
      // Force English if Pro expires
      currentLocale.value = const Locale('en', 'US');
      Get.updateLocale(currentLocale.value);
    }
  }

  Future<void> changeLanguage(String langCode) async {
    // ❗ Free user restriction
    if (!isPro && langCode != 'en') {
      Get.snackbar(
        "Premium Feature",
        "Upgrade to unlock all languages",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final match = supportedLanguages.firstWhere(
          (l) => l['code'] == langCode,
      orElse: () => supportedLanguages[0],
    );

    currentLocale.value = Locale(match['code']!, match['country']!);
    Get.updateLocale(currentLocale.value);
  }

  String get currentFlag {
    final match = supportedLanguages.firstWhere(
          (l) => l['code'] == currentLocale.value.languageCode,
      orElse: () => supportedLanguages[0],
    );
    return '${match['flag']} ${match['name']}';
  }
}