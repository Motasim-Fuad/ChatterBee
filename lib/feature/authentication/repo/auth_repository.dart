import 'dart:io';
import 'package:chatter_bee/feature/authentication/model/auth_model.dart';
import 'package:chatter_bee/services/notification_controller.dart';
import 'package:chatter_bee/services/storage/data_storage.dart';
import 'package:chatter_bee/services/storage/secure_storage.dart';
import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/services/api_client.dart';
import 'package:chatter_bee/utils/logger_utils.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:chatter_bee/routes/app_routes.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();
  final SecureStorageService _secureStorage = SecureStorageService();
  final StorageService _storage = StorageService();

  // Register Communicator
  Future<ApiResponse<RegisterResponse>> registerCommunicator({
    required String email,
    required String password,
    required String password2,
    required String firstName,
    required String lastName,
  }) async {
    try {
      LoggerUtils.logInfo('=== REGISTERING COMMUNICATOR ===');
      final response = await _apiClient.post<Map<String, dynamic>>(
        AppUrl.communicatorRegister,
        data: {'email': email.toLowerCase().trim(), 'password': password, 'password2': password2, 'first_name': firstName, 'last_name': lastName},
      );
      if (response.isSuccess && response.data != null) {
        final registerResponse = RegisterResponse.fromJson(response.data!);
        await _storage.saveUserRole('communicator');
        await _storage.saveUserName('$firstName $lastName'.trim());
        return ApiResponse.success(data: registerResponse, statusCode: response.statusCode, message: response.message);
      }
      return ApiResponse.error(statusCode: response.statusCode, message: response.message, errors: response.errors);
    } catch (e) {
      return ApiResponse.error(statusCode: 500, message: 'Failed to register. Please try again.');
    }
  }

  // Register Caregiver
  Future<ApiResponse<RegisterResponse>> registerCaregiver({
    required String email,
    required String password,
    required String password2,
    required String firstName,
    required String lastName,
  }) async {
    try {
      LoggerUtils.logInfo('=== REGISTERING CAREGIVER ===');
      final response = await _apiClient.post<Map<String, dynamic>>(
        AppUrl.caregiverRegister,
        data: {'email': email.toLowerCase().trim(), 'password': password, 'password2': password2, 'first_name': firstName, 'last_name': lastName},
      );
      if (response.isSuccess && response.data != null) {
        final registerResponse = RegisterResponse.fromJson(response.data!);
        await _storage.saveUserRole('caregiver');
        await _storage.saveUserName('$firstName $lastName'.trim());
        return ApiResponse.success(data: registerResponse, statusCode: response.statusCode, message: response.message);
      }
      return ApiResponse.error(statusCode: response.statusCode, message: response.message, errors: response.errors);
    } catch (e) {
      return ApiResponse.error(statusCode: 500, message: 'Failed to register. Please try again.');
    }
  }

  // Login
  Future<ApiResponse<LoginResponse>> login({required String email, required String password}) async {
    try {
      LoggerUtils.logInfo('=== LOGIN ===');
      final response = await _apiClient.post<Map<String, dynamic>>(
        AppUrl.login,
        data: {'email': email, 'password': password},
      );
      if (response.isSuccess && response.data != null) {
        final loginResponse = LoginResponse.fromJson(response.data!);
        await _saveAuthData(loginResponse);
        final isRegistered = await NotificationControllerFCM.to.registerFcmToken();
        print('FCM registered: $isRegistered');
        return ApiResponse.success(data: loginResponse, statusCode: response.statusCode, message: response.message);
      }
      return ApiResponse.error(statusCode: response.statusCode, message: response.message, errors: response.errors);
    } catch (e) {
      return ApiResponse.error(statusCode: 500, message: 'Failed to login. Please try again.');
    }
  }

  Future<ApiResponse<LoginResponse>> switchAccount({required int targetUserId}) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        AppUrl.switchConnection,
        data: {'target_user_id': targetUserId},
      );
      if (response.isSuccess && response.data != null) {
        final switched = LoginResponse.fromJson(response.data!);
        if (!switched.user.isActive) {
          return ApiResponse.error(
            statusCode: 409,
            message: 'This linked account is inactive. Please reactivate it before switching.',
          );
        }
        await _saveAuthData(switched);
        return ApiResponse.success(
          data: switched,
          statusCode: response.statusCode,
          message: response.message,
        );
      }
      return ApiResponse.error(statusCode: response.statusCode, message: response.message, errors: response.errors);
    } catch (_) {
      return ApiResponse.error(statusCode: 500, message: 'Unable to switch account. Please try again.');
    }
  }

  // Verify Email
  Future<ApiResponse<VerifyEmailResponse>> verifyEmail({required String email, required String otp}) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(AppUrl.verifyEmail, data: {'email': email, 'otp': otp});
      if (response.isSuccess && response.data != null) {
        final verified = VerifyEmailResponse.fromJson(response.data!);
        return ApiResponse.success(data: verified, statusCode: response.statusCode, message: response.message);
      }
      return ApiResponse.error(statusCode: response.statusCode, message: response.message, errors: response.errors);
    } catch (e) {
      return ApiResponse.error(statusCode: 500, message: 'Failed to verify email. Please try again.');
    }
  }

  // Resend Otp
  Future<ApiResponse<Map<String, dynamic>>> resendOtp({required String email}) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(AppUrl.resendOtp, data: {'email': email, "purpose": "verification"});
      if (response.isSuccess) {
        return ApiResponse.success(data: response.data ?? {}, statusCode: response.statusCode, message: response.message);
      }
      return ApiResponse.error(statusCode: response.statusCode, message: response.message, errors: response.errors);
    } catch (e) {
      return ApiResponse.error(statusCode: 500, message: 'Failed to resend OTP. Please try again.');
    }
  }

  // Forgot Password Request
  Future<ApiResponse<ForgotPasswordResponse>> forgotPasswordRequest({required String email}) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(AppUrl.forgotPassword, data: {'email': email});
      if (response.isSuccess && response.data != null) {
        return ApiResponse.success(data: ForgotPasswordResponse.fromJson(response.data!), statusCode: response.statusCode, message: response.message);
      }
      return ApiResponse.error(statusCode: response.statusCode, message: response.message, errors: response.errors);
    } catch (e) {
      return ApiResponse.error(statusCode: 500, message: 'Failed to send reset OTP. Please try again.');
    }
  }

  // Verify Reset Password Otp
  Future<ApiResponse<Map<String, dynamic>>> verifyResetPasswordOtp({required String email, required String otp}) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(AppUrl.verifyResetOtp, data: {'email': email, 'otp': otp});
      if (response.isSuccess) {
        return ApiResponse.success(data: response.data ?? {}, statusCode: response.statusCode, message: response.message);
      }
      return ApiResponse.error(statusCode: response.statusCode, message: response.message, errors: response.errors);
    } catch (e) {
      return ApiResponse.error(statusCode: 500, message: 'Failed to verify OTP. Please try again.');
    }
  }

  // Reset Password
  Future<ApiResponse<ResetPasswordResponse>> resetPassword({
    required String email, required String otp,
    required String newPassword, required String confirmPassword,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        AppUrl.resetPassword,
        data: {'email': email, 'otp': otp, 'new_password': newPassword, 'new_password2': confirmPassword},
      );
      if (response.isSuccess && response.data != null) {
        return ApiResponse.success(data: ResetPasswordResponse.fromJson(response.data!), statusCode: response.statusCode, message: response.message);
      }
      return ApiResponse.error(statusCode: response.statusCode, message: response.message, errors: response.errors);
    } catch (e) {
      return ApiResponse.error(statusCode: 500, message: 'Failed to reset password. Please try again.');
    }
  }

  // Change Password
  Future<ApiResponse<Map<String, dynamic>>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPassword2,
  }) async {
    try {
      LoggerUtils.logInfo('=== CHANGE PASSWORD ===');
      final response = await _apiClient.post<Map<String, dynamic>>(
        AppUrl.changePassword,
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
          'new_password2': newPassword2,
        },
      );
      if (response.isSuccess) {
        LoggerUtils.logSuccess('Password changed successfully');
        return ApiResponse.success(data: response.data ?? {}, statusCode: response.statusCode, message: response.message);
      }
      return ApiResponse.error(statusCode: response.statusCode, message: response.message, errors: response.errors);
    } catch (e) {
      LoggerUtils.logError('Change password error: $e');
      return ApiResponse.error(statusCode: 500, message: 'Failed to change password. Please try again.');
    }
  }

  // Get Profile
  Future<ApiResponse<Map<String, dynamic>>> getProfile() async {
    try {
      LoggerUtils.logInfo('=== GET PROFILE ===');
      final response = await _apiClient.get<Map<String, dynamic>>(AppUrl.profile);
      if (response.isSuccess && response.data != null) {
        LoggerUtils.logSuccess('Profile fetched successfully');
        return ApiResponse.success(data: response.data!, statusCode: response.statusCode, message: response.message);
      }
      return ApiResponse.error(statusCode: response.statusCode, message: response.message, errors: response.errors);
    } catch (e) {
      LoggerUtils.logError('Get profile error: $e');
      return ApiResponse.error(statusCode: 500, message: 'Failed to load profile. Please try again.');
    }
  }

  // Update Profile
  Future<ApiResponse<Map<String, dynamic>>> updateProfile({
    String? fullName,
    bool? buddyMode,
    String? profileType,
    String? voiceType,
    File? avatar,
  }) async {
    try {
      LoggerUtils.logInfo('=== UPDATE PROFILE ===');

      final Map<String, dynamic> formMap = {};
      if (fullName != null) formMap['full_name'] = fullName;
      if (buddyMode != null) formMap['buddy_mode'] = buddyMode.toString();
      if (profileType != null) formMap['profile_type'] = profileType;
      if (voiceType != null) formMap['voice_type'] = voiceType;

      if (avatar != null) {
        formMap['avatar'] = await MultipartFile.fromFile(
          avatar.path,
          filename: avatar.path.split('/').last,
        );
      }

      final formData = FormData.fromMap(formMap);

      final response = await _apiClient.multipartPut<Map<String, dynamic>>(
        AppUrl.profile,
        formData: formData,
      );

      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        final profileData = data['data'] ?? data;
        if (profileData['full_name'] != null) {
          await _storage.saveUserName(profileData['full_name']);
        }
        LoggerUtils.logSuccess('Profile updated successfully');
        return ApiResponse.success(data: data, statusCode: response.statusCode, message: response.message);
      }

      return ApiResponse.error(statusCode: response.statusCode, message: response.message, errors: response.errors);
    } catch (e) {
      LoggerUtils.logError('Update profile error: $e');
      return ApiResponse.error(statusCode: 500, message: 'Failed to update profile. Please try again.');
    }
  }

  // Delete Account
  Future<ApiResponse<Map<String, dynamic>>> deleteAccount() async {
    try {
      LoggerUtils.logInfo('=== DELETE ACCOUNT ===');
      final response = await _apiClient.post<Map<String, dynamic>>(
        AppUrl.deleteAccount,
        data: {'confirm': true},
      );
      if (response.isSuccess) {
        await _clearAuthData();
        LoggerUtils.logSuccess('Account deleted successfully');
        return ApiResponse.success(data: response.data ?? {}, statusCode: response.statusCode, message: response.message);
      }
      return ApiResponse.error(statusCode: response.statusCode, message: response.message, errors: response.errors);
    } catch (e) {
      LoggerUtils.logError('Delete account error: $e');
      return ApiResponse.error(statusCode: 500, message: 'Failed to delete account. Please try again.');
    }
  }

  // Logout
  Future<ApiResponse<void>> logout() async {
    try {
      LoggerUtils.logInfo('=== LOGOUT ===');
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _apiClient.post<Map<String, dynamic>>(AppUrl.logout, data: {'refresh': refreshToken});
      }
      await NotificationControllerFCM.to.deleteFcmToken();
      await _clearAuthData();
      return ApiResponse.success(data: null, statusCode: 200, message: 'Logged out successfully');
    } catch (e) {
      await _clearAuthData();
      return ApiResponse.success(data: null, statusCode: 200, message: 'Logged out successfully');
    }
  }

  // Handle Unauthorized
  Future<void> handleUnauthorized() async {
    try {
      await NotificationControllerFCM.to.deleteFcmToken();
      await _clearAuthData();
      Get.offAllNamed(AppRoutes.SIGNINSCREEN);
      Get.snackbar('Session Expired', 'Please login again', snackPosition: SnackPosition.TOP);
    } catch (e) {
      LoggerUtils.logError('Handle unauthorized error: $e');
    }
  }

  Future<void> _saveAuthData(LoginResponse loginResponse) async {
    if (loginResponse.accessToken.isEmpty || loginResponse.refreshToken.isEmpty) {
      throw StateError('Authentication response did not contain both tokens.');
    }
    final role = loginResponse.user.role ?? 'user';
    await _secureStorage.saveAuthSession(
      accessToken: loginResponse.accessToken,
      refreshToken: loginResponse.refreshToken,
      userId: loginResponse.user.id,
      email: loginResponse.user.email,
      role: role,
    );
    await _storage.saveUserRole(role);
    await _storage.saveUserName(loginResponse.user.fullName);
    await _storage.setLoggedIn(true);
  }

  Future<void> saveVerifiedSignupSession({
    required VerifyEmailResponse response,
    required String email,
    required String role,
  }) async {
    if (response.accessToken.isEmpty || response.refreshToken.isEmpty) {
      throw StateError('Verification succeeded without authentication tokens.');
    }
    await _secureStorage.saveAuthSession(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      userId: '',
      email: email,
      role: role,
    );
    await _storage.saveUserRole(role);
    await _storage.setLoggedIn(true);
  }

  Future<void> _clearAuthData() async {
    await _secureStorage.clearAll();
    await _storage.clearAll();
  }

  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.getAccessToken();
    return token != null && token.isNotEmpty && _storage.isLoggedIn();
  }

  Future<String?> getUserRole() async => await _secureStorage.getUserRole();
}
