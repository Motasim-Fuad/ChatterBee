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

  late final CommCategoryLite parentCategory;

  final RxList<CommSubCategoryLite> subCategories = <CommSubCategoryLite>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt playingId = (-1).obs;

  @override
  void onInit() {
    super.onInit();
    parentCategory = Get.arguments as CommCategoryLite;
    _load();
  }

  
  String get _currentLang {
    try {
      return LanguageController.to.currentLocale.value.languageCode;
    } catch (_) {
      return 'en';
    }
  }

  
  Future<void> _load() async {
    isLoading.value = true;
    final lang = _currentLang;

    final res = await _repo.getCategoryItems(parentCategory.id, lang: lang);

    isLoading.value = false;

    if (res.isSuccess && res.data != null) {
      subCategories.value = res.data!.subCategories;
    }
  }

  Future<void> refresh() async {
    await _load();
    if (Get.isRegistered<CommunicatorHomeController>()) {
      Get.find<CommunicatorHomeController>().loadContent();
    }
  }

  void onSubCategoryTap(CommSubCategoryLite sub) {
    Get.toNamed(AppRoutes.COMMUNICATOR_ITEM, arguments: sub);
  }

  Future<void> playAudio(int id, String? audioPath) async {
    final url = audioPath != null && audioPath.startsWith('http')
        ? audioPath
        : AppUrl.mediaUrl(audioPath);
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