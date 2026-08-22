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
    if (text.value.isNotEmpty) {
      Get.snackbar(
        'Speaking',
        text.value,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        'Error',
        'Please type something to speak',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
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
