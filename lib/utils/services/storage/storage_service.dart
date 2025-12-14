import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String _keyMusicVolume = 'music_volume';
  static const String _keyGameVolume = 'game_volume';
  static const String _keyLanguage = 'language';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool> setDouble(String key, double value) async {
    return await _prefs?.setDouble(key, value) ?? false;
  }

  double getDouble(String key, double defaultValue) {
    return _prefs?.getDouble(key) ?? defaultValue;
  }

  Future<bool> setString(String key, String value) async {
    return await _prefs?.setString(key, value) ?? false;
  }

  String getString(String key, String defaultValue) {
    return _prefs?.getString(key) ?? defaultValue;
  }

  Future<bool> setBool(String key, bool value) async {
    return await _prefs?.setBool(key, value) ?? false;
  }

  bool getBool(String key, bool defaultValue) {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  Future<bool> setInt(String key, int value) async {
    return await _prefs?.setInt(key, value) ?? false;
  }

  int getInt(String key, int defaultValue) {
    return _prefs?.getInt(key) ?? defaultValue;
  }

  Future<bool> remove(String key) async {
    return await _prefs?.remove(key) ?? false;
  }

  Future<bool> clear() async {
    return await _prefs?.clear() ?? false;
  }

  double get musicVolume => getDouble(_keyMusicVolume, 0.5);
  Future<void> setMusicVolume(double value) => setDouble(_keyMusicVolume, value);

  double get gameVolume => getDouble(_keyGameVolume, 0.7);
  Future<void> setGameVolume(double value) => setDouble(_keyGameVolume, value);

  String get language => getString(_keyLanguage, 'en');
  Future<void> setLanguage(String value) => setString(_keyLanguage, value);
}