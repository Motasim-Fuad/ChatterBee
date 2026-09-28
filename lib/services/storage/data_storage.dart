import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;


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
  static const String _keyRememberMe = 'remember_me';
  static const String _keyBuddyMode = 'buddy_mode';
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyTheme = 'theme';
  static const String _keyLanguage = 'language';

  
  Future<bool> setString(String key, String value) async {
    return await prefs.setString(key, value);
  }

  String? getString(String key, {String? defaultValue}) {
    return prefs.getString(key) ?? defaultValue;
  }

  
  Future<bool> setInt(String key, int value) async {
    return await prefs.setInt(key, value);
  }

  int? getInt(String key, {int? defaultValue}) {
    return prefs.getInt(key) ?? defaultValue;
  }

  
  Future<bool> setBool(String key, bool value) async {
    return await prefs.setBool(key, value);
  }

  bool? getBool(String key, {bool? defaultValue}) {
    return prefs.getBool(key) ?? defaultValue;
  }

  
  Future<bool> setDouble(String key, double value) async {
    return await prefs.setDouble(key, value);
  }

  double? getDouble(String key, {double? defaultValue}) {
    return prefs.getDouble(key) ?? defaultValue;
  }

  
  Future<bool> setStringList(String key, List<String> value) async {
    return await prefs.setStringList(key, value);
  }

  List<String>? getStringList(String key) {
    return prefs.getStringList(key);
  }


  Future<bool> saveUserRole(String role) async {
    return await setString(_keyUserRole, role);
  }

  
  String? getUserRole() {
    return getString(_keyUserRole);
  }

  
  Future<bool> saveUserName(String name) async {
    return await setString(_keyUserName, name);
  }

  
  String? getUserName() {
    return getString(_keyUserName);
  }

  
  Future<bool> setLoggedIn(bool value) async {
    return await setBool(_keyIsLoggedIn, value);
  }

  
  bool isLoggedIn() {
    return getBool(_keyIsLoggedIn, defaultValue: false) ?? false;
  }

  Future<bool> setRememberMe(bool value) async {
    return await setBool(_keyRememberMe, value);
  }

  bool rememberMe() {
    return getBool(_keyRememberMe, defaultValue: false) ?? false;
  }

  bool? rememberMeOrNull() {
    if (!containsKey(_keyRememberMe)) return null;
    return getBool(_keyRememberMe);
  }

  Future<bool> setBuddyMode(bool value) async {
    return await setBool(_keyBuddyMode, value);
  }

  bool buddyMode() {
    return getBool(_keyBuddyMode, defaultValue: false) ?? false;
  }

  
  Future<bool> setOnboardingComplete(bool value) async {
    return await setBool(_keyOnboardingComplete, value);
  }

  
  bool isOnboardingComplete() {
    return getBool(_keyOnboardingComplete, defaultValue: false) ?? false;
  }

  
  Future<bool> saveTheme(String theme) async {
    return await setString(_keyTheme, theme);
  }

  
  String getTheme() {
    return getString(_keyTheme, defaultValue: 'light') ?? 'light';
  }

  
  Future<bool> saveLanguage(String language) async {
    return await setString(_keyLanguage, language);
  }

  
  String getLanguage() {
    return getString(_keyLanguage, defaultValue: 'en') ?? 'en';
  }


  Future<bool> remove(String key) async {
    return await prefs.remove(key);
  }

  
  Future<bool> clearAll() async {
    return await prefs.clear();
  }

  
  bool containsKey(String key) {
    return prefs.containsKey(key);
  }

  
  Set<String> getAllKeys() {
    return prefs.getKeys();
  }
}
