import 'package:chatter_bee/Repository/communicator_repository/communicator_repository.dart';
import 'package:chatter_bee/config/translations/language_controller.dart';
import 'package:chatter_bee/services/tts_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chatter_bee/utils/app_toast.dart';

class TextToSpeakController extends GetxController {
  final CommunicatorRepository _repo = CommunicatorRepository();
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
      AppToast.error('type_to_speak_hint'.tr);
      return;
    }
    var lang = 'en';
    try {
      lang = LanguageController.to.currentLocale.value.languageCode;
    } catch (_) {}
    TtsService.to.speak(spoken, lang: lang);
    _repo.pressSentence(spoken);
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
