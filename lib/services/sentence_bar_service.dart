import 'package:chatter_bee/services/speech_mode_service.dart';
import 'package:chatter_bee/services/tts_service.dart';
import 'package:chatter_bee/utils/buddy_bee_encouragement.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SentenceToken {
  final String text;
  final String imageUrl;
  final String colorHex;

  const SentenceToken({
    required this.text,
    this.imageUrl = '',
    this.colorHex = '#FFD700',
  });
}

class SentenceBarService extends GetxService {
  static SentenceBarService get to => Get.find();

  final RxList<SentenceToken> tokens = <SentenceToken>[].obs;
  final TextEditingController typeController = TextEditingController();
  final FocusNode typeFocusNode = FocusNode();

  String get spokenText =>
      tokens.map((t) => t.text.trim()).where((t) => t.isNotEmpty).join(' ');

  void addToken({
    required String text,
    String imageUrl = '',
    String colorHex = '#FFD700',
    String? lang,
  }) {
    final word = text.trim();
    if (word.isEmpty) return;
    final mode = SpeechModeService.to;
    if (mode.buildsSentence) {
      tokens.add(SentenceToken(
        text: word,
        imageUrl: imageUrl,
        colorHex: colorHex,
      ));
    }
    if (mode.speaksOnTap) {
      TtsService.to.speak(word, lang: lang ?? 'en');
      BuddyBeeEncouragement.maybeShow();
    }
  }

  void beginTyping() {
    typeController.clear();
    typeFocusNode.requestFocus();
  }

  void submitTyped({String? lang}) {
    final text = typeController.text.trim();
    typeController.clear();
    if (text.isEmpty) return;
    addToken(text: text, lang: lang);
    typeFocusNode.unfocus();
  }

  Future<void> speakAll({String? lang}) async {
    final sentence = spokenText;
    if (sentence.isEmpty) return;
    await TtsService.to.speak(sentence, lang: lang ?? 'en');
    BuddyBeeEncouragement.maybeShow();
  }

  void clear() {
    TtsService.to.stop();
    tokens.clear();
    typeController.clear();
  }

  @override
  void onClose() {
    typeController.dispose();
    typeFocusNode.dispose();
    super.onClose();
  }
}
