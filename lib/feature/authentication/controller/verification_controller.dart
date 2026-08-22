import 'dart:async';
import 'package:chatter_bee/config/app_colors.dart';
import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:chatter_bee/feature/authentication/repo/auth_repository.dart';
import 'package:chatter_bee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class VerificationController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  List<TextEditingController> otpControllers = [];
  List<FocusNode> focusNodes = [];

  String _otpCode = '';
  String get otpCode => _otpCode;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isNavigating = false;
  bool get isNavigating => _isNavigating;

  bool _canResend = false;
  bool get canResend => _canResend;

  int _resendTimer = 59;
  int get resendTimer => _resendTimer;

  Timer? _timer;

  String? email;
  String role = '';

  bool _isDisposed = false;

  @override
  void onInit() {
    super.onInit();
    email = Get.arguments?['email'] ?? '';
    role = (Get.arguments?['role'] ?? '').toString().toLowerCase();

    _initializeOtpFields();

    _startResendTimer();
  }

  @override
  void onClose() {
    _isDisposed = true;

    _timer?.cancel();

    for (var focusNode in focusNodes) {
      if (focusNode.hasFocus) {
        focusNode.unfocus();
      }
    }

    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }

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
    if (_isDisposed || _isNavigating) return;

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
    if (_isDisposed || _isNavigating) return;

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
    if (_isDisposed) return;
    _otpCode = otpControllers.map((controller) => controller.text).join('');
  }

  void _startResendTimer() {
    _canResend = false;
    _resendTimer = 59;
    update();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }

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
    if (!_canResend || _isDisposed || email == null || email!.isEmpty) return;

    try {
      _setLoading(true);

      final response = await _authRepository.resendOtp(email: email!);

      if (_isDisposed) return;

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
      if (_isDisposed) return;

      _showErrorSnackbar(
        'Error',
        'Failed to resend code. Please try again.',
      );
    } finally {
      if (!_isDisposed) {
        _setLoading(false);
      }
    }
  }

  Future<void> verifyCode() async {
    if (_isDisposed || _isNavigating) return;

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

    bool isVerified = false;

    try {
      _setLoading(true);

      final response = await _authRepository.verifyEmail(
        email: email!,
        otp: _otpCode,
      );

      if (_isDisposed) return;

      if (response.isSuccess && response.data != null) {
        isVerified = response.data!.isVerified;

        if (isVerified) {
          await _authRepository.saveVerifiedSignupSession(
            response: response.data!,
            email: email!,
            role: role,
          );
          _isNavigating = true;
          _setLoading(false);
          update();

          await Future.delayed(const Duration(milliseconds: 100));

          for (var focusNode in focusNodes) {
            if (focusNode.hasFocus) {
              focusNode.unfocus();
            }
          }

          await Future.delayed(const Duration(milliseconds: 500));

          Get.dialog(
            WillPopScope(
              onWillPop: () async => false,
              child: VerificationSuccessDialog(
                title: 'Successful!',
                message: 'Your account has been verified successfully.',
              ),
            ),
            barrierDismissible: false,
          );

          await Future.delayed(const Duration(milliseconds: 500));

          if (Get.isDialogOpen == true) {
            Get.back();
          }

          await Future.delayed(const Duration(milliseconds: 300));

          Get.offAllNamed(
            role == 'caregiver'
                ? AppRoutes.CAREGIVERPROFILE
                : AppRoutes.COMMUNICATORPROFILE,
          );
        } else {
          _showErrorSnackbar(
            'Invalid Code',
            'The verification code is incorrect. Please try again.',
          );
          clearOtpFields();
        }
      } else {
        _showErrorSnackbar(
          'Verification Failed',
          response.message,
        );
        clearOtpFields();
      }
    } catch (e) {
      if (_isDisposed) return;

      _showErrorSnackbar(
        'Error',
        'Verification failed. Please try again.',
      );
      clearOtpFields();
    } finally {
      if (!isVerified && !_isDisposed && !_isNavigating) {
        _setLoading(false);
      }
    }
  }

  void clearOtpFields() {
    if (_isDisposed) return;

    _otpCode = '';
    for (var controller in otpControllers) {
      controller.clear();
    }
    focusNodes[0].requestFocus();
    update();
  }

  void _setLoading(bool loading) {
    if (_isDisposed) return;
    _isLoading = loading;
    update();
  }

  void _showSuccessSnackbar(String title, String message) {
    if (_isDisposed) return;

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
    if (_isDisposed) return;

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
    if (_isDisposed) return;

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
    if (_isDisposed) return;
    Get.back();
  }

  void focusOtpField(int index) {
    if (_isDisposed) return;
    if (index >= 0 && index < focusNodes.length) {
      focusNodes[index].requestFocus();
    }
  }
}

class VerificationSuccessDialog extends StatefulWidget {
  final String title;
  final String message;

  const VerificationSuccessDialog({
    super.key,
    this.title = 'Successful!',
    this.message = 'Your account has been verified successfully.',
  });

  @override
  State<VerificationSuccessDialog> createState() =>
      _VerificationSuccessDialogState();
}

class _VerificationSuccessDialogState extends State<VerificationSuccessDialog> {
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
