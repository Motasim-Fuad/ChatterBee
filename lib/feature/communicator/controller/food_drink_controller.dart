import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:chatter_bee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FoodDrinkController extends GetxController {
  var selectedFood = ''.obs;

  final List<FoodItemModel> foodItems = [
    FoodItemModel(
      imagePath: ImagesLink.appleImg,
      label: 'Apple',
      backgroundColor: const Color(0xFFFFF3E0),
      isCategory: false,
    ),
    FoodItemModel(
      imagePath: ImagesLink.waterImg,
      label: 'Water',
      backgroundColor: const Color(0xFFE3F2FD),
      isCategory: false,
    ),
    FoodItemModel(
      imagePath: ImagesLink.milkImg,
      label: 'Milk',
      backgroundColor: const Color(0xFFFFF9C4),
      isCategory: false,
    ),
    FoodItemModel(
      imagePath: ImagesLink.bananaImg,
      label: 'Banana',
      backgroundColor: const Color(0xFFFFF9C4),
      isCategory: false,
    ),
    FoodItemModel(
      imagePath: ImagesLink.teaImg,
      label: 'Tea',
      backgroundColor: const Color(0xFFE8F5E9),
      isCategory: false,
    ),
    FoodItemModel(
      imagePath: ImagesLink.juiceImg,
      label: 'Juice',
      backgroundColor: const Color(0xFFFFF3E0),
      isCategory: false,
    ),
    FoodItemModel(
      imagePath: ImagesLink.dinnerImag,
      label: 'Dinner',
      backgroundColor: const Color(0xFFFFE0B2),
      isCategory: false,
    ),
    FoodItemModel(
      imagePath: ImagesLink.breakfastImg,
      label: 'breakfast',
      backgroundColor: const Color(0xFFFFF9C4),
      isCategory: false,
    ),
    FoodItemModel(
      imagePath: ImagesLink.breakfastCapitalImg,
      label: 'Breakfast',
      backgroundColor: const Color(0xFFFFF3E0),
      isCategory: true,
    ),
    FoodItemModel(
      imagePath: ImagesLink.mealsImg,
      label: 'Meals',
      backgroundColor: const Color(0xFFFFF9C4),
      isCategory: true,
    ),
    FoodItemModel(
      imagePath: ImagesLink.drinksImg,
      label: 'Drinks',
      backgroundColor: const Color(0xFFE3F2FD),
      isCategory: true,
    ),
    FoodItemModel(
      imagePath: ImagesLink.fruitsImg,
      label: 'Fruits',
      backgroundColor: const Color(0xFFF1F8E9),
      isCategory: true,
    ),
    FoodItemModel(
      imagePath: ImagesLink.snacksImg,
      label: 'Snacks',
      backgroundColor: const Color(0xFFFFF9C4),
      isCategory: true,
    ),
  ];

  void selectFood(String food, bool isCategory) {
    if (isCategory) {
      navigateToCategory(food);
    } else {
      selectedFood.value = food;
    }
  }

  void navigateToCategory(String category) {
    switch (category) {
      case 'Breakfast':
        Get.toNamed(AppRoutes.BREAKFAST);
        break;
      case 'Meals':
        Get.toNamed(AppRoutes.MEALS);
        break;
      case 'Drinks':
        Get.toNamed(AppRoutes.DRINKS);
        break;
      case 'Fruits':
        Get.toNamed(AppRoutes.FRUITS);
        break;
      case 'Snacks':
        Get.toNamed(AppRoutes.SNACKS);
        break;
      default:
        Get.snackbar('Category', category);
    }
  }

  void speakFood() {
    if (selectedFood.value.isNotEmpty) {
      Get.snackbar(
        'Speaking',
        selectedFood.value,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        'Error',
        'Please select a food item first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  void clearFood() {
    selectedFood.value = '';
  }
}

class FoodItemModel {
  final String imagePath;
  final String label;
  final Color backgroundColor;
  final bool isCategory;

  FoodItemModel({
    required this.imagePath,
    required this.label,
    required this.backgroundColor,
    this.isCategory = false,
  });
}
