import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String _keyMusicVolume = 'music_volume';
  static const String _keyGameVolume = 'game_volume';
  static const String _keyLanguage = 'language';
  static const String _keyJoystickEnabled = 'joystick_enabled';
  static const String _keyJoystickSide = 'joystick_side';
  static const String _keySelectedSkin = 'selected_skin';


  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> setSelectedSkin(String value) => setString(_keySelectedSkin, value);
  String get selectedSkin => getString(_keySelectedSkin, 'classic');

  Future<bool> setDouble(String key, double value) async => await _prefs?.setDouble(key, value) ?? false;
  double getDouble(String key, double defaultValue) => _prefs?.getDouble(key) ?? defaultValue;

  Future<bool> setString(String key, String value) async => await _prefs?.setString(key, value) ?? false;
  String getString(String key, String defaultValue) => _prefs?.getString(key) ?? defaultValue;

  Future<bool> setBool(String key, bool value) async => await _prefs?.setBool(key, value) ?? false;
  bool getBool(String key, bool defaultValue) => _prefs?.getBool(key) ?? defaultValue;

  Future<bool> setInt(String key, int value) async => await _prefs?.setInt(key, value) ?? false;
  int getInt(String key, int defaultValue) => _prefs?.getInt(key) ?? defaultValue;

  double get musicVolume => getDouble(_keyMusicVolume, 0.5);
  Future<void> setMusicVolume(double value) => setDouble(_keyMusicVolume, value);

  double get gameVolume => getDouble(_keyGameVolume, 0.7);
  Future<void> setGameVolume(double value) => setDouble(_keyGameVolume, value);

  String get language => getString(_keyLanguage, 'en');
  Future<void> setLanguage(String value) => setString(_keyLanguage, value);

  bool get joystickEnabled => getBool(_keyJoystickEnabled, true);
  Future<void> setJoystickEnabled(bool value) => setBool(_keyJoystickEnabled, value);

  String get joystickSide => getString(_keyJoystickSide, 'left');
  Future<void> setJoystickSide(String value) => setString(_keyJoystickSide, value);
}