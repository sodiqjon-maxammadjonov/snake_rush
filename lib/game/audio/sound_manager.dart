import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
// import 'package:audioplayers/audioplayers.dart'; // Kelajakda qo'shiladi

/// Tovush boshqaruvchisi
class SoundManager extends ChangeNotifier {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  // Settings
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  double _soundVolume = 0.7;
  double _musicVolume = 0.5;

  // Audio players (kelajakda to'ldiriladi)
  // late final AudioPlayer _sfxPlayer;
  // late final AudioPlayer _musicPlayer;

  // ==================== GETTERS ====================
  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  double get soundVolume => _soundVolume;
  double get musicVolume => _musicVolume;

  // ==================== INITIALIZATION ====================

  Future<void> initialize() async {
    // Audio player'larni sozlash
    // _sfxPlayer = AudioPlayer();
    // _musicPlayer = AudioPlayer();

    // Settings'dan yuklash
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Storage'dan sozlamalarni yuklash
    // TODO: SharedPreferences yoki Hive
  }

  // ==================== SETTINGS ====================

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    notifyListeners();
    _saveSettings();
  }

  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;

    if (!enabled) {
      stopMusic();
    } else {
      playBackgroundMusic();
    }

    notifyListeners();
    _saveSettings();
  }

  void setSoundVolume(double volume) {
    _soundVolume = volume.clamp(0.0, 1.0);
    // _sfxPlayer.setVolume(_soundVolume);
    notifyListeners();
    _saveSettings();
  }

  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
    // _musicPlayer.setVolume(_musicVolume);
    notifyListeners();
    _saveSettings();
  }

  Future<void> _saveSettings() async {
    // Settings'ni saqlash
    // TODO: SharedPreferences
  }

  // ==================== SOUND EFFECTS ====================

  /// Ovqat yeyilganda
  Future<void> playFoodEat() async {
    if (!_soundEnabled) return;

    // await _sfxPlayer.play(AssetSource('sounds/food_eat.mp3'));
    _playHaptic(HapticPattern.light);
  }

  /// Ilon o'lganda
  Future<void> playDeath() async {
    if (!_soundEnabled) return;

    // await _sfxPlayer.play(AssetSource('sounds/death.mp3'));
    _playHaptic(HapticPattern.heavy);
  }

  /// Power-up olinganda
  Future<void> playPowerUp() async {
    if (!_soundEnabled) return;

    // await _sfxPlayer.play(AssetSource('sounds/powerup.mp3'));
    _playHaptic(HapticPattern.medium);
  }

  /// Boshqa ilonni yutish
  Future<void> playKill() async {
    if (!_soundEnabled) return;

    // await _sfxPlayer.play(AssetSource('sounds/kill.mp3'));
    _playHaptic(HapticPattern.success);
  }

  /// Level up
  Future<void> playLevelUp() async {
    if (!_soundEnabled) return;

    // await _sfxPlayer.play(AssetSource('sounds/levelup.mp3'));
    _playHaptic(HapticPattern.success);
  }

  /// Tugma bosilganda
  Future<void> playButtonClick() async {
    if (!_soundEnabled) return;

    // await _sfxPlayer.play(AssetSource('sounds/button.mp3'));
    _playHaptic(HapticPattern.selection);
  }

  // ==================== MUSIC ====================

  /// Fon musiqasi
  Future<void> playBackgroundMusic() async {
    if (!_musicEnabled) return;

    // await _musicPlayer.play(
    //   AssetSource('music/background.mp3'),
    //   volume: _musicVolume,
    // );
    // await _musicPlayer.setReleaseMode(ReleaseMode.loop);
  }

  /// Musiqani to'xtatish
  Future<void> stopMusic() async {
    // await _musicPlayer.stop();
  }

  /// Musiqani pauza qilish
  Future<void> pauseMusic() async {
    // await _musicPlayer.pause();
  }

  /// Musiqani davom ettirish
  Future<void> resumeMusic() async {
    if (!_musicEnabled) return;
    // await _musicPlayer.resume();
  }

  // ==================== HAPTIC FEEDBACK ====================

  void _playHaptic(HapticPattern pattern) {
    switch (pattern) {
      case HapticPattern.light:
        HapticFeedback.lightImpact();
        break;
      case HapticPattern.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticPattern.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticPattern.selection:
        HapticFeedback.selectionClick();
        break;
      case HapticPattern.success:
        HapticFeedback.mediumImpact();
        Future.delayed(const Duration(milliseconds: 100), () {
          HapticFeedback.lightImpact();
        });
        break;
    }
  }

  // ==================== CLEANUP ====================

  Future<void> dispose() async {
    // await _sfxPlayer.dispose();
    // await _musicPlayer.dispose();
    super.dispose();
  }
}

// ==================== ENUMS ====================

enum HapticPattern {
  light,
  medium,
  heavy,
  selection,
  success,
}

// ==================== SOUND ASSETS ====================

/// Audio fayllar ro'yxati (kelajakda pubspec.yaml'ga qo'shiladi)
class SoundAssets {
  // Sound Effects
  static const foodEat = 'sounds/food_eat.mp3';
  static const death = 'sounds/death.mp3';
  static const powerUp = 'sounds/powerup.mp3';
  static const kill = 'sounds/kill.mp3';
  static const levelUp = 'sounds/levelup.mp3';
  static const button = 'sounds/button.mp3';
  static const collision = 'sounds/collision.mp3';

  // Music
  static const backgroundMusic = 'music/background.mp3';
  static const menuMusic = 'music/menu.mp3';

  // Ro'yxat
  static const List<String> allAssets = [
    foodEat,
    death,
    powerUp,
    kill,
    levelUp,
    button,
    collision,
    backgroundMusic,
    menuMusic,
  ];
}

/*
pubspec.yaml ga qo'shish kerak:

dependencies:
  audioplayers: ^5.0.0

flutter:
  assets:
    - assets/sounds/
    - assets/music/
*/