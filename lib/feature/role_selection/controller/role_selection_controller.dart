import 'package:chatter_bee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chatter_bee/utils/app_toast.dart';

class RoleSelectionController extends GetxController {
  final RxString selectedRole = ''.obs;

  
  void selectRole(String role) {
    selectedRole.value = role;
  }

  
  Future<void> continueToSignup() async {
    if (selectedRole.value.isEmpty) {
      AppToast.error('Please select a role');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', selectedRole.value);

    print('=== ROLE SAVED ===');
    print('Selected Role: ${selectedRole.value}');

    Get.toNamed(AppRoutes.SIGNUPSCREEN);
  }

  
  void backToLogin() {
    Get.back();
  }
}
