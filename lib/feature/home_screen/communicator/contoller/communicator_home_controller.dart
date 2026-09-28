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

  // Lightweight — counts only, no nested items/sub-categories.
  final RxList<CommCategoryLite> categories = <CommCategoryLite>[].obs;
  final RxList<CommQuickSpeakModel> quickSpeaks = <CommQuickSpeakModel>[].obs;

  final RxString quickSpeakText = ''.obs;
  final RxString quickSpeakImage = ''.obs;
  final RxString quickSpeakColor = '#FFD700'.obs;
  final RxInt selectedQsId = (-1).obs;
  final RxBool isSearchOpen = false.obs;
  final RxString searchQuery = ''.obs;

  // Server-side search results (item data is no longer loaded client-side).
  final RxList<CommSearchItemResult> searchItems = <CommSearchItemResult>[].obs;
  final RxBool isSearching = false.obs;

  Timer? _searchDebounce;

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

  /// Loads the lightweight categories list (counts only). Items load
  /// lazily per-category/sub-category once the user taps into one.
  Future<void> loadContent() async {
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
    isLoading.value = categories.isEmpty && quickSpeaks.isEmpty;

    final res = await _repo.getCategoriesLite(
      buddyMode: isBuddyMode.value,
      lang: lang,
    );

    if (res.isSuccess && res.data != null) {
      categories.assignAll(res.data!.categories);
      quickSpeaks.assignAll(res.data!.quickSpeaks);
    } else if (categories.isEmpty && quickSpeaks.isEmpty) {
      loadError.value = res.message.isNotEmpty
          ? res.message
          : 'failed_to_load_content'.tr;
    }
    isLoading.value = false;
  }

  Future<void> refresh() => loadContent();

  /// Debounced search input — call this from the search TextField's
  /// onChanged instead of setting [searchQuery] directly.
  void onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      searchQuery.value = value;
      _performSearch(value);
    });
  }

  Future<void> _performSearch(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      searchItems.clear();
      return;
    }
    isSearching.value = true;
    final res = await _repo.search(q, lang: _currentLang);
    isSearching.value = false;

    if (res.isSuccess && res.data != null) {
      searchItems.assignAll(res.data!.items);
    } else {
      searchItems.clear();
    }
  }

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

  /// Tapping a server-search item result — treated the same as tapping a
  /// quick speak (adds it to the sentence bar).
  void onSearchItemTap(CommSearchItemResult item) {
    final qs = CommQuickSpeakModel(
      id: item.id,
      word: item.word,
      speak: item.speak,
      color: item.color,
      imageIcon: item.imageIcon,
      order: item.order,
      isActive: true,
      isDeleted: false,
    );
    onQuickSpeakTap(qs);
  }

  List<CommQuickSpeakModel> get filteredQuickSpeaks {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return quickSpeaks.toList();
    return quickSpeaks.where((e) => (e.word ?? '').toLowerCase().contains(q)).toList();
  }

  /// Category name only — item-level matches now come from [searchItems].
  List<CommCategoryLite> get filteredCategories {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return categories.toList();
    return categories.where((c) => c.name.toLowerCase().contains(q)).toList();
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
  void onCategoryTap(CommCategoryLite category) {
    if (category.subCategoriesCount == 0) {
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
    _searchDebounce?.cancel();
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