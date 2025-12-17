import 'package:flame_audio/flame_audio.dart';
import '../storage/storage_service.dart';

/// Audio Manager - Xavfsiz versiya (fayllar yo'q bo'lsa ham crash qilmaydi)
class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final _storage = StorageService();

  double _musicVolume = 0.5;
  double _gameVolume = 0.7;
  bool _isMusicPlaying = false;
  bool _isGameMusicPlaying = false;
  bool _audioEnabled = false; // Audio mavjudmi?

  double get musicVolume => _musicVolume;
  double get gameVolume => _gameVolume;
  bool get isMusicPlaying => _isMusicPlaying;
  bool get isAudioEnabled => _audioEnabled;

  Future<void> init() async {
    try {
      // Audio fayllarni yuklab ko'rish
      await FlameAudio.audioCache.loadAll([
        'music/background.mp3',
        'sounds/eat.mp3',
        'sounds/game_over.mp3',
        'sounds/button_click.mp3',
      ]);

      _musicVolume = _storage.musicVolume;
      _gameVolume = _storage.gameVolume;
      _audioEnabled = true;

      print('✅ Audio successfully loaded');
    } catch (e) {
      // Agar audio yo'q bo'lsa, xato bermaydi
      _audioEnabled = false;
      print('⚠️ Audio files not found, continuing without audio: $e');
    }
  }

  // ✅ Main menu musiqasi
  Future<void> playBackgroundMusic() async {
    if (!_audioEnabled) return;

    try {
      if (!_isMusicPlaying) {
        await FlameAudio.bgm.stop();
        await FlameAudio.bgm.play('music/background.mp3', volume: _musicVolume);
        _isMusicPlaying = true;
        _isGameMusicPlaying = false;
      }
    } catch (e) {
      print('⚠️ Failed to play background music: $e');
    }
  }

  // ✅ Game musiqasi
  Future<void> playGameMusic() async {
    if (!_audioEnabled) return;

    try {
      // Hozircha background music davom etadi
      _isGameMusicPlaying = true;
    } catch (e) {
      print('⚠️ Failed to play game music: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    if (!_audioEnabled) return;

    try {
      await FlameAudio.bgm.stop();
      _isMusicPlaying = false;
      _isGameMusicPlaying = false;
    } catch (e) {
      print('⚠️ Failed to stop music: $e');
    }
  }

  Future<void> pauseBackgroundMusic() async {
    if (!_audioEnabled) return;

    try {
      await FlameAudio.bgm.pause();
    } catch (e) {
      print('⚠️ Failed to pause music: $e');
    }
  }

  Future<void> resumeBackgroundMusic() async {
    if (!_audioEnabled) return;

    try {
      await FlameAudio.bgm.resume();
    } catch (e) {
      print('⚠️ Failed to resume music: $e');
    }
  }

  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0);

    if (_audioEnabled) {
      try {
        FlameAudio.bgm.audioPlayer.setVolume(_musicVolume);
      } catch (e) {
        print('⚠️ Failed to set volume: $e');
      }
    }

    await _storage.setMusicVolume(_musicVolume);
  }

  Future<void> setGameVolume(double volume) async {
    _gameVolume = volume.clamp(0.0, 1.0);
    await _storage.setGameVolume(_gameVolume);
  }

  Future<void> playSound(String sound, {double volumeMultiplier = 1.0}) async {
    if (!_audioEnabled) return;

    try {
      final adjustedVolume = (_gameVolume * volumeMultiplier).clamp(0.0, 1.0);
      await FlameAudio.play(sound, volume: adjustedVolume);
    } catch (e) {
      print('⚠️ Failed to play sound $sound: $e');
    }
  }

  Future<void> playEatSound() => playSound('sounds/eat.mp3');
  Future<void> playGameOverSound() => playSound('sounds/game_over.mp3');
  Future<void> playButtonClick() => playSound('sounds/button_click.mp3');

  Future<void> dispose() async {
    if (!_audioEnabled) return;

    try {
      await FlameAudio.bgm.stop();
      await FlameAudio.bgm.dispose();
      _isMusicPlaying = false;
      _isGameMusicPlaying = false;
    } catch (e) {
      print('⚠️ Failed to dispose audio: $e');
    }
  }
}