import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuestionController extends GetxController {
  var selectedQuestion = ''.obs;

  final List<QuestionModel> questions = [
    QuestionModel(
      imagePath: ImagesLink.yesOrNoImg,
      label: 'Yes or No?',
    ),
    QuestionModel(
      imagePath: ImagesLink.whatImg,
      label: 'What',
    ),
    QuestionModel(
      imagePath: ImagesLink.whoImg,
      label: 'Who',
    ),
    QuestionModel(
      imagePath: ImagesLink.howMuchImg,
      label: 'How much',
    ),
    QuestionModel(
      imagePath: ImagesLink.whereImg,
      label: 'Where',
    ),
    QuestionModel(
      imagePath: ImagesLink.whyImg,
      label: 'Why',
    ),
  ];

  void selectQuestion(String question) {
    selectedQuestion.value = question;
  }

  void speakQuestion() {
    if (selectedQuestion.value.isNotEmpty) {
      Get.snackbar(
        'Speaking',
        selectedQuestion.value,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        'Error',
        'Please select a question first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  void clearQuestion() {
    selectedQuestion.value = '';
  }
}

class QuestionModel {
  final String imagePath;
  final String label;

  QuestionModel({
    required this.imagePath,
    required this.label,
  });
}
