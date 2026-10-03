import 'dart:async';
import 'dart:io';

import 'package:chatter_bee/Repository/notification/notification_repo.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:chatter_bee/services/storage/secure_storage.dart';

class NotificationControllerFCM extends GetxController {
  static NotificationControllerFCM get to => Get.find();

  final FcmTokenRepository _fcmRepo = FcmTokenRepository();
  final SecureStorageService _secureStorage = SecureStorageService();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  final RxString fcmToken = ''.obs;
  final RxBool isTokenRegistered = false.obs;

  StreamSubscription<String>? _tokenRefreshSub;
  Future<bool>? _registering;

  @override
  void onInit() {
    super.onInit();
    _getCurrentFcmToken();
    _tokenRefreshSub = _fcm.onTokenRefresh.listen(_onTokenRefresh);
  }

  @override
  void onClose() {
    _tokenRefreshSub?.cancel();
    super.onClose();
  }

  Future<void> _getCurrentFcmToken() async {
    try {
      if (Platform.isIOS) {
        String? apns;
        for (int i = 0; i < 5; i++) {
          apns = await _fcm.getAPNSToken();
          if (apns != null) break;
          await Future.delayed(const Duration(seconds: 2));
        }
        if (apns == null) {
          if (kDebugMode) print('APNs token not available yet');
          return;
        }
      }
      final token = await _fcm.getToken();
      fcmToken.value = token ?? '';
      if (kDebugMode) print('Current FCM Token: ${fcmToken.value}');
    } catch (e) {
      if (kDebugMode) print('Get token error: $e');
    }
  }

  Future<bool> _hasSession() async {
    final access = await _secureStorage.getAccessToken();
    return access != null && access.isNotEmpty;
  }

  Future<void> _onTokenRefresh(String token) async {
    if (token.isEmpty || token == fcmToken.value) return;
    fcmToken.value = token;
    if (await _hasSession()) {
      await registerFcmToken();
    }
  }

  Future<void> ensureRegistered() async {
    if (!await _hasSession()) return;
    await registerFcmToken();
  }

  Future<bool> registerFcmToken({bool force = false}) {
    final inFlight = _registering;
    if (inFlight != null) return inFlight;
    final future = _register(force: force).whenComplete(() => _registering = null);
    _registering = future;
    return future;
  }

  Future<bool> _register({required bool force}) async {
    try {
      if (fcmToken.value.isEmpty) {
        await _getCurrentFcmToken();
      }

      if (fcmToken.value.isEmpty) {
        if (kDebugMode) print('No FCM token available');
        return false;
      }

      final existingId = await _secureStorage.getFcmTokenId();
      final registeredToken = await _secureStorage.getFcmRegisteredToken();
      final hasExisting = existingId != null && existingId.isNotEmpty;

      if (!force && hasExisting && registeredToken == fcmToken.value) {
        isTokenRegistered.value = true;
        return true;
      }

      if (hasExisting) {
        await _fcmRepo.deleteFcmToken(tokenId: existingId);
        await _secureStorage.deleteFcmTokenId();
      }

      final response = await _fcmRepo.registerFcmToken(
        deviceToken: fcmToken.value,
        deviceType: FcmTokenRepository.getDeviceType(),
      );

      if (response.isSuccess) {
        final data = response.data;
        final tokenId = data is Map ? data['id']?.toString() : null;
        if (tokenId != null && tokenId.isNotEmpty) {
          await _secureStorage.saveFcmTokenId(tokenId);
          await _secureStorage.saveFcmRegisteredToken(fcmToken.value);
        }
        isTokenRegistered.value = true;
        if (kDebugMode) print('FCM Token registered (id: $tokenId)');
        return true;
      }

      if (kDebugMode) print('FCM registration failed: ${response.message}');
      return false;
    } catch (e) {
      if (kDebugMode) print('registerFcmToken error: $e');
      return false;
    }
  }

  Future<bool> deleteFcmToken() async {
    try {
      final tokenId = await _secureStorage.getFcmTokenId();

      if (tokenId == null || tokenId.isEmpty) {
        if (kDebugMode) print('No FCM token ID found to delete');
        isTokenRegistered.value = false;
        return true;
      }

      await _fcmRepo.deleteFcmToken(tokenId: tokenId);
      await _secureStorage.deleteFcmTokenId();
      isTokenRegistered.value = false;
      return true;
    } catch (e) {
      if (kDebugMode) print('deleteFcmToken error: $e');
      return false;
    }
  }

  Future<void> refreshAndReRegister() async {
    await _fcm.deleteToken();
    final newToken = await _fcm.getToken();
    if (newToken != null) {
      fcmToken.value = newToken;
      await registerFcmToken(force: true);
    }
  }
}
