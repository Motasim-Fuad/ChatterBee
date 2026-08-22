import 'package:chatter_bee/config/app_colors.dart';
import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:chatter_bee/feature/authentication/repo/auth_repository.dart';
import 'package:chatter_bee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateNewPasswordController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _isNewPasswordVisible = false;
  bool get isNewPasswordVisible => _isNewPasswordVisible;

  bool _isConfirmPasswordVisible = false;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isNavigating = false;
  bool _isDisposed = false;

  String? email;
  String? otp;

  bool _hasMinLength = false;
  bool get hasMinLength => _hasMinLength;
  bool get isPasswordValid => _hasMinLength;

  @override
  void onInit() {
    super.onInit();
    email = Get.arguments?['email'] ?? '';
    otp = Get.arguments?['otp'] ?? '';
  }

  @override
  void onClose() {
    _isDisposed = true;
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void toggleNewPasswordVisibility() {
    _isNewPasswordVisible = !_isNewPasswordVisible;
    update();
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    update();
  }

  void validatePassword(String password) {
    _hasMinLength = password.length >= 6;
    update();
  }

  Future<void> resetPassword() async {
    if (_isDisposed || _isNavigating) return;

    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showWarningSnackbar(
        'Empty Fields',
        'Please fill in all password fields',
      );
      return;
    }

    if (!isPasswordValid) {
      _showWarningSnackbar(
        'Password Too Short',
        'Password must be at least 6 characters',
      );
      return;
    }

    if (newPassword != confirmPassword) {
      _showErrorSnackbar(
        'Password Mismatch',
        'Passwords do not match. Please try again.',
      );
      return;
    }

    if (email == null || email!.isEmpty) {
      _showErrorSnackbar(
        'Error',
        'Email not found. Please try again.',
      );
      return;
    }

    if (otp == null || otp!.isEmpty) {
      _showErrorSnackbar(
        'Error',
        'Verification code not found. Please try again.',
      );
      return;
    }

    bool isSuccess = false;

    try {
      _setLoading(true);

      final response = await _authRepository.resetPassword(
        email: email!,
        otp: otp!,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (_isDisposed) return;

      if (response.isSuccess) {
        isSuccess = true;

        _isNavigating = true;
        _setLoading(false);
        update();

        await Future.delayed(const Duration(milliseconds: 100));

        FocusManager.instance.primaryFocus?.unfocus();

        await Future.delayed(const Duration(milliseconds: 500));

        Get.dialog(
          WillPopScope(
            onWillPop: () async => false,
            child: PasswordResetSuccessDialog(
              title: 'Successful!',
              message: 'Your password has been changed successfully.',
            ),
          ),
          barrierDismissible: false,
        );

        await Future.delayed(const Duration(milliseconds: 500));

        if (Get.isDialogOpen == true) {
          Get.back();
        }

        await Future.delayed(const Duration(milliseconds: 300));

        Get.offNamed(AppRoutes.SIGNINSCREEN);
      } else {
        _showErrorSnackbar(
          'Error',
          response.message,
        );
      }
    } catch (e) {
      if (_isDisposed) return;

      _showErrorSnackbar(
        'Error',
        'An error occurred. Please try again.',
      );
    } finally {
      if (!isSuccess && !_isDisposed && !_isNavigating) {
        _setLoading(false);
      }
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    update();
  }

  void _showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  void _showWarningSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  void goBack() {
    Get.back();
  }
}

class PasswordResetSuccessDialog extends StatefulWidget {
  final String title;
  final String message;

  const PasswordResetSuccessDialog({
    super.key,
    this.title = 'Successful!',
    this.message = 'Your password has been changed successfully.',
  });

  @override
  State<PasswordResetSuccessDialog> createState() =>
      _PasswordResetSuccessDialogState();
}

class _PasswordResetSuccessDialogState
    extends State<PasswordResetSuccessDialog> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && Get.isDialogOpen == true) {
        Get.back();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 24),
              Image.asset(ImagesLink.success, height: 100),
              const SizedBox(height: 20),
              Text(
                widget.title,
                style: GoogleFonts.nunito(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    color: const Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Image.asset(ImagesLink.successfulIcon, height: 80),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
