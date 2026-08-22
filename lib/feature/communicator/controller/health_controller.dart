import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HealthController extends GetxController {
  var selectedHealth = ''.obs;

  final List<HealthModel> healthItems = [
    HealthModel(
      imagePath: ImagesLink.feelSickImg,
      label: 'I feel sick',
    ),
    HealthModel(
      imagePath: ImagesLink.needDoctorImg,
      label: 'I need a doctor',
    ),
    HealthModel(
      imagePath: ImagesLink.headHurtsImg,
      label: 'My head hurts',
    ),
    HealthModel(
      imagePath: ImagesLink.needMedicineImg,
      label: 'I need medicine',
    ),
  ];

  void selectHealth(String health) {
    selectedHealth.value = health;
  }

  void speakHealth() {
    if (selectedHealth.value.isNotEmpty) {
      Get.snackbar(
        'Speaking',
        selectedHealth.value,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        'Error',
        'Please select a health option first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  void clearHealth() {
    selectedHealth.value = '';
  }
}

class HealthModel {
  final String imagePath;
  final String label;

  HealthModel({
    required this.imagePath,
    required this.label,
  });
}
