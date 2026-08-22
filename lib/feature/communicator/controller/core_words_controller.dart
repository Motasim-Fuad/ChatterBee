import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CoreWordsController extends GetxController {
  var selectedWords = <String>[].obs;
  var coreWordsText = ''.obs;

  final List<CoreWordModel> coreWords = [
    CoreWordModel(
      imagePath: ImagesLink.yesImg,
      word: 'Yes',
    ),
    CoreWordModel(
      imagePath: ImagesLink.noImg,
      word: 'No',
    ),
    CoreWordModel(
      imagePath: ImagesLink.thisImg,
      word: 'This',
    ),
    CoreWordModel(
      imagePath: ImagesLink.mineImg,
      word: 'Mine',
    ),
    CoreWordModel(
      imagePath: ImagesLink.myImg,
      word: 'My',
    ),
    CoreWordModel(
      imagePath: ImagesLink.upImg,
      word: 'Up',
    ),
    CoreWordModel(
      imagePath: ImagesLink.downImg,
      word: 'Down',
    ),
    CoreWordModel(
      imagePath: ImagesLink.hereImg,
      word: 'here',
    ),
    CoreWordModel(
      imagePath: ImagesLink.ofImg,
      word: 'Of',
    ),
    CoreWordModel(
      imagePath: ImagesLink.itImg,
      word: 'It',
    ),
    CoreWordModel(
      imagePath: ImagesLink.someImg,
      word: 'Some',
    ),
  ];

  void selectWord(String word) {
    selectedWords.add(word);
    coreWordsText.value = selectedWords.join(' ');
  }

  void speakCoreWords() {
    if (coreWordsText.value.isNotEmpty) {
      Get.snackbar(
        'Speaking',
        coreWordsText.value,
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

  void clearCoreWords() {
    selectedWords.clear();
    coreWordsText.value = '';
  }
}

class CoreWordModel {
  final String imagePath;
  final String word;

  CoreWordModel({
    required this.imagePath,
    required this.word,
  });
}
