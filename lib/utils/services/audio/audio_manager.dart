import 'package:audioplayers/audioplayers.dart';
import '../storage/storage_service.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final _storage = StorageService();
  late final AudioPlayer _bgmPlayer;
  final List<AudioPlayer> _sfxPool = [];
  final int _poolSize = 4;
  int _poolIndex = 0;

  double _musicVolume = 0.5;
  double _gameVolume = 0.7;
  bool _isInitialized = false;

  double get musicVolume => _musicVolume;
  double get gameVolume => _gameVolume;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      await AudioPlayer.global.setAudioContext(AudioContext(
        android: const AudioContextAndroid(
          audioFocus: AndroidAudioFocus.none,
          usageType: AndroidUsageType.game,
          contentType: AndroidContentType.sonification,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {
            AVAudioSessionOptions.mixWithOthers,
            AVAudioSessionOptions.duckOthers,
          },
        ),
      ));

      _bgmPlayer = AudioPlayer();
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);

      for (int i = 0; i < _poolSize; i++) {
        _sfxPool.add(AudioPlayer());
      }

      _musicVolume = _storage.musicVolume;
      _gameVolume = _storage.gameVolume;

      _isInitialized = true;
      print('✅ AudioManager initialized and context set.');
    } catch (e) {
      print('❌ Audio Error: $e');
    }
  }

  void playBackgroundMusic() async {
    if (!_isInitialized) return;
    try {
      if (_bgmPlayer.state == PlayerState.playing) return;
      await _bgmPlayer.play(AssetSource('audio/music/background.mp3'), volume: _musicVolume);
    } catch (e) {
      print('⚠️ BGM play error: $e');
    }
  }

  void _playSfx(String path, {double mult = 1.0}) {
    if (!_isInitialized || _gameVolume <= 0) return;

    final player = _sfxPool[_poolIndex];
    _poolIndex = (_poolIndex + 1) % _poolSize;

    player.stop().then((_) {
      player.play(
          AssetSource(path),
          volume: (_gameVolume * mult).clamp(0.0, 1.0)
      );
    });
  }

  void playButtonClick() => _playSfx('audio/sounds/button_click.mp3');
  void playEatSound() => _playSfx('audio/sounds/eat.mp3', mult: 1.1);
  void playGameOverSound() => _playSfx('audio/sounds/game_over.mp3', mult: 1.2);

  void setMusicVolume(double vol) {
    _musicVolume = vol.clamp(0.0, 1.0);
    _bgmPlayer.setVolume(_musicVolume);
    _storage.setMusicVolume(_musicVolume);
  }

  void setGameVolume(double vol) {
    _gameVolume = vol.clamp(0.0, 1.0);
    _storage.setGameVolume(_gameVolume);
  }

  Future<void> dispose() async {
    await _bgmPlayer.dispose();
    for (var p in _sfxPool) {
      await p.dispose();
    }
    _isInitialized = false;
  }
}