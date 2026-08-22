import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:chatter_bee/feature/communicator/sub_category/item_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MealsController extends GetxController {
  var selectedItem = ''.obs;

  final List<ItemModel> items = [
    ItemModel(imagePath: ImagesLink.pizzaImg, label: 'Pizza'),
    ItemModel(imagePath: ImagesLink.pastaImg, label: 'Pasta'),
    ItemModel(imagePath: ImagesLink.burgerImg, label: 'Burger'),
    ItemModel(imagePath: ImagesLink.saladImg, label: 'Salad'),
    ItemModel(imagePath: ImagesLink.noodlesImg, label: 'Noodles'),
    ItemModel(imagePath: ImagesLink.yogurtImg, label: 'Yogurt'),
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
