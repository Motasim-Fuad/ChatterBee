import 'package:chatter_bee/feature/authentication/repo/auth_repository.dart';
import 'package:chatter_bee/routes/app_routes.dart';
import 'package:chatter_bee/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  final RxString emailError = ''.obs;

  // Is Password Visible
  bool get isPasswordVisible => _isPasswordVisible;
  bool get isLoading => _isLoading;

  String _userRole = 'communicator';
  String get userRole => _userRole;

  @override
  void onInit() {
    super.onInit();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();

    _loadUserRole();

    print('=== SIGNUP SCREEN ===');
    print('Selected Role: $_userRole');
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    _userRole = prefs.getString('user_role') ?? 'communicator';
    update();
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    update();
  }

  // Validate form inputs
  bool _validateInputs() {
    emailError.value = '';
    if (firstNameController.text.trim().isEmpty) {
      _showErrorSnackbar('Please enter your first name');
      return false;
    }
    if (lastNameController.text.trim().isEmpty) {
      _showErrorSnackbar('Please enter your last name');
      return false;
    }

    if (emailController.text.trim().isEmpty) {
      _showErrorSnackbar('Please enter your email address');
      return false;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      _showErrorSnackbar('Please enter a valid email address');
      return false;
    }

    if (passwordController.text.isEmpty) {
      _showErrorSnackbar('Please enter a password');
      return false;
    }

    if (passwordController.text.length < 6) {
      _showErrorSnackbar('Password must be at least 6 characters long');
      return false;
    }

    return true;
  }

  // Show error snackbar
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade800,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.error_outline, color: Colors.red),
    );
  }

  // Show success snackbar
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade800,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.check_circle_outline, color: Colors.green),
    );
  }

  // Show validation errors from API
  void _showValidationErrors(Map<String, dynamic>? errors) {
    if (errors == null) return;

    String errorMessage = '';
    errors.forEach((key, value) {
      if (value is List && value.isNotEmpty) {
        errorMessage += '${value.first}\n';
      } else if (value is String) {
        errorMessage += '$value\n';
      }
    });

    if (errorMessage.isNotEmpty) {
      _showErrorSnackbar(errorMessage.trim());
    }
  }

  // Sign up method
  Future<void> signUp() async {
    if (!_validateInputs()) return;

    _isLoading = true;
    update();

    try {
      final email = emailController.text.trim();
      final password = passwordController.text;
      final firstName = firstNameController.text.trim();
      final lastName = lastNameController.text.trim();

      print('=== CALLING ${_userRole.toUpperCase()} REGISTER API ===');
      print('Email: $email');

      ApiResponse response;

      if (_userRole == 'communicator') {
        response = await _authRepository.registerCommunicator(
          email: email,
          password: password,
          password2: password,
          firstName: firstName,
          lastName: lastName,
        );
      } else {
        response = await _authRepository.registerCaregiver(
          email: email,
          password: password,
          password2: password,
          firstName: firstName,
          lastName: lastName,
        );
      }

      if (response.isSuccess) {
        print('=== REGISTRATION SUCCESSFUL ===');
        print('Status Code: ${response.statusCode}');
        print('Message: ${response.message}');

        _showSuccessSnackbar(
          response.message.isNotEmpty
              ? response.message
              : 'Verification code sent! Please check your email.',
        );

        _clearForm();

        Get.toNamed(
          AppRoutes.VERIFICATIONSCREEN,
          arguments: {
            'email': email,
            'role': _userRole,
          },
        );
      } else {
        print('=== REGISTRATION FAILED ===');
        print('Status Code: ${response.statusCode}');
        print('Message: ${response.message}');
        print('Errors: ${response.errors}');

        final emailErrors = response.errors?['email'];
        if (emailErrors is List && emailErrors.isNotEmpty) {
          emailError.value = emailErrors.first.toString();
        } else if (emailErrors is String) {
          emailError.value = emailErrors;
        }
        if (response.errors != null) {
          final otherErrors = Map<String, dynamic>.from(response.errors!)..remove('email');
          _showValidationErrors(otherErrors);
        } else {
          _showErrorSnackbar(
            response.message.isNotEmpty
                ? response.message
                : 'Registration failed. Please try again.',
          );
        }
      }
    } catch (error) {
      print('=== UNEXPECTED ERROR ===');
      print('Error: $error');
      _showErrorSnackbar('An unexpected error occurred. Please try again.');
    } finally {
      _isLoading = false;
      update();
    }
  }

  // Clear form inputs
  void _clearForm() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    passwordController.clear();
    _isPasswordVisible = false;
  }

  // Navigate to sign in screen
  void navigateToSignIn() {
    Get.toNamed(AppRoutes.SIGNINSCREEN);
  }

  // Check if form is valid
  bool get isFormValid {
    return firstNameController.text.trim().isNotEmpty &&
        lastNameController.text.trim().isNotEmpty &&
        GetUtils.isEmail(emailController.text.trim()) &&
        passwordController.text.length >= 6;
  }
}
