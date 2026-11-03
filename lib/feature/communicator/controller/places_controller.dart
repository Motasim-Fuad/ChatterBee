import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chatter_bee/utils/app_toast.dart';

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
      AppToast.show(selectedPlace.value);
    } else {
      AppToast.error('Please select a place first');
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
