import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:chatter_bee/feature/communicator/sub_category/item_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FruitsController extends GetxController {
  var selectedItem = ''.obs;

  final List<ItemModel> items = [
    ItemModel(imagePath: ImagesLink.appleImg, label: 'Apple'),
    ItemModel(imagePath: ImagesLink.grapeImg, label: 'Grape'),
    ItemModel(imagePath: ImagesLink.bananaImg, label: 'Banana'),
    ItemModel(imagePath: ImagesLink.watermelonImg, label: 'Watermelon'),
    ItemModel(imagePath: ImagesLink.orangeImg, label: 'Orange'),
    ItemModel(imagePath: ImagesLink.fruitImag, label: 'Fruit'),
    ItemModel(imagePath: ImagesLink.blueberryImag, label: 'Blueberry'),
    ItemModel(imagePath: ImagesLink.strawberryImg, label: 'Strawberry'),

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
