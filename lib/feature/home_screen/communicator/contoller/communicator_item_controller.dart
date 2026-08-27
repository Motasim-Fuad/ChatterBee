import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:chatter_bee/Repository/communicator_repository/communicator_repository.dart';
import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/config/translations/language_controller.dart';
import 'package:chatter_bee/feature/home_screen/communicator/contoller/communicator_home_controller.dart';
import 'package:chatter_bee/models/aac/sentence_chip.dart';
import 'package:chatter_bee/models/communicator_models/communicator_content_model.dart';
import 'package:chatter_bee/services/speech_mode_service.dart';
import 'package:chatter_bee/services/tts_service.dart';
import 'package:chatter_bee/utils/buddy_bee_encouragement.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunicatorItemController extends GetxController {
  final CommunicatorRepository _repo = CommunicatorRepository();
  final AudioPlayer _audioPlayer = AudioPlayer();

  late final dynamic parent;
  String get parentTitle => parent is CommSubCategoryModel
      ? (parent as CommSubCategoryModel).name
      : (parent as CommCategoryModel).name;

  final RxList<CommItemModel> items = <CommItemModel>[].obs;
  final RxInt playingId = (-1).obs;

  final RxList<SentenceChip> sentence = <SentenceChip>[].obs;
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
    if (parent is CommSubCategoryModel) {
      items.value = (parent as CommSubCategoryModel).items;
    } else if (parent is CommCategoryModel) {
      items.value = (parent as CommCategoryModel).items;
    } else {
      throw ArgumentError('Communicator item screen requires a category or sub-category');
    }
  }

  // Current language
  String get _currentLang {
    try {
      return LanguageController.to.currentLocale.value.languageCode;
    } catch (_) {
      return 'en';
    }
  }

  // Buddy mode from CommunicatorHomeController
  bool get _isBuddyMode {
    try {
      return Get.find<CommunicatorHomeController>().isBuddyMode.value;
    } catch (_) {
      return false;
    }
  }

  // Refresh using the buddy-mode + language endpoint
  Future<void> refresh() async {
    final lang = _currentLang;

    final res = _isBuddyMode
        ? await _repo.getBuddyModeContent(lang: lang)
        : await _repo.getContent(lang: lang);

    if (res.isSuccess && res.data != null) {
      for (final cat in res.data!.categories) {
        if (parent is CommCategoryModel && cat.id == (parent as CommCategoryModel).id) {
          items.value = cat.items;
          break;
        }
        if (parent is CommSubCategoryModel) {
          final sub = cat.subCategories.firstWhereOrNull(
              (s) => s.id == (parent as CommSubCategoryModel).id);
          if (sub != null) {
            items.value = sub.items;
            break;
          }
        }
      }

      if (Get.isRegistered<CommunicatorHomeController>()) {
        Get.find<CommunicatorHomeController>().loadContent();
      }
    }
  }

  // Item tap — speak and/or add to the sentence bar based on Speech Mode
  void onItemTap(CommItemModel item) {
    final mode = SpeechModeService.to.currentMode.value;
    final chip = SentenceChip(
      id: item.id,
      word: item.word ?? '',
      imageUrl: item.imageIcon,
      color: item.color,
    );

    if (mode == SpeechMode.speakImmediatelyOnly) {
      selectedItemId.value = item.id;
      selectedWord.value = chip.word;
      selectedImage.value = chip.imageUrl ?? '';
      selectedColor.value = chip.color;
      _speakNow(chip.word);
      _repo.pressContent(contentType: 'item', contentId: item.id);
      BuddyBeeEncouragement.maybeShow();
      return;
    }

    sentence.add(chip);
    _syncSentencePreview();

    if (mode == SpeechMode.speakImmediately) {
      _speakNow(chip.word);
      _repo.pressContent(contentType: 'item', contentId: item.id);
    }
  }

  void addTypedText(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    sentence.add(SentenceChip(
      id: DateTime.now().millisecondsSinceEpoch,
      word: trimmed,
      isTyped: true,
    ));
    _syncSentencePreview();
    if (SpeechModeService.to.speaksOnTap) {
      _speakNow(trimmed);
    }
  }

  void removeChipAt(int index) {
    if (index < 0 || index >= sentence.length) return;
    sentence.removeAt(index);
    _syncSentencePreview();
  }

  void _syncSentencePreview() {
    if (sentence.isEmpty) {
      selectedItemId.value = -1;
      selectedWord.value = '';
      selectedImage.value = '';
      return;
    }
    final last = sentence.last;
    selectedItemId.value = last.id;
    selectedWord.value = sentence.map((c) => c.word).join(' ');
    selectedImage.value = last.imageUrl ?? '';
    selectedColor.value = last.color;
  }

  void _speakNow(String text) {
    TtsService.to.speak(text, lang: _currentLang);
  }

  // Speak the full sentence (or the last word in immediate-only mode)
  void speakSelected() {
    if (isSpeakCooldown.value) return;

    final mode = SpeechModeService.to.currentMode.value;
    if (mode == SpeechMode.speakImmediatelyOnly) {
      if (selectedWord.value.isEmpty) return;
      _speakNow(selectedWord.value);
      BuddyBeeEncouragement.maybeShow();
      _startCooldown();
      return;
    }

    if (sentence.isEmpty) return;
    final spoken = sentence.map((c) => c.word).join(' ');
    _speakNow(spoken);
    for (final chip in sentence.where((c) => !c.isTyped)) {
      _repo.pressContent(contentType: 'item', contentId: chip.id);
    }
    BuddyBeeEncouragement.maybeShow();
    _startCooldown();
  }

  // Clear Selection
  void clearSelection() {
    _stopAudio();
    TtsService.to.stop();
    selectedItemId.value = -1;
    selectedWord.value = '';
    selectedImage.value = '';
    sentence.clear();
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
    final url = AppUrl.mediaUrl(audioPath);
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
