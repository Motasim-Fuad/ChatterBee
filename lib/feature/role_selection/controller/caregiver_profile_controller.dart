import 'dart:io';
import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:chatter_bee/feature/Profile/controller/pro_status_controller.dart';
import 'package:chatter_bee/feature/authentication/repo/auth_repository.dart';
import 'package:chatter_bee/routes/app_routes.dart';
import 'package:chatter_bee/services/pro_access_gate.dart';
import 'package:chatter_bee/services/storage/data_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class CaregiverProfileController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final ImagePicker _picker = ImagePicker();

  final fullNameController = TextEditingController();
  final selectedLanguage = Rx<String>('English (United States)');
  final isBuddyBeeMode = RxBool(false);
  final selectedVoiceType = Rx<String>('male_child');
  final Rx<File?> profileImage = Rx<File?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  final List<Map<String, dynamic>> voiceTypes = [
    {'type': 'male_adult',   'key': 'male_adult',   'icon': ImagesLink.adultMale},
    {'type': 'female_adult', 'key': 'female_adult', 'icon': ImagesLink.adultFemale},
    {'type': 'male_child',   'key': 'male_child',   'icon': ImagesLink.maleBoy},
    {'type': 'female_child', 'key': 'female_child', 'icon': ImagesLink.femaleChild},
  ];

  // Pro check helper
  bool get _isPro => ProStatusController.to.isProUser.value;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      final response = await _authRepository.getProfile();
      if (response.isSuccess && response.data != null) {
        final data = response.data!['data'] ?? response.data!;
        fullNameController.text = data['full_name'] ?? '';
        isBuddyBeeMode.value = data['buddy_mode'] ?? false;
        StorageService().setBuddyMode(isBuddyBeeMode.value);
        selectedVoiceType.value = data['voice_type'] ?? 'male_child';
      }
    } catch (e) {
      debugPrint('Load caregiver profile error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Buddy Bee: block free users and show upgrade dialog
  void toggleBuddyBeeMode(bool value) {
    if (value && !_isPro) {
      _showProUpgradeDialog('buddy_bee_mode'.tr);
      return;
    }
    isBuddyBeeMode.value = value;
    StorageService().setBuddyMode(value);
  }

  // Checks if another communicator can be added
  bool canAddCommunicator(int currentCount) {
    if (_isPro) return true;
    if (currentCount >= 1) {
      _showProUpgradeDialog('linked_accounts'.tr);
      return false;
    }
    return true;
  }

  void selectVoiceType(String key) => selectedVoiceType.value = key;
  void selectLanguage(String language) => selectedLanguage.value = language;

  // Pro upgrade dialog
  void _showProUpgradeDialog(String featureName) {
    ProAccessGate.show(featureName: featureName);
  }

  Future<void> pickImage() async {
    try {
      await Get.bottomSheet(
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('choose_profile_picture'.tr,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text('camera'.tr),
                onTap: () async { Get.back(); await _pickFrom(ImageSource.camera); },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text('gallery'.tr),
                onTap: () async { Get.back(); await _pickFrom(ImageSource.gallery); },
              ),
              if (profileImage.value != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: Text('remove_photo'.tr,
                      style: const TextStyle(color: Colors.red)),
                  onTap: () { Get.back(); profileImage.value = null; },
                ),
            ],
          ),
        ),
      );
    } catch (e) {
      Get.snackbar('error'.tr, 'failed_open_picker'.tr,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _pickFrom(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
          source: source, maxWidth: 512, maxHeight: 512, imageQuality: 75);
      if (image != null) profileImage.value = File(image.path);
    } catch (e) {
      Get.snackbar('error'.tr, 'failed_pick_image'.tr,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> onContinue() async {
    if (fullNameController.text.trim().isEmpty) {
      Get.snackbar('error'.tr, 'enter_full_name_error'.tr,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    try {
      isSaving.value = true;
      final response = await _authRepository.updateProfile(
        fullName: fullNameController.text.trim(),
        buddyMode: isBuddyBeeMode.value,
        voiceType: selectedVoiceType.value,
        avatar: profileImage.value,
      );
      if (response.isSuccess) {
        Get.snackbar('success'.tr, 'profile_updated'.tr,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFE8F5E9));
        Get.offAllNamed(AppRoutes.NAVIGATIONBAR);
      } else {
        Get.snackbar('error'.tr, response.message,
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('error'.tr, 'profile_update_failed'.tr,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    super.onClose();
  }
}
