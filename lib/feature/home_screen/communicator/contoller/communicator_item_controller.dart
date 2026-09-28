import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:chatter_bee/Repository/communicator_repository/communicator_repository.dart';
import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/config/translations/language_controller.dart';
import 'package:chatter_bee/feature/home_screen/communicator/contoller/communicator_home_controller.dart';
import 'package:chatter_bee/models/communicator_models/communicator_content_model.dart';
import 'package:chatter_bee/services/sentence_bar_service.dart';
import 'package:chatter_bee/services/speech_mode_service.dart';
import 'package:chatter_bee/services/tts_service.dart';
import 'package:chatter_bee/utils/buddy_bee_encouragement.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunicatorItemController extends GetxController {
  final CommunicatorRepository _repo = CommunicatorRepository();
  final AudioPlayer _audioPlayer = AudioPlayer();

  /// CommCategoryLite (direct-item category) or CommSubCategoryLite.
  late final dynamic parent;
  String get parentTitle => parent is CommSubCategoryLite
      ? (parent as CommSubCategoryLite).name
      : (parent as CommCategoryLite).name;
  int get _parentId => parent is CommSubCategoryLite
      ? (parent as CommSubCategoryLite).id
      : (parent as CommCategoryLite).id;
  bool get _isSubCategory => parent is CommSubCategoryLite;

  final RxList<CommItemLite> items = <CommItemLite>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt playingId = (-1).obs;

  final RxString selectedWord = ''.obs;
  final RxInt selectedItemId = (-1).obs;
  final RxString selectedImage = ''.obs;
  final RxString selectedColor = '#FFD700'.obs;

  final RxBool isSpeakCooldown = false.obs;
  final RxInt cooldownCount = 5.obs;

  Timer? _cooldownTimer;

  @override
  void onInit() {
    super.onInit();
    parent = Get.arguments;
    if (parent is! CommSubCategoryLite && parent is! CommCategoryLite) {
      throw ArgumentError(
          'Communicator item screen requires a CommCategoryLite or CommSubCategoryLite');
    }
    _loadItems();
  }

  // Current language
  String get _currentLang {
    try {
      return LanguageController.to.currentLocale.value.languageCode;
    } catch (_) {
      return 'en';
    }
  }

  /// Loads this category's/sub-category's items lazily.
  Future<void> _loadItems() async {
    isLoading.value = true;
    final lang = _currentLang;

    if (_isSubCategory) {
      final res = await _repo.getSubCategoryItems(_parentId, lang: lang);
      isLoading.value = false;
      if (res.isSuccess && res.data != null) {
        items.value = res.data!.items;
      }
    } else {
      final res = await _repo.getCategoryItems(_parentId, lang: lang);
      isLoading.value = false;
      if (res.isSuccess && res.data != null) {
        items.value = res.data!.items;
      }
    }
  }

  Future<void> refresh() async {
    await _loadItems();
    if (Get.isRegistered<CommunicatorHomeController>()) {
      Get.find<CommunicatorHomeController>().loadContent();
    }
  }

  void onItemTap(CommItemLite item) {
    selectedItemId.value = item.id;
    SentenceBarService.to.addToken(
      text: item.word ?? '',
      imageUrl: item.imageIcon ?? '',
      colorHex: item.color,
      lang: _currentLang,
    );
    _repo.pressContent(contentType: 'item', contentId: item.id);
  }

  void promptTypedText() {
    SentenceBarService.to.beginTyping();
  }

  void _speakNow(String text) {
    TtsService.to.speak(text, lang: _currentLang);
  }

  // Speak the full sentence (or the last word in immediate-only mode)
  void speakSelected() {
    if (isSpeakCooldown.value) return;
    if (SentenceBarService.to.spokenText.isEmpty) return;
    SentenceBarService.to.speakAll(lang: _currentLang);
    if (selectedItemId.value > 0) {
      _repo.pressContent(contentType: 'item', contentId: selectedItemId.value);
    }
    _startCooldown();
  }

  void clearSelection() {
    _stopAudio();
    selectedItemId.value = -1;
    SentenceBarService.to.clear();
    _cancelCooldown();
  }

  // Cooldown helpers
  void _startCooldown() {
    _cancelCooldown();

    cooldownCount.value = 5;
    isSpeakCooldown.value = true;

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (cooldownCount.value > 0) {
        cooldownCount.value--;
      } else {
        timer.cancel();
        isSpeakCooldown.value = false;
        cooldownCount.value = 5;
      }
    });
  }

  void _cancelCooldown() {
    _cooldownTimer?.cancel();
    _cooldownTimer = null;
    isSpeakCooldown.value = false;
    cooldownCount.value = 5;
  }

  // Play Audio Internal
  Future<void> _playAudioInternal(int id, String? audioPath) async {
    // New endpoints already return a full URL for speak/image.
    final url =
    audioPath != null && audioPath.startsWith('http') ? audioPath : AppUrl.mediaUrl(audioPath);
    if (url == null) return;

    try {
      playingId.value = id;
      await _audioPlayer.play(UrlSource(url));
      _audioPlayer.onPlayerComplete.listen((_) {
        if (playingId.value == id) playingId.value = -1;
      });
    } catch (e) {
      debugPrint('Audio error: $e');
      playingId.value = -1;
    }
  }

  Future<void> _stopAudio() async {
    try {
      await _audioPlayer.stop();
    } catch (_) {}
    playingId.value = -1;
  }

  // Public legacy — kept for compatibility
  Future<void> playAudio(int id, String? audioPath) async {
    if (playingId.value == id) {
      await _stopAudio();
      return;
    }
    await _playAudioInternal(id, audioPath);
  }

  @override
  void onClose() {
    _cancelCooldown();
    _audioPlayer.dispose();
    super.onClose();
  }
}