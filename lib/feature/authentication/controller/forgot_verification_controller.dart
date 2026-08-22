import 'dart:async';
import 'package:chatter_bee/config/app_colors.dart';
import 'package:chatter_bee/feature/authentication/repo/auth_repository.dart';
import 'package:chatter_bee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotVerificationController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  List<TextEditingController> otpControllers = [];
  List<FocusNode> focusNodes = [];

  String _otpCode = '';
  String get otpCode => _otpCode;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _canResend = false;
  bool get canResend => _canResend;

  int _resendTimer = 59;
  int get resendTimer => _resendTimer;

  Timer? _timer;

  String? email;

  @override
  void onInit() {
    super.onInit();
    email = Get.arguments?['email'] ?? '';

    _initializeOtpFields();

    _startResendTimer();
  }

  @override
  void onClose() {
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    _timer?.cancel();
    super.onClose();
  }

  void _initializeOtpFields() {
    otpControllers.clear();
    focusNodes.clear();

    for (int i = 0; i < 4; i++) {
      otpControllers.add(TextEditingController());
      focusNodes.add(FocusNode());
    }
  }

  void onOtpChanged(String value, int index) {
    if (value.isNotEmpty && value.length == 1) {
      otpControllers[index].value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: 1),
      );

      _updateOtpCode();

      if (index < 3) {
        focusNodes[index + 1].requestFocus();
      } else {
        focusNodes[index].unfocus();
      }
    } else if (value.isEmpty) {
      otpControllers[index].clear();
      _updateOtpCode();

      if (index > 0) {
        focusNodes[index - 1].requestFocus();
      }
    } else if (value.length > 1) {
      _handlePastedCode(value, index);
    }

    update();
  }

  void _handlePastedCode(String pastedValue, int startIndex) {
    String digits = pastedValue.replaceAll(RegExp(r'[^0-9]'), '');

    for (int i = 0; i < digits.length && (startIndex + i) < 4; i++) {
      otpControllers[startIndex + i].text = digits[i];
    }

    _updateOtpCode();

    int nextIndex = (startIndex + digits.length).clamp(0, 3);
    if (nextIndex == 3 && otpControllers[3].text.isNotEmpty) {
      focusNodes[3].unfocus();
    } else {
      focusNodes[nextIndex].requestFocus();
    }
  }

  void _updateOtpCode() {
    _otpCode = otpControllers.map((controller) => controller.text).join('');
  }

  void _startResendTimer() {
    _canResend = false;
    _resendTimer = 59;
    update();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        _resendTimer--;
        update();
      } else {
        _canResend = true;
        timer.cancel();
        update();
      }
    });
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> resendCode() async {
    if (!_canResend || email == null || email!.isEmpty) return;

    try {
      _setLoading(true);

      final response = await _authRepository.resendOtp(email: email!);

      if (response.isSuccess) {
        _showSuccessSnackbar(
          'Code Sent',
          'Verification code has been sent to your email',
        );

        _startResendTimer();
      } else {
        _showErrorSnackbar(
          'Error',
          response.message,
        );
      }
    } catch (e) {
      _showErrorSnackbar(
        'Error',
        'Failed to resend code. Please try again.',
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> verifyCode() async {
    if (_otpCode.length != 4) {
      _showWarningSnackbar(
        'Invalid Code',
        'Please enter the complete 4-digit verification code',
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

    try {
      _setLoading(true);

      final response = await _authRepository.verifyResetPasswordOtp(
        email: email!,
        otp: _otpCode,
      );

      if (response.isSuccess) {
        _navigateToCreatePassword();
      } else {
        _showErrorSnackbar(
          'Invalid Code',
          response.message,
        );
        clearOtpFields();
      }
    } catch (e) {
      _showErrorSnackbar(
        'Error',
        'Verification failed. Please try again.',
      );
      clearOtpFields();
    } finally {
      _setLoading(false);
    }
  }

  void clearOtpFields() {
    _otpCode = '';
    for (var controller in otpControllers) {
      controller.clear();
    }
    focusNodes[0].requestFocus();
    update();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    update();
  }

  void _navigateToCreatePassword() {
    Get.toNamed(
      AppRoutes.CREATENEWPASSSCREEN,
      arguments: {
        'email': email,
        'otp': _otpCode,
      },
    );
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

  void focusOtpField(int index) {
    if (index >= 0 && index < focusNodes.length) {
      focusNodes[index].requestFocus();
    }
  }
}
