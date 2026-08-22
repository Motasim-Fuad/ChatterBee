import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThingsController extends GetxController {
  var selectedThing = ''.obs;

  final List<ThingModel> things = [
    ThingModel(
      imagePath: ImagesLink.goodMorningImg,
      label: 'Good morning',
    ),
    ThingModel(
      imagePath: ImagesLink.hiImg,
      label: 'Hi',
    ),
    ThingModel(
      imagePath: ImagesLink.byeImg,
      label: 'Bye',
    ),
    ThingModel(
      imagePath: ImagesLink.myTurnImg,
      label: 'My turn',
    ),
    ThingModel(
      imagePath: ImagesLink.yourTurnImg,
      label: 'Your turn',
    ),
    ThingModel(
      imagePath: ImagesLink.thankYouImg,
      label: 'Thank you',
    ),
    ThingModel(
      imagePath: ImagesLink.iDontKnowImg,
      label: "I don't know",
    ),
    ThingModel(
      imagePath: ImagesLink.iDontImg,
      label: "I don't",
    ),
    ThingModel(
      imagePath: ImagesLink.understandImg,
      label: 'Understand',
    ),
    ThingModel(
      imagePath: ImagesLink.wowImg,
      label: 'wow!',
    ),
    ThingModel(
      imagePath: ImagesLink.goodJobImg,
      label: 'Good job!',
    ),
  ];

  void selectThing(String thing) {
    selectedThing.value = thing;
  }

  void speakThing() {
    if (selectedThing.value.isNotEmpty) {
      Get.snackbar(
        'Speaking',
        selectedThing.value,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        'Error',
        'Please select an option first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  void clearThing() {
    selectedThing.value = '';
  }
}

class ThingModel {
  final String imagePath;
  final String label;

  ThingModel({
    required this.imagePath,
    required this.label,
  });
}
