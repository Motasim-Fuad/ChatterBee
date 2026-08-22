import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:chatter_bee/feature/communicator/sub_category/item_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class SnacksController extends GetxController {
  var selectedItem = ''.obs;

  final List<ItemModel> items = [
    ItemModel(imagePath: ImagesLink.popcornImg, label: 'Popcorn'),
    ItemModel(imagePath: ImagesLink.frenchFriesImg, label: 'French fries'),
    ItemModel(imagePath: ImagesLink.nachosImg, label: 'Nachos'),
    ItemModel(imagePath: ImagesLink.crackersImg, label: 'Crackers'),
    ItemModel(imagePath: ImagesLink.doritosImg, label: 'Doritos'),
    ItemModel(imagePath: ImagesLink.cheeseImag, label: 'Cheese'),
    ItemModel(imagePath: ImagesLink.breadImg, label: 'Bread'),
  ];

  void selectItem(String item) => selectedItem.value = item;
  void clearItem() => selectedItem.value = '';

  void speakItem() {
    if (selectedItem.value.isNotEmpty) {
      Get.snackbar('Speaking', selectedItem.value, snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar('Error', 'Please select an item first',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900);
    }
  }
}
