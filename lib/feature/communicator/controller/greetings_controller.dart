import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GreetingsController extends GetxController {
  var selectedWords = <String>[].obs;
  var greetingText = ''.obs;

  final List<GreetingWordModel> greetingWords = [
    GreetingWordModel(emoji: '👋', word: 'I'),
    GreetingWordModel(emoji: '🤝', word: 'Want'),
    GreetingWordModel(emoji: '👉', word: 'That'),
    GreetingWordModel(emoji: '🙋‍♀️', word: 'My'),
    GreetingWordModel(emoji: '🙏', word: 'Be'),
    GreetingWordModel(emoji: '🤝', word: 'Want'),
    GreetingWordModel(emoji: '💛', word: 'Like'),
    GreetingWordModel(emoji: '👇', word: 'This'),
    GreetingWordModel(emoji: '✋', word: 'Stop'),
    GreetingWordModel(emoji: '👊', word: 'Me'),
    GreetingWordModel(emoji: '🤟', word: 'Can'),
    GreetingWordModel(emoji: '✊', word: 'Get'),
    GreetingWordModel(emoji: '✍️', word: 'Good'),
    GreetingWordModel(emoji: '☝️', word: 'This'),
    GreetingWordModel(emoji: '🤳', word: 'Have'),
  ];

  void selectWord(String word) {
    selectedWords.add(word);
    greetingText.value = selectedWords.join(' ');
  }

  void speakGreeting() {
    if (greetingText.value.isNotEmpty) {
      Get.snackbar(
        'Speaking',
        greetingText.value,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        'Error',
        'Please select words first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  void clearGreeting() {
    selectedWords.clear();
    greetingText.value = '';
  }
}

class GreetingWordModel {
  final String emoji;
  final String word;

  GreetingWordModel({
    required this.emoji,
    required this.word,
  });
}
