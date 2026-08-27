import 'dart:io';
import 'package:chatter_bee/config/app_colors.dart';
import 'package:chatter_bee/feature/authentication/repo/auth_repository.dart';
import 'package:chatter_bee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chatter_bee/Repository/profile_invitation_repo.dart';
import 'package:chatter_bee/services/communicator_session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final ProfileInvitationRepo _connectionRepository = ProfileInvitationRepo();

  final Rx<File?> profileImage = Rx<File?>(null);
  final RxString selectedRole = 'Communicator'.obs;
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxString userType = ''.obs;
  final RxString voiceType = ''.obs;
  final RxString avatarUrl = ''.obs;
  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> switchableUsers = <Map<String, dynamic>>[].obs;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  // Load User Profile
  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;
      final response = await _authRepository.getProfile();

      if (response.isSuccess && response.data != null) {
        final profileData = response.data!['data'] ?? response.data!;
        userName.value = profileData['full_name'] ?? '';
        userEmail.value = profileData['email'] ?? '';
        userType.value = profileData['profile_type'] ?? '';
        voiceType.value = profileData['voice_type'] ?? '';
        avatarUrl.value = profileData['avatar'] ?? '';
        final role = profileData['role'] ?? '';
        selectedRole.value = _capitalizeRole(role);
        if (role.toString().toLowerCase() == 'caregiver') {
          await loadSwitchableUsers();
        } else {
          switchableUsers.clear();
        }
      } else {
        Get.snackbar('error'.tr, response.message,
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('error'.tr, 'failed_load_profile'.tr,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  String _capitalizeRole(String role) {
    if (role.isEmpty) return 'Communicator';
    return role[0].toUpperCase() + role.substring(1).toLowerCase();
  }

  bool get canSwitchUser => selectedRole.value.toLowerCase() == 'caregiver';

  Future<void> loadSwitchableUsers() async {
    final response = await _connectionRepository.listConnections();
    if (!response.isSuccess || response.data == null) return;
    final root = response.data!['data'] ?? response.data!;
    final raw = root is List
        ? root
        : (root['connections'] ?? root['results'] ?? const []);
    if (raw is! List) return;
    switchableUsers.assignAll(raw.whereType<Map>().map((entry) {
      final map = Map<String, dynamic>.from(entry);
      final user = map['communicator'] ?? map['user'] ?? map['linked_user'] ?? map;
      if (user is! Map) return <String, dynamic>{};
      final result = Map<String, dynamic>.from(user);
      result['_connection_id'] = map['id'];
      result['_communicator_id'] = map['communicator_id'] ??
          map['target_user_id'] ?? result['id'];
      return result;
    }).where((user) =>
        user['id'] != null || user['_communicator_id'] != null));
  }

  Future<void> switchToUser(Map<String, dynamic> user) async {
    if (user['is_active'] == false) {
      Get.snackbar(
        'error'.tr,
        'This linked account is inactive. Please reactivate it before switching.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    final id = int.tryParse(
        (user['_communicator_id'] ?? user['id']).toString());
    if (id == null) return;
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
    final response = await _authRepository.switchAccount(targetUserId: id);
    if (Get.isDialogOpen ?? false) Get.back();
    if (response.isSuccess && response.data != null) {
      final switched = response.data!;
      final role = switched.user.getRoleSafe();
      final name = switched.user.fullName.isNotEmpty
          ? switched.user.fullName
          : switched.user.email;
      await CommunicatorSessionService.to.setSelected(id, name);

      Get.offAllNamed(
        role == 'caregiver'
            ? AppRoutes.CAREGIVERPROFILE
            : AppRoutes.COMMUNICATORPROFILE,
      );
    } else if (response.statusCode == 404) {
      final name = (user['full_name'] ?? user['email'] ?? 'Communicator')
          .toString();
      await CommunicatorSessionService.to.setSelected(id, name);
      Get.offAllNamed(AppRoutes.NAVIGATIONBAR);
    } else {
      Get.snackbar('error'.tr, response.message, snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Pick Image
  Future<void> pickImage() async {
    try {
      await Get.bottomSheet(
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
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
                onTap: () async {
                  Get.back();
                  await _pickImageFromSource(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text('gallery'.tr),
                onTap: () async {
                  Get.back();
                  await _pickImageFromSource(ImageSource.gallery);
                },
              ),
              if (profileImage.value != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: Text('remove_photo'.tr,
                      style: const TextStyle(color: Colors.red)),
                  onTap: () {
                    Get.back();
                    removeProfileImage();
                  },
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

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      if (image != null) {
        profileImage.value = File(image.path);
        await _uploadAvatar(File(image.path));
      }
    } catch (e) {
      Get.snackbar('error'.tr, 'failed_pick_image'.tr,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _uploadAvatar(File file) async {
    try {
      final response = await _authRepository.updateProfile(avatar: file);
      if (response.isSuccess) {
        Get.snackbar('success'.tr, 'profile_picture_updated'.tr,
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('error'.tr, response.message,
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('error'.tr, 'failed_upload_picture'.tr,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void removeProfileImage() {
    profileImage.value = null;
    Get.snackbar('success'.tr, 'profile_picture_removed'.tr,
        snackPosition: SnackPosition.BOTTOM);
  }

  // On Subscription Tap
  void onSubscriptionTap() => Get.toNamed(AppRoutes.SUBSCRIPTION);

  void onEditPersonalInfo() {
    final role = selectedRole.value.toLowerCase();
    if (role == 'caregiver') {
      Get.toNamed(AppRoutes.CAREGIVERPROFILE);
    } else {
      Get.toNamed(AppRoutes.COMMUNICATORPROFILE);
    }
  }

  void onChangePasswordTap() => Get.toNamed(AppRoutes.CHANGEPASSWORD);
  void onPrivacyPolicyTap() => Get.toNamed(AppRoutes.PRIVACYPOLICY);
  void onSupportTap() => Get.toNamed(AppRoutes.SUPPORT);

  // On Delete Account Tap
  void onDeleteAccountTap() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(45),
            topRight: Radius.circular(45),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('delete'.tr,
                style: GoogleFonts.nunito(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor)),
            const SizedBox(height: 24),
            Text('delete_confirm'.tr,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D2D2D),
                    height: 1.5)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: Get.back,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: AppColors.primaryColor, width: 1.5),
                    ),
                    child: Text('cancel'.tr,
                        style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryColor)),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      deleteAccount();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text('yes_delete'.tr,
                        style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2D2D2D))),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }

  // On Logout Tap
  void onLogoutTap() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('logout'.tr,
                style: GoogleFonts.nunito(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor)),
            const SizedBox(height: 24),
            Text('logout_confirm'.tr,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D2D2D),
                    height: 1.5)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: Get.back,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: AppColors.primaryColor, width: 1.5),
                    ),
                    child: Text('cancel'.tr,
                        style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryColor)),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      logout();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text('yes_logout'.tr,
                        style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }

  // Delete Account
  Future<void> deleteAccount() async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()),
          barrierDismissible: false);

      final response = await _authRepository.deleteAccount();
      if (Get.isDialogOpen ?? false) Get.back();

      if (response.isSuccess) {
        Get.snackbar('success'.tr, 'account_deleted'.tr,
            snackPosition: SnackPosition.BOTTOM);
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed(AppRoutes.SIGNINSCREEN);
      } else {
        Get.snackbar('error'.tr, response.message,
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar('error'.tr, 'failed_delete_account'.tr,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()),
          barrierDismissible: false);

      final response = await _authRepository.logout();
      if (Get.isDialogOpen ?? false) Get.back();

      if (response.isSuccess) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('remembered_email');
        Get.snackbar('success'.tr, 'logged_out'.tr,
            snackPosition: SnackPosition.BOTTOM);
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed(AppRoutes.SIGNINSCREEN);
      } else {
        Get.offAllNamed(AppRoutes.SIGNINSCREEN);
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.offAllNamed(AppRoutes.SIGNINSCREEN);
    }
  }

  @override
  void onClose() => super.onClose();
}
