import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:chatter_bee/Repository/communicator_repository/communicator_repository.dart';
import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/config/translations/language_controller.dart';
import 'package:chatter_bee/feature/authentication/repo/auth_repository.dart';
import 'package:chatter_bee/models/communicator_models/communicator_content_model.dart';
import 'package:chatter_bee/routes/app_routes.dart';
import 'package:chatter_bee/services/tts_service.dart';
import 'package:chatter_bee/feature/Profile/controller/pro_status_controller.dart';
import 'package:chatter_bee/services/revenueCat_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunicatorHomeController extends GetxController {
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

  final RxInt playingId = (-1).obs;

  final RxBool isSpeakCooldown = false.obs;

  final RxInt cooldownCount = 5.obs;

  Timer? _cooldownTimer;

  @override
  void onInit() {
    super.onInit();
    loadContent();
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

  // Quick speak tap
  void onQuickSpeakTap(CommQuickSpeakModel qs) {
    if (selectedQsId.value == qs.id) {
      selectedQsId.value = -1;
      quickSpeakText.value = '';
      quickSpeakImage.value = '';
    } else {
      selectedQsId.value = qs.id;
      quickSpeakText.value = qs.word ?? '';
      quickSpeakImage.value = AppUrl.mediaUrl(qs.imageIcon) ?? '';
    }
  }

  // Plays audio + calls pressed API + starts 2-second cooldown
  void speakQuickSpeak() {
    if (isSpeakCooldown.value) return;

    if (quickSpeakText.value.isEmpty) {
      Get.snackbar('select_first'.tr, 'tap_quick_speak_first'.tr,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final selected =
    quickSpeaks.firstWhereOrNull((q) => q.id == selectedQsId.value);
    if (selected == null) return;

    TtsService.to.speak(quickSpeakText.value, lang: _currentLang);

    _repo.pressContent(contentType: 'quickspeak', contentId: selected.id);
    _startCooldown();
  }

  void clearQuickSpeak() {
    _stopAudio();
    TtsService.to.stop();
    selectedQsId.value = -1;
    quickSpeakText.value = '';
    quickSpeakImage.value = '';
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
