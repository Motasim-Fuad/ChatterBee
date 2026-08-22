// lib/services/storage/secure_storage.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  // Singleton instance
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // ==================== STORAGE KEYS ====================
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserRole = 'user_role';

  // FCM token id key
  static const String _keyFcmTokenId = 'fcm_token_id';

  // ==================== TOKEN METHODS ====================

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _keyAccessToken, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _keyRefreshToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  /// Replaces the complete authenticated identity together. This prevents
  /// requests from seeing tokens for one account and metadata for another
  /// while login/account-switch navigation is in progress.
  Future<void> saveAuthSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String email,
    required String role,
  }) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
    await _storage.write(key: _keyUserId, value: userId);
    await _storage.write(key: _keyUserEmail, value: email);
    await _storage.write(key: _keyUserRole, value: role);
  }

  // ==================== USER DATA METHODS ====================

  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _keyUserId, value: userId);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }

  Future<void> saveUserEmail(String email) async {
    await _storage.write(key: _keyUserEmail, value: email);
  }

  Future<String?> getUserEmail() async {
    return await _storage.read(key: _keyUserEmail);
  }

  Future<void> saveUserRole(String role) async {
    await _storage.write(key: _keyUserRole, value: role);
  }

  Future<String?> getUserRole() async {
    return await _storage.read(key: _keyUserRole);
  }

  // ==================== ✅ FCM TOKEN METHODS ====================

  /// Save FCM token ID returned by the backend
  Future<void> saveFcmTokenId(String tokenId) async {
    await _storage.write(key: _keyFcmTokenId, value: tokenId);
  }

  /// Get FCM Token ID
  Future<String?> getFcmTokenId() async {
    return await _storage.read(key: _keyFcmTokenId);
  }

  /// Delete FCM Token ID
  Future<void> deleteFcmTokenId() async {
    await _storage.delete(key: _keyFcmTokenId);
  }

  // ==================== CLEAR METHODS ====================

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyFcmTokenId);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  // ==================== CUSTOM KEY-VALUE ====================

  Future<void> save(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> get(String key) async {
    return await _storage.read(key: key);
  }
}
