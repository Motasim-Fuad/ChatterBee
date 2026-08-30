import 'package:chatter_bee/feature/Notification/notification_controller.dart';
import 'package:chatter_bee/feature/authentication/repo/auth_repository.dart';
import 'package:chatter_bee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool isPasswordVisible = false.obs;
  final RxBool rememberMe = false.obs;
  final RxBool isLoading = false.obs;
  final RxString emailError = ''.obs;
  final RxString passwordError = ''.obs;

  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();
    _restoreRememberedEmail();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.onClose();
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Toggle remember me
  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
    _persistRememberedEmail();
  }

  Future<void> _restoreRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('remembered_email') ?? '';
    if (saved.isNotEmpty) {
      emailController.text = saved;
      rememberMe.value = true;
    }
  }

  Future<void> persistRememberedEmail() => _persistRememberedEmail();

  Future<void> _persistRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe.value) {
      await prefs.setString('remembered_email', emailController.text.trim().toLowerCase());
    } else {
      await prefs.remove('remembered_email');
    }
  }

  // Validate email
  bool validateEmail() {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      emailError.value = 'Email is required';
      return false;
    }
    if (!GetUtils.isEmail(email)) {
      emailError.value = 'Please enter a valid email';
      return false;
    }
    emailError.value = '';
    return true;
  }

  // Validate password
  bool validatePassword() {
    final password = passwordController.text;
    if (password.isEmpty) {
      passwordError.value = 'Password is required';
      return false;
    }
    if (password.length < 6) {
      passwordError.value = 'Password must be at least 6 characters';
      return false;
    }
    passwordError.value = '';
    return true;
  }

  // Validate all fields
  bool validateForm() {
    final emailValid = validateEmail();
    final passwordValid = validatePassword();
    return emailValid && passwordValid;
  }

  // Sign in method with role-based navigation
  Future<void> signIn() async {
    if (!validateForm()) {
      return;
    }

    try {
      isLoading.value = true;

      final response = await _authRepository.login(
        email: emailController.text.trim(),
        password: passwordController.text,
        persistSession: rememberMe.value,
      );

      if (response.isSuccess && response.data != null) {
        await _persistRememberedEmail();
        TextInput.finishAutofillContext();

        Get.snackbar(
          'Success',
          'Login successful!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );

        Get.offAllNamed(AppRoutes.NAVIGATIONBAR);
      } else {
        if (response.statusCode == 403) {
          Get.snackbar(
            'Email Not Verified',
            'Please verify your email before logging in. Check your inbox for verification code.',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 4),
          );

        } else {
          Get.snackbar(
            'Login Failed',
            response.message,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 3),
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Forgot password method
  void forgotPassword() {
    Get.toNamed(AppRoutes.FORGOTSCREEN);
  }

  // Sign up navigation - GO TO ROLE SELECTION
  void goToSignUp() {
    Get.toNamed(AppRoutes.ROLESELECTION);
  }

  // Clear form
  void clearForm() {
    emailController.clear();
    passwordController.clear();
    emailError.value = '';
    passwordError.value = '';
    rememberMe.value = false;
  }
}
