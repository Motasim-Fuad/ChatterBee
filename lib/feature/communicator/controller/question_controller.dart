import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chatter_bee/utils/app_toast.dart';

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
      AppToast.show(selectedQuestion.value);
    } else {
      AppToast.error('Please select a question first');
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
