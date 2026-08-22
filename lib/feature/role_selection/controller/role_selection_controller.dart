import 'package:chatter_bee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoleSelectionController extends GetxController {
  final RxString selectedRole = ''.obs;

  // Select role
  void selectRole(String role) {
    selectedRole.value = role;
  }

  // Continue button - save role and go to signup
  Future<void> continueToSignup() async {
    if (selectedRole.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a role',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', selectedRole.value);

    print('=== ROLE SAVED ===');
    print('Selected Role: ${selectedRole.value}');

    Get.toNamed(AppRoutes.SIGNUPSCREEN);
  }

  // Back to login
  void backToLogin() {
    Get.back();
  }
}
