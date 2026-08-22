import 'package:chatter_bee/feature/authentication/repo/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangePasswordController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final RxBool showOldPassword = false.obs;
  final RxBool showNewPassword = false.obs;
  final RxBool showConfirmPassword = false.obs;
  final RxBool isLoading = false.obs;

  void toggleOldPassword() => showOldPassword.value = !showOldPassword.value;
  void toggleNewPassword() => showNewPassword.value = !showNewPassword.value;
  void toggleConfirmPassword() => showConfirmPassword.value = !showConfirmPassword.value;

  Future<void> confirmChanges() async {
    final oldPassword = oldPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar('error'.tr, 'fill_all_fields'.tr,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (newPassword.length < 8) {
      Get.snackbar('error'.tr, 'password_min_length'.tr,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (newPassword != confirmPassword) {
      Get.snackbar('error'.tr, 'passwords_not_match'.tr,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading.value = true;
      Get.dialog(const Center(child: CircularProgressIndicator()),
          barrierDismissible: false);

      final response = await _authRepository.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
        newPassword2: confirmPassword,
      );

      if (Get.isDialogOpen ?? false) Get.back();

      if (response.isSuccess) {
        Get.snackbar(
          'success'.tr, 'password_changed'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE8F5E9),
        );
        _clearFields();
        Get.back();
      } else {
        final oldPassError = response.getFieldError('old_password');
        final newPassError = response.getFieldError('new_password');
        final errorMsg = oldPassError ?? newPassError ?? response.message;
        Get.snackbar('error'.tr, errorMsg,
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar('error'.tr, 'profile_update_failed'.tr,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void _clearFields() {
    oldPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  @override
  void onClose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
