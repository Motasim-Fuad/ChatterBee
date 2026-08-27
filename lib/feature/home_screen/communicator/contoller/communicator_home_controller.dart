import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:chatter_bee/Repository/communicator_repository/communicator_repository.dart';
import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/config/translations/language_controller.dart';
import 'package:chatter_bee/feature/authentication/repo/auth_repository.dart';
import 'package:chatter_bee/models/communicator_models/communicator_content_model.dart';
import 'package:chatter_bee/routes/app_routes.dart';
import 'package:chatter_bee/models/aac/sentence_chip.dart';
import 'package:chatter_bee/services/speech_mode_service.dart';
import 'package:chatter_bee/services/tts_service.dart';
import 'package:chatter_bee/utils/buddy_bee_encouragement.dart';
import 'package:chatter_bee/feature/Profile/controller/pro_status_controller.dart';
import 'package:chatter_bee/services/revenueCat_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunicatorHomeController extends GetxController
    with WidgetsBindingObserver {
  final CommunicatorRepository _repo = CommunicatorRepository();
  final AuthRepository _authRepository = AuthRepository();
  final AudioPlayer _audioPlayer = AudioPlayer();

  final RxBool isLoading = true.obs;
  final RxBool isBuddyMode = false.obs;
  final RxString loadError = ''.obs;

  final RxList<CommCategoryModel> categories = <CommCategoryModel>[].obs;
  final RxList<CommQuickSpeakModel> quickSpeaks = <CommQuickSpeakModel>[].obs;

  final RxString quickSpeakText = ''.obs;
  final RxString quickSpeakImage = ''.obs;
  final RxInt selectedQsId = (-1).obs;
  final RxList<SentenceChip> sentence = <SentenceChip>[].obs;
  final RxBool isSearchOpen = false.obs;
  final RxString searchQuery = ''.obs;

  final RxInt playingId = (-1).obs;

  final RxBool isSpeakCooldown = false.obs;

  final RxInt cooldownCount = 5.obs;

  Timer? _cooldownTimer;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    loadContent();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadContent();
    }
  }

  // Current language code (en / es / ar)
  String get _currentLang {
    try {
      return LanguageController.to.currentLocale.value.languageCode;
    } catch (_) {
      return 'en';
    }
  }

  // API call with buddy mode + lang routing
  Future<void> loadContent() async {
    isLoading.value = true;
    loadError.value = '';

    try {
      final profileRes = await _authRepository.getProfile();
      if (profileRes.isSuccess && profileRes.data != null) {
        final data = profileRes.data!['data'] ?? profileRes.data!;
        isBuddyMode.value = data['buddy_mode'] ?? false;
      }
    } catch (e) {
      debugPrint('CommunicatorHomeController: profile fetch error: $e');
    }

    final lang = _currentLang;

    final res = isBuddyMode.value
        ? await _repo.getBuddyModeContent(lang: lang)
        : await _repo.getContent(lang: lang);

    isLoading.value = false;

    if (res.isSuccess && res.data != null) {
      categories.assignAll(res.data!.categories);
      quickSpeaks.assignAll(res.data!.quickSpeaks);
    } else {
      categories.clear();
      quickSpeaks.clear();
      loadError.value = res.message.isNotEmpty
          ? res.message
          : 'failed_to_load_content'.tr;
    }
  }

  Future<void> refresh() => loadContent();

  void _syncSentencePreview() {
    if (sentence.isEmpty) {
      selectedQsId.value = -1;
      quickSpeakText.value = '';
      quickSpeakImage.value = '';
      return;
    }
    final last = sentence.last;
    selectedQsId.value = last.id;
    quickSpeakText.value = sentence.map((c) => c.word).join(' ');
    quickSpeakImage.value = AppUrl.mediaUrl(last.imageUrl) ?? last.imageUrl ?? '';
  }

  void onQuickSpeakTap(CommQuickSpeakModel qs) {
    final mode = SpeechModeService.to.currentMode.value;
    final chip = SentenceChip(
      id: qs.id,
      word: qs.word ?? '',
      imageUrl: qs.imageIcon,
      color: qs.color,
    );

    if (mode == SpeechMode.speakImmediatelyOnly) {
      selectedQsId.value = qs.id;
      quickSpeakText.value = chip.word;
      quickSpeakImage.value = AppUrl.mediaUrl(chip.imageUrl) ?? '';
      TtsService.to.speak(chip.word, lang: _currentLang);
      _repo.pressContent(contentType: 'quickspeak', contentId: qs.id);
      BuddyBeeEncouragement.maybeShow();
      return;
    }

    sentence.add(chip);
    _syncSentencePreview();
    if (mode == SpeechMode.speakImmediately) {
      TtsService.to.speak(chip.word, lang: _currentLang);
      _repo.pressContent(contentType: 'quickspeak', contentId: qs.id);
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
      TtsService.to.speak(trimmed, lang: _currentLang);
    }
  }

  Future<void> promptTypedText() async {
    final input = TextEditingController();
    final result = await Get.dialog<String>(
      AlertDialog(
        title: Text('tap_to_type'.tr),
        content: TextField(
          controller: input,
          autofocus: true,
          decoration: InputDecoration(hintText: 'type_to_speak_hint'.tr),
          onSubmitted: (v) => Get.back(result: v),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: Text('cancel'.tr)),
          TextButton(
            onPressed: () => Get.back(result: input.text),
            child: Text('add'.tr),
          ),
        ],
      ),
    );
    input.dispose();
    if (result != null) addTypedText(result);
  }

  void removeChipAt(int index) {
    if (index < 0 || index >= sentence.length) return;
    sentence.removeAt(index);
    _syncSentencePreview();
  }

  void onSearchItemTap(CommItemModel item) {
    final qs = CommQuickSpeakModel(
      id: item.id,
      word: item.word,
      speak: item.speak,
      color: item.color,
      imageIcon: item.imageIcon,
      order: item.order,
      isActive: item.isActive,
      isDeleted: item.isDeleted,
    );
    onQuickSpeakTap(qs);
  }

  List<CommQuickSpeakModel> get filteredQuickSpeaks {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return quickSpeaks.toList();
    return quickSpeaks.where((e) => (e.word ?? '').toLowerCase().contains(q)).toList();
  }

  List<CommCategoryModel> get filteredCategories {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return categories.toList();
    return categories.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  List<CommItemModel> get filteredItems {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final out = <CommItemModel>[];
    for (final cat in categories) {
      out.addAll(cat.items.where((i) => (i.word ?? '').toLowerCase().contains(q)));
      for (final sub in cat.subCategories) {
        out.addAll(sub.items.where((i) => (i.word ?? '').toLowerCase().contains(q)));
      }
    }
    return out;
  }

  void speakQuickSpeak() {
    if (isSpeakCooldown.value) return;
    final mode = SpeechModeService.to.currentMode.value;
    if (mode == SpeechMode.speakImmediatelyOnly) {
      if (quickSpeakText.value.isEmpty) {
        Get.snackbar('select_first'.tr, 'tap_quick_speak_first'.tr,
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      TtsService.to.speak(quickSpeakText.value, lang: _currentLang);
      BuddyBeeEncouragement.maybeShow();
      _startCooldown();
      return;
    }
    if (sentence.isEmpty) {
      Get.snackbar('select_first'.tr, 'tap_quick_speak_first'.tr,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final spoken = sentence.map((c) => c.word).join(' ');
    TtsService.to.speak(spoken, lang: _currentLang);
    for (final chip in sentence.where((c) => !c.isTyped)) {
      _repo.pressContent(contentType: 'quickspeak', contentId: chip.id);
    }
    BuddyBeeEncouragement.maybeShow();
    _startCooldown();
  }

  void clearQuickSpeak() {
    _stopAudio();
    TtsService.to.stop();
    selectedQsId.value = -1;
    quickSpeakText.value = '';
    quickSpeakImage.value = '';
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
      debugPrint('Audio play error: $e');
      playingId.value = -1;
    }
  }

  Future<void> _stopAudio() async {
    try {
      await _audioPlayer.stop();
    } catch (_) {}
    playingId.value = -1;
  }

  // Public — sub-screens may call this if they share the same AudioPlayer
  Future<void> playAudio(int id, String? audioPath) async {
    final url = AppUrl.mediaUrl(audioPath);
    if (url == null) return;

    if (playingId.value == id) {
      await _stopAudio();
      return;
    }
    await _playAudioInternal(id, audioPath);
  }

  // On Category Tap
  void onCategoryTap(CommCategoryModel category) {
    if (category.subCategories.isEmpty) {
      Get.toNamed(AppRoutes.COMMUNICATOR_ITEM, arguments: category);
    } else {
      Get.toNamed(AppRoutes.COMMUNICATOR_SUB_CATEGORY, arguments: category);
    }
  }

  void openSchedule() {
    final isPro = Get.isRegistered<ProStatusController>() &&
        ProStatusController.to.isProUser.value;
    if (isPro) {
      Get.toNamed(AppRoutes.ACTIVITIES);
      return;
    }
    _showProUpgradeDialog();
  }

  void _showProUpgradeDialog() {
    const features = [
      'Real-Time Notifications',
      'Visual Routines',
      'Advanced Customization',
      'BuddyBee Encouragement',
      'Linked Caregiver Accounts',
    ];
    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(color: Color(0xFFFFF4CF), shape: BoxShape.circle),
              child: const Icon(Icons.workspace_premium_rounded, size: 40, color: Color(0xFFF4B400)),
            ),
            const SizedBox(height: 16),
            const Text('Unlock ChatterBee Pro', textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            const Text(
              'Unlock powerful tools that help caregivers stay connected while creating a more personalized communication experience.',
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.45, color: Color(0xFF636F85)),
            ),
            const SizedBox(height: 18),
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(children: [
                const Icon(Icons.check_circle_rounded, size: 20, color: Color(0xFFF4B400)),
                const SizedBox(width: 10),
                Expanded(child: Text(feature, style: const TextStyle(fontWeight: FontWeight.w600))),
              ]),
            )),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: () { Get.back(); Get.toNamed(AppRoutes.SUBSCRIPTION); },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC857),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Unlock ChatterBee Pro', style: TextStyle(fontWeight: FontWeight.w800)),
            )),
            TextButton(onPressed: Get.back, child: const Text('Maybe Later')),
            TextButton(
              onPressed: () async {
                final restored = await RevenueCatService.instance.restorePurchases();
                if (restored && Get.isRegistered<ProStatusController>()) {
                  ProStatusController.to.isProUser.value = true;
                  Get.back();
                  Get.toNamed(AppRoutes.ACTIVITIES);
                } else {
                  Get.snackbar('Not found', 'No active subscription to restore.');
                }
              },
              child: const Text('Already subscribed? Restore Purchase'),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelCooldown();
    _audioPlayer.dispose();
    super.onClose();
  }
}

class CategoryItemModel {
  final String imagePath;
  final String label;
  final String id;

  CategoryItemModel({
    required this.imagePath,
    required this.label,
    required this.id,
  });
}
