import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;


  // Initialize SharedPreferences - Call this in main.dart before runApp()
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    print('StorageService initialized');
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call init() in main.dart');
    }
    return _prefs!;
  }

  static const String _keyUserRole = 'user_role';
  static const String _keyUserName = 'user_name';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyTheme = 'theme';
  static const String _keyLanguage = 'language';

  // Set String

  Future<bool> setString(String key, String value) async {
    return await prefs.setString(key, value);
  }

  String? getString(String key, {String? defaultValue}) {
    return prefs.getString(key) ?? defaultValue;
  }

  // Set Int

  Future<bool> setInt(String key, int value) async {
    return await prefs.setInt(key, value);
  }

  int? getInt(String key, {int? defaultValue}) {
    return prefs.getInt(key) ?? defaultValue;
  }

  // Set Bool

  Future<bool> setBool(String key, bool value) async {
    return await prefs.setBool(key, value);
  }

  bool? getBool(String key, {bool? defaultValue}) {
    return prefs.getBool(key) ?? defaultValue;
  }

  // Set Double

  Future<bool> setDouble(String key, double value) async {
    return await prefs.setDouble(key, value);
  }

  double? getDouble(String key, {double? defaultValue}) {
    return prefs.getDouble(key) ?? defaultValue;
  }

  // Set String List

  Future<bool> setStringList(String key, List<String> value) async {
    return await prefs.setStringList(key, value);
  }

  List<String>? getStringList(String key) {
    return prefs.getStringList(key);
  }


  // Save user role
  Future<bool> saveUserRole(String role) async {
    return await setString(_keyUserRole, role);
  }

  // Get user role
  String? getUserRole() {
    return getString(_keyUserRole);
  }

  // Save user name
  Future<bool> saveUserName(String name) async {
    return await setString(_keyUserName, name);
  }

  // Get user name
  String? getUserName() {
    return getString(_keyUserName);
  }

  // Set logged in status
  Future<bool> setLoggedIn(bool value) async {
    return await setBool(_keyIsLoggedIn, value);
  }

  // Check if logged in
  bool isLoggedIn() {
    return getBool(_keyIsLoggedIn, defaultValue: false) ?? false;
  }

  // Set onboarding complete
  Future<bool> setOnboardingComplete(bool value) async {
    return await setBool(_keyOnboardingComplete, value);
  }

  // Check if onboarding is complete
  bool isOnboardingComplete() {
    return getBool(_keyOnboardingComplete, defaultValue: false) ?? false;
  }

  // Save theme
  Future<bool> saveTheme(String theme) async {
    return await setString(_keyTheme, theme);
  }

  // Get theme
  String getTheme() {
    return getString(_keyTheme, defaultValue: 'light') ?? 'light';
  }

  // Save language
  Future<bool> saveLanguage(String language) async {
    return await setString(_keyLanguage, language);
  }

  // Get language
  String getLanguage() {
    return getString(_keyLanguage, defaultValue: 'en') ?? 'en';
  }


  // Remove a key
  Future<bool> remove(String key) async {
    return await prefs.remove(key);
  }

  // Clear all data
  Future<bool> clearAll() async {
    return await prefs.clear();
  }

  // Check if key exists
  bool containsKey(String key) {
    return prefs.containsKey(key);
  }

  // Get all keys
  Set<String> getAllKeys() {
    return prefs.getKeys();
  }
}
