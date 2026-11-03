import 'package:chatter_bee/feature/authentication/repo/auth_repository.dart';
import 'package:chatter_bee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chatter_bee/utils/app_toast.dart';

class ForgotPasswordController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  late TextEditingController emailController;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _emailError;
  String? get emailError => _emailError;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  
  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  
  bool validateEmail() {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      _emailError = 'Email is required';
      update();
      return false;
    }

    if (!_isValidEmail(email)) {
      _emailError = 'Please enter a valid email address';
      update();
      return false;
    }

    _emailError = null;
    update();
    return true;
  }

  
  void clearEmailError() {
    if (_emailError != null) {
      _emailError = null;
      update();
    }
  }

  
  void _setLoading(bool loading) {
    _isLoading = loading;
    update();
  }

  
  Future<void> sendResetPasswordEmail() async {
    if (!validateEmail()) {
      return;
    }

    try {
      _setLoading(true);

      final response = await _authRepository.forgotPasswordRequest(
        email: emailController.text.trim(),
      );

      if (response.isSuccess) {
        AppToast.success('Password reset code sent to your email');

        Get.toNamed(
          AppRoutes.FORGOTOTPSCREEN,
          arguments: {
            'email': emailController.text.trim(),
          },
        );
      } else {
        AppToast.error(response.message);
      }
    } catch (e) {
      AppToast.error('Failed to send reset email. Please try again.');
    } finally {
      _setLoading(false);
    }
  }

  
  void onEmailChanged(String value) {
    clearEmailError();
  }
}
