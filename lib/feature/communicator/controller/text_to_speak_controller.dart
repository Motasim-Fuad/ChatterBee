import 'package:chatter_bee/config/translations/language_controller.dart';
import 'package:chatter_bee/services/tts_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TextToSpeakController extends GetxController {
  final TextEditingController textController = TextEditingController();
  var text = ''.obs;

  @override
  void onInit() {
    super.onInit();
    textController.addListener(() {
      text.value = textController.text;
    });
  }

  void updateText(String value) {
    text.value = value;
  }

  void speakText() {
    final spoken = text.value.trim();
    if (spoken.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'type_to_speak_hint'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }
    var lang = 'en';
    try {
      lang = LanguageController.to.currentLocale.value.languageCode;
    } catch (_) {}
    TtsService.to.speak(spoken, lang: lang);
  }

  void clearText() {
    textController.clear();
    text.value = '';
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}
