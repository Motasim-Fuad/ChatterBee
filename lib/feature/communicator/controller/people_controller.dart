import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PeopleController extends GetxController {
  var selectedPerson = ''.obs;

  final List<PersonModel> people = [
    PersonModel(
      imagePath: ImagesLink.momImg,
      label: 'Mom',
    ),
    PersonModel(
      imagePath: ImagesLink.dadImg,
      label: 'Dad',
    ),
    PersonModel(
      imagePath: ImagesLink.brotherImg,
      label: 'Brother',
    ),
    PersonModel(
      imagePath: ImagesLink.sisterImg,
      label: 'Sister',
    ),
    PersonModel(
      imagePath: ImagesLink.friendImg,
      label: 'Friend',
    ),
  ];

  void selectPerson(String person) {
    selectedPerson.value = person;
  }

  void speakPerson() {
    if (selectedPerson.value.isNotEmpty) {
      Get.snackbar(
        'Speaking',
        selectedPerson.value,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        'Error',
        'Please select a person first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  void clearPerson() {
    selectedPerson.value = '';
  }
}

class PersonModel {
  final String imagePath;
  final String label;

  PersonModel({
    required this.imagePath,
    required this.label,
  });
}
