import 'package:chatter_bee/feature/authentication/repo/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chatter_bee/widgets/app_shimmer.dart';
import 'package:chatter_bee/utils/app_toast.dart';

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
      AppToast.error('fill_all_fields'.tr);
      return;
    }

    if (newPassword.length < 8) {
      AppToast.error('password_min_length'.tr);
      return;
    }

    if (newPassword != confirmPassword) {
      AppToast.error('passwords_not_match'.tr);
      return;
    }

    try {
      isLoading.value = true;
      Get.dialog(const AppShimmerBlocking(), barrierDismissible: false);

      final response = await _authRepository.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
        newPassword2: confirmPassword,
      );

      if (Get.isDialogOpen ?? false) Get.back();

      if (response.isSuccess) {
        AppToast.success('password_changed'.tr);
        _clearFields();
        Get.back();
      } else {
        final oldPassError = response.getFieldError('old_password');
        final newPassError = response.getFieldError('new_password');
        final errorMsg = oldPassError ?? newPassError ?? response.message;
        AppToast.error(errorMsg);
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      AppToast.error('profile_update_failed'.tr);
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
