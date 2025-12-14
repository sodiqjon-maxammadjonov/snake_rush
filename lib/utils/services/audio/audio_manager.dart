import 'package:flame_audio/flame_audio.dart';
import '../storage/storage_service.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final _storage = StorageService();

  double _musicVolume = 0.5;
  double _gameVolume = 0.7;
  bool _isMusicPlaying = false;

  double get musicVolume => _musicVolume;
  double get gameVolume => _gameVolume;
  bool get isMusicPlaying => _isMusicPlaying;

  Future<void> init() async {
    await FlameAudio.audioCache.loadAll([
      'music/background.mp3',
      'sounds/eat.mp3',
      'sounds/game_over.mp3',
      'sounds/button_click.mp3',
    ]);

    _musicVolume = _storage.musicVolume;
    _gameVolume = _storage.gameVolume;
  }

  Future<void> playBackgroundMusic() async {
    if (!_isMusicPlaying) {
      await FlameAudio.bgm.play('music/background.mp3', volume: _musicVolume);
      _isMusicPlaying = true;
    }
  }

  Future<void> stopBackgroundMusic() async {
    await FlameAudio.bgm.stop();
    _isMusicPlaying = false;
  }

  Future<void> pauseBackgroundMusic() async {
    await FlameAudio.bgm.pause();
  }

  Future<void> resumeBackgroundMusic() async {
    await FlameAudio.bgm.resume();
  }

  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0);
    FlameAudio.bgm.audioPlayer.setVolume(_musicVolume);
    await _storage.setMusicVolume(_musicVolume);
  }

  Future<void> setGameVolume(double volume) async {
    _gameVolume = volume.clamp(0.0, 1.0);
    await _storage.setGameVolume(_gameVolume);
  }

  Future<void> playSound(String sound, {double volumeMultiplier = 1.0}) async {
    final adjustedVolume = (_gameVolume * volumeMultiplier).clamp(0.0, 1.0);
    await FlameAudio.play(sound, volume: adjustedVolume);
  }

  Future<void> playEatSound() => playSound('sounds/eat.mp3');
  Future<void> playGameOverSound() => playSound('sounds/game_over.mp3');
  Future<void> playButtonClick() => playSound('sounds/button_click.mp3');

  void dispose() {
    FlameAudio.bgm.dispose();
  }
}