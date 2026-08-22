import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BreakfastController extends GetxController {
  var selectedFood = ''.obs;

  final List<BreakfastItemModel> breakfastItems = [
    BreakfastItemModel(
      imagePath: ImagesLink.cerealImg,
      label: 'Cereal',
    ),
    BreakfastItemModel(
      imagePath: ImagesLink.sandwichImg,
      label: 'Sandwich',
    ),
    BreakfastItemModel(
      imagePath: ImagesLink.muffinImg,
      label: 'Muffin',
    ),
    BreakfastItemModel(
      imagePath: ImagesLink.toastImg,
      label: 'Toast',
    ),
    BreakfastItemModel(
      imagePath: ImagesLink.cheeseImg,
      label: 'Cheese',
    ),
    BreakfastItemModel(
      imagePath: ImagesLink.bagelImg,
      label: 'Bagel',
    ),
    BreakfastItemModel(
      imagePath: ImagesLink.granolaImg,
      label: 'granola',
    ),
    BreakfastItemModel(
      imagePath: ImagesLink.jellyImg,
      label: 'Jelly',
    ),
    BreakfastItemModel(
      imagePath: ImagesLink.baconImg,
      label: 'Bacon',
    ),
    BreakfastItemModel(
      imagePath: ImagesLink.eggImg,
      label: 'egg',
    ),
  ];

  void selectFood(String food) {
    selectedFood.value = food;
  }

  void speakFood() {
    if (selectedFood.value.isNotEmpty) {
      Get.snackbar(
        'Speaking',
        selectedFood.value,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        'Error',
        'Please select a breakfast item first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  void clearFood() {
    selectedFood.value = '';
  }
}

class BreakfastItemModel {
  final String imagePath;
  final String label;

  BreakfastItemModel({
    required this.imagePath,
    required this.label,
  });
}
