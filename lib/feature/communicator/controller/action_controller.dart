import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ActionController extends GetxController {
  var selectedAction = ''.obs;

  final List<ActionModel> actions = [
    ActionModel(
      imagePath: ImagesLink.call911Img,
      label: 'Call 911',
    ),
    ActionModel(
      imagePath: ImagesLink.callDoctorImg,
      label: 'Call Doctor',
    ),
    ActionModel(
      imagePath: ImagesLink.iamInPainImg,
      label: 'Iam in pain',
    ),
    ActionModel(
      imagePath: ImagesLink.iamNotWellImg,
      label: 'I am not well',
    ),
    ActionModel(
      imagePath: ImagesLink.tiredWantToImg,
      label: 'Tired, want to',
    ),
    ActionModel(
      imagePath: ImagesLink.waterPleaseImg,
      label: 'Water please',
    ),
    ActionModel(
      imagePath: ImagesLink.problemImg,
      label: 'Problem',
    ),
    ActionModel(
      imagePath: ImagesLink.wantHomeImg,
      label: 'Want home',
    ),
    ActionModel(
      imagePath: ImagesLink.callHomeImg,
      label: 'Call home',
    ),
    ActionModel(
      imagePath: ImagesLink.myMedicinesImg,
      label: 'My medicines',
    ),
  ];

  void selectAction(String action) {
    selectedAction.value = action;
  }

  void speakAction() {
    if (selectedAction.value.isNotEmpty) {
      Get.snackbar(
        'Speaking',
        selectedAction.value,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        'Error',
        'Please select an action first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  void clearAction() {
    selectedAction.value = '';
  }
}

class ActionModel {
  final String imagePath;
  final String label;

  ActionModel({
    required this.imagePath,
    required this.label,
  });
}
