import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chatter_bee/utils/app_toast.dart';

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
      AppToast.show(selectedHealth.value);
    } else {
      AppToast.error('Please select a health option first');
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
