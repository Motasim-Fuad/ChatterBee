import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:chatter_bee/Repository/communicator_repository/communicator_repository.dart';
import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/config/translations/language_controller.dart';
import 'package:chatter_bee/feature/authentication/repo/auth_repository.dart';
import 'package:chatter_bee/models/communicator_models/communicator_content_model.dart';
import 'package:chatter_bee/routes/app_routes.dart';
import 'package:chatter_bee/services/sentence_bar_service.dart';
import 'package:chatter_bee/services/speech_mode_service.dart';
import 'package:chatter_bee/services/tts_service.dart';
import 'package:chatter_bee/utils/buddy_bee_encouragement.dart';
import 'package:chatter_bee/services/pro_access_gate.dart';
import 'package:chatter_bee/services/storage/data_storage.dart';
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
  final RxString quickSpeakColor = '#FFD700'.obs;
  final RxInt selectedQsId = (-1).obs;
  final RxBool isSearchOpen = false.obs;
  final RxString searchQuery = ''.obs;

  /// 0 = Home page, 1 = All Categories page (PageView current page)
  final RxInt homePageIndex = 0.obs;
  final pageController = PageController();

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

  String get currentLang {
    try {
      return LanguageController.to.currentLocale.value.languageCode;
    } catch (_) {
      return 'en';
    }
  }

  String get _currentLang => currentLang;

  // Home <-> All Categories page switch
  void goToPage(int i) {
    if (!pageController.hasClients) return;
    pageController.animateToPage(i,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
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
        await StorageService().setBuddyMode(isBuddyMode.value);
      }
    } catch (e) {
      debugPrint('CommunicatorHomeController: profile fetch error: $e');
    }

    final lang = _currentLang;

    final res = isBuddyMode.value
        ? await _repo.getBuddyModeContent(lang: lang)
        : await _repo.getContent(lang: lang);

    if (res.isSuccess && res.data != null) {
      categories.assignAll(res.data!.categories);
      var qs = res.data!.quickSpeaks;
      if (qs.isEmpty && isBuddyMode.value) {
        final fallback = await _repo.getContent(lang: lang);
        if (fallback.isSuccess && fallback.data != null) {
          qs = fallback.data!.quickSpeaks;
        }
      }
      quickSpeaks.assignAll(qs);
    } else {
      categories.clear();
      quickSpeaks.clear();
      loadError.value = res.message.isNotEmpty
          ? res.message
          : 'failed_to_load_content'.tr;
    }
    isLoading.value = false;
  }

  Future<void> refresh() => loadContent();

  void onQuickSpeakTap(CommQuickSpeakModel qs) {
    final word = qs.word ?? '';
    selectedQsId.value = qs.id;
    SentenceBarService.to.addToken(
      text: word,
      imageUrl: qs.imageIcon ?? '',
      colorHex: qs.color,
      lang: _currentLang,
    );
    _repo.pressContent(contentType: 'quickspeak', contentId: qs.id);
  }

  void addTypedText(String text) {
    SentenceBarService.to.addToken(text: text, lang: _currentLang);
  }

  void promptTypedText() {
    SentenceBarService.to.beginTyping();
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

  List<CommItemModel> get homeTalkButtons {
    final q = searchQuery.value.trim().toLowerCase();
    final out = <CommItemModel>[];
    for (final cat in categories) {
      out.addAll(cat.items);
      for (final sub in cat.subCategories) {
        out.addAll(sub.items);
      }
    }
    if (q.isEmpty) return out;
    return out
        .where((i) => (i.word ?? '').toLowerCase().contains(q))
        .toList();
  }

  void speakQuickSpeak() {
    if (isSpeakCooldown.value) return;
    if (SentenceBarService.to.spokenText.isEmpty) {
      Get.snackbar('select_first'.tr, 'tap_quick_speak_first'.tr,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    SentenceBarService.to.speakAll(lang: _currentLang);
    if (selectedQsId.value > 0) {
      _repo.pressContent(contentType: 'quickspeak', contentId: selectedQsId.value);
    }
    _startCooldown();
  }

  void clearQuickSpeak() {
    _stopAudio();
    selectedQsId.value = -1;
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
    final liveSubs = category.subCategories.where((s) => !s.isDeleted).toList();
    if (liveSubs.isEmpty) {
      Get.toNamed(AppRoutes.COMMUNICATOR_ITEM, arguments: category);
    } else {
      Get.toNamed(AppRoutes.COMMUNICATOR_SUB_CATEGORY, arguments: category);
    }
  }

  void openSchedule() {
    ProAccessGate.openScheduleOrPrompt();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelCooldown();
    _audioPlayer.dispose();
    pageController.dispose();
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