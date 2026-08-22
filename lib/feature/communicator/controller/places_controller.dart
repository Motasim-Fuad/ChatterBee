import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlacesController extends GetxController {
  var selectedPlace = ''.obs;

  final List<PlaceModel> places = [
    PlaceModel(
      imagePath: ImagesLink.homeImg,
      label: 'Home',
    ),
    PlaceModel(
      imagePath: ImagesLink.parkImg,
      label: 'Park',
    ),
    PlaceModel(
      imagePath: ImagesLink.schoolImg,
      label: 'School',
    ),
    PlaceModel(
      imagePath: ImagesLink.storeImg,
      label: 'Store',
    ),
  ];

  void selectPlace(String place) {
    selectedPlace.value = place;
  }

  void speakPlace() {
    if (selectedPlace.value.isNotEmpty) {
      Get.snackbar(
        'Speaking',
        selectedPlace.value,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        'Error',
        'Please select a place first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  void clearPlace() {
    selectedPlace.value = '';
  }
}

class PlaceModel {
  final String imagePath;
  final String label;

  PlaceModel({
    required this.imagePath,
    required this.label,
  });
}
