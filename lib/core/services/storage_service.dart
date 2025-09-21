import "package:shared_preferences/shared_preferences.dart";

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _preferences;

  StorageService._internal();

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._internal();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // Constructor for Provider
  StorageService() {
    _init();
  }

  Future<void> _init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  // String operations
  Future<bool> setString(String key, String value) async {
    await _init();
    return await _preferences!.setString(key, value);
  }

  String? getString(String key) {
    return _preferences?.getString(key);
  }

  // App-specific convenience methods
  static const String _authTokenKey = "auth_token";
  static const String _userIdKey = "user_id";

  Future<bool> setAuthToken(String token) async {
    return await setString(_authTokenKey, token);
  }

  String? getAuthToken() {
    return getString(_authTokenKey);
  }

  Future<bool> setUserId(String userId) async {
    return await setString(_userIdKey, userId);
  }

  String? getUserId() {
    return getString(_userIdKey);
  }

  Future<bool> clearAuthData() async {
    await _init();
    await _preferences!.remove(_authTokenKey);
    await _preferences!.remove(_userIdKey);
    return true;
  }
}
