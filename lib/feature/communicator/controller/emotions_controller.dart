import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmotionsController extends GetxController {
  var selectedEmotion = ''.obs;

  final List<EmotionModel> emotions = [
    EmotionModel(
      imagePath: ImagesLink.happyImg,
      label: 'Happy',
    ),
    EmotionModel(
      imagePath: ImagesLink.angryImg,
      label: 'Angry',
    ),
    EmotionModel(
      imagePath: ImagesLink.loveImg,
      label: 'Love',
    ),
    EmotionModel(
      imagePath: ImagesLink.confusedImg,
      label: 'Confused',
    ),
    EmotionModel(
      imagePath: ImagesLink.sadImg,
      label: 'Sad',
    ),
    EmotionModel(
      imagePath: ImagesLink.scaredImg,
      label: 'Scared',
    ),
    EmotionModel(
      imagePath: ImagesLink.dislikeImg,
      label: 'Dislike',
    ),
    EmotionModel(
      imagePath: ImagesLink.neutralImg,
      label: 'Neutral',
    ),
  ];

  void selectEmotion(String emotion) {
    selectedEmotion.value = emotion;
  }

  void speakEmotion() {
    if (selectedEmotion.value.isNotEmpty) {
      Get.snackbar(
        'Speaking',
        'I feel ${selectedEmotion.value.toLowerCase()}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        'Error',
        'Please select an emotion first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  void clearEmotion() {
    selectedEmotion.value = '';
  }
}

class EmotionModel {
  final String imagePath;
  final String label;

  EmotionModel({
    required this.imagePath,
    required this.label,
  });
}
