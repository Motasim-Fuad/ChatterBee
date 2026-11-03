import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:chatter_bee/feature/communicator/sub_category/item_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chatter_bee/utils/app_toast.dart';

class DrinksController extends GetxController {
  var selectedItem = ''.obs;

  final List<ItemModel> items = [
    ItemModel(imagePath: ImagesLink.milkImag, label: 'Milk'),
    ItemModel(imagePath: ImagesLink.sodaImg, label: 'Soda'),
    ItemModel(imagePath: ImagesLink.smoothieImg, label: 'Smoothie'),
    ItemModel(imagePath: ImagesLink.juiceImag, label: 'Juice'),
  ];

  void selectItem(String item) => selectedItem.value = item;
  void clearItem() => selectedItem.value = '';

  void speakItem() {
    if (selectedItem.value.isNotEmpty) {
      AppToast.show(selectedItem.value);
    } else {
      AppToast.error('Please select an item first');
    }
  }
}
