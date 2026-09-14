import 'package:chatter_bee/feature/authentication/repo/auth_repository.dart';
import 'package:chatter_bee/routes/app_routes.dart';
import 'package:chatter_bee/services/storage/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final SecureStorageService _secureStorage = SecureStorageService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool isPasswordVisible = false.obs;
  final RxBool rememberMe = false.obs;
  final RxBool isLoading = false.obs;
  final RxString emailError = ''.obs;
  final RxString passwordError = ''.obs;
  final RxString lastRememberedEmail = ''.obs;
  final RxBool showEmailSuggestion = false.obs;

  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();
    emailFocusNode.addListener(_onEmailFocusChanged);
    _restoreRememberedEmail();
  }

  @override
  void onClose() {
    emailFocusNode.removeListener(_onEmailFocusChanged);
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
    if (!rememberMe.value) {
      lastRememberedEmail.value = '';
      showEmailSuggestion.value = false;
      _secureStorage.clearRememberedEmail();
    }
  }

  void _onEmailFocusChanged() {
    showEmailSuggestion.value = emailFocusNode.hasFocus &&
        lastRememberedEmail.value.isNotEmpty &&
        rememberMe.value;
  }

  void applyRememberedEmail() {
    final email = lastRememberedEmail.value;
    if (email.isEmpty) return;
    emailController.text = email;
    emailController.selection =
        TextSelection.collapsed(offset: email.length);
    showEmailSuggestion.value = false;
  }

  Future<void> _restoreRememberedEmail() async {
    var saved = await _secureStorage.getRememberedEmail() ?? '';
    if (saved.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      saved = (prefs.getString('remembered_email') ?? '').trim().toLowerCase();
      if (saved.isNotEmpty) {
        await _secureStorage.saveRememberedEmail(saved);
        await prefs.remove('remembered_email');
      }
    }
    if (saved.isNotEmpty) {
      lastRememberedEmail.value = saved;
      rememberMe.value = true;
      emailController.text = saved;
    }
  }

  Future<void> _saveRememberedEmailAfterLogin(String email) async {
    if (rememberMe.value) {
      await _secureStorage.saveRememberedEmail(email);
      lastRememberedEmail.value = email.trim().toLowerCase();
    } else {
      await _secureStorage.clearRememberedEmail();
      lastRememberedEmail.value = '';
    }
  }

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

  bool validateForm() {
    final emailValid = validateEmail();
    final passwordValid = validatePassword();
    return emailValid && passwordValid;
  }

  Future<void> signIn() async {
    if (!validateForm()) {
      return;
    }

    try {
      isLoading.value = true;

      final response = await _authRepository.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (response.isSuccess && response.data != null) {
        await _saveRememberedEmailAfterLogin(emailController.text.trim());
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

  void forgotPassword() {
    Get.toNamed(AppRoutes.FORGOTSCREEN);
  }

  void goToSignUp() {
    Get.toNamed(AppRoutes.ROLESELECTION);
  }

  void clearForm() {
    emailController.clear();
    passwordController.clear();
    emailError.value = '';
    passwordError.value = '';
  }
}
