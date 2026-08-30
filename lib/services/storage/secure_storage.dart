import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
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

  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserRole = 'user_role';

  static const String _keyFcmTokenId = 'fcm_token_id';
  static const String _keyRememberedEmail = 'remembered_login_email';

  String? _memAccessToken;
  String? _memRefreshToken;
  String? _memUserId;
  String? _memUserEmail;
  String? _memUserRole;
  String? _memFcmTokenId;

  Future<void> _write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> _read(String key, String? memoryValue) async {
    if (memoryValue != null && memoryValue.isNotEmpty) return memoryValue;
    return await _storage.read(key: key);
  }

  Future<void> saveAccessToken(String token) async {
    _memAccessToken = token;
    await _write(_keyAccessToken, token);
  }

  Future<String?> getAccessToken() async {
    return _read(_keyAccessToken, _memAccessToken);
  }

  Future<void> saveRefreshToken(String token) async {
    _memRefreshToken = token;
    await _write(_keyRefreshToken, token);
  }

  Future<String?> getRefreshToken() async {
    return _read(_keyRefreshToken, _memRefreshToken);
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _memAccessToken = accessToken;
    _memRefreshToken = refreshToken;
    await _write(_keyAccessToken, accessToken);
    await _write(_keyRefreshToken, refreshToken);
  }

  Future<void> saveAuthSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String email,
    required String role,
  }) async {
    _memAccessToken = accessToken;
    _memRefreshToken = refreshToken;
    _memUserId = userId;
    _memUserEmail = email;
    _memUserRole = role;

    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
    await _storage.write(key: _keyUserId, value: userId);
    await _storage.write(key: _keyUserEmail, value: email);
    await _storage.write(key: _keyUserRole, value: role);
  }

  Future<void> saveUserId(String userId) async {
    _memUserId = userId;
    await _write(_keyUserId, userId);
  }

  Future<String?> getUserId() async {
    return _read(_keyUserId, _memUserId);
  }

  Future<void> saveUserEmail(String email) async {
    _memUserEmail = email;
    await _write(_keyUserEmail, email);
  }

  Future<String?> getUserEmail() async {
    return _read(_keyUserEmail, _memUserEmail);
  }

  Future<void> saveUserRole(String role) async {
    _memUserRole = role;
    await _write(_keyUserRole, role);
  }

  Future<String?> getUserRole() async {
    return _read(_keyUserRole, _memUserRole);
  }

  Future<void> saveFcmTokenId(String tokenId) async {
    _memFcmTokenId = tokenId;
    await _write(_keyFcmTokenId, tokenId);
  }

  Future<String?> getFcmTokenId() async {
    return _read(_keyFcmTokenId, _memFcmTokenId);
  }

  Future<void> deleteFcmTokenId() async {
    _memFcmTokenId = null;
    await _storage.delete(key: _keyFcmTokenId);
  }

  Future<void> saveRememberedEmail(String email) async {
    final trimmed = email.trim().toLowerCase();
    if (trimmed.isEmpty) {
      await clearRememberedEmail();
      return;
    }
    await _storage.write(key: _keyRememberedEmail, value: trimmed);
  }

  Future<String?> getRememberedEmail() async {
    final value = await _storage.read(key: _keyRememberedEmail);
    if (value == null || value.trim().isEmpty) return null;
    return value.trim().toLowerCase();
  }

  Future<void> clearRememberedEmail() async {
    await _storage.delete(key: _keyRememberedEmail);
  }

  Future<void> clearAll() async {
    _memAccessToken = null;
    _memRefreshToken = null;
    _memUserId = null;
    _memUserEmail = null;
    _memUserRole = null;
    _memFcmTokenId = null;
    final remembered = await _storage.read(key: _keyRememberedEmail);
    await _storage.deleteAll();
    if (remembered != null && remembered.trim().isNotEmpty) {
      await _storage.write(key: _keyRememberedEmail, value: remembered.trim());
    }
  }

  Future<void> clearTokens() async {
    _memAccessToken = null;
    _memRefreshToken = null;
    _memFcmTokenId = null;
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyFcmTokenId);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> save(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> get(String key) async {
    return await _storage.read(key: key);
  }
}
