// lib/feature/home_screen/communicator/contoller/communicator_sub_category_controller.dart

import 'package:audioplayers/audioplayers.dart';
import 'package:chatter_bee/Repository/communicator_repository/communicator_repository.dart';
import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/config/translations/language_controller.dart';
import 'package:chatter_bee/feature/home_screen/communicator/contoller/communicator_home_controller.dart';
import 'package:chatter_bee/models/communicator_models/communicator_content_model.dart';
import 'package:chatter_bee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunicatorSubCategoryController extends GetxController {
  final CommunicatorRepository _repo = CommunicatorRepository();
  final AudioPlayer _audioPlayer = AudioPlayer();

  late final CommCategoryModel parentCategory;

  final RxList<CommSubCategoryModel> subCategories =
      <CommSubCategoryModel>[].obs;
  final RxInt playingId = (-1).obs;

  @override
  void onInit() {
    super.onInit();
    parentCategory = Get.arguments as CommCategoryModel;
    subCategories.value = parentCategory.subCategories;
  }

  // ── Current language ──────────────────────────────────────────
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
      final updated = res.data!.categories
          .firstWhereOrNull((c) => c.id == parentCategory.id);
      if (updated != null) subCategories.value = updated.subCategories;

      // Also refresh the home controller
      if (Get.isRegistered<CommunicatorHomeController>()) {
        Get.find<CommunicatorHomeController>().loadContent();
      }
    }
  }

  void onSubCategoryTap(CommSubCategoryModel sub) {
    if (sub.items.isEmpty && sub.itemsCount == 0) {
      Get.toNamed(AppRoutes.COMMUNICATOR_ITEM, arguments: sub);
    } else {
      Get.toNamed(AppRoutes.COMMUNICATOR_ITEM, arguments: sub);
    }
  }

  Future<void> playAudio(int id, String? audioPath) async {
    final url = AppUrl.mediaUrl(audioPath);
    if (url == null) return;

    if (playingId.value == id) {
      await _audioPlayer.stop();
      playingId.value = -1;
      return;
    }
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

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }
}