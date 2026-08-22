// lib/feature/notification/repo/fcm_token_repository.dart

import 'dart:io';
import 'dart:developer' as developer;
import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/services/api_client.dart';
import 'package:flutter/foundation.dart';

class FcmTokenRepository {
  final ApiClient _apiClient = ApiClient();

  /// Register FCM token with the backend
  Future<ApiResponse> registerFcmToken({
    required String deviceToken,
    required String deviceType,
  }) async {
    try {
      final String url = "${AppUrl.baseUrl}/api/notification/fcm-tokens/";
      final data = {
        "token": deviceToken,
        "device_type": deviceType,
      };

      if (kDebugMode) {
        developer.log('📤 Registering FCM token', name: 'FcmTokenRepo');
        developer.log('URL: $url', name: 'FcmTokenRepo');
        developer.log('Data: $data', name: 'FcmTokenRepo');
      }

      final response = await _apiClient.post(url, data: data);

      if (kDebugMode) {
        developer.log('✅ FCM Token response: ${response.statusCode}', name: 'FcmTokenRepo');
        developer.log('Response data: ${response.data}', name: 'FcmTokenRepo');
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        developer.log('❌ FCM registration failed: $e', name: 'FcmTokenRepo');
      }
      return ApiResponse.error(
        statusCode: 500,
        message: e.toString(),
      );
    }
  }

  /// Delete FCM token by ID
  Future<ApiResponse> deleteFcmToken({required String tokenId}) async {
    try {
      final String url = "${AppUrl.baseUrl}/api/notification/fcm-tokens/$tokenId/";

      if (kDebugMode) {
        developer.log('🗑️ Deleting FCM token', name: 'FcmTokenRepo');
        developer.log('DELETE 👉 $url', name: 'FcmTokenRepo');
      }

      final response = await _apiClient.delete(url);

      if (kDebugMode) {
        developer.log('DELETE status: ${response.statusCode}', name: 'FcmTokenRepo');
      }

      if (response.isSuccess || response.statusCode == 204) {
        if (kDebugMode) {
          developer.log('✅ FCM Token deleted successfully', name: 'FcmTokenRepo');
        }
        return response;
      } else {
        final errorMsg = "Delete failed with status: ${response.statusCode}";
        if (kDebugMode) developer.log('❌ $errorMsg', name: 'FcmTokenRepo');
        return ApiResponse.error(
          statusCode: response.statusCode,
          message: errorMsg,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log('❌ FCM delete failed: $e', name: 'FcmTokenRepo');
      }
      return ApiResponse.error(
        statusCode: 500,
        message: e.toString(),
      );
    }
  }

  /// Detect device type
  static String getDeviceType() {
    if (Platform.isAndroid) return "android";
    if (Platform.isIOS) return "ios";
    return "unknown";
  }
}