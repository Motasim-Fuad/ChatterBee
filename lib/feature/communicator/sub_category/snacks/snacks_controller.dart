import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:chatter_bee/feature/communicator/sub_category/item_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chatter_bee/utils/app_toast.dart';


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
      AppToast.show(selectedItem.value);
    } else {
      AppToast.error('Please select an item first');
    }
  }
}
