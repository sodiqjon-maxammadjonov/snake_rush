import 'package:flutter/foundation.dart';

enum GameStatus {
  loading,
  ready,
  playing,
  paused,
  gameOver,
  victory,
}

class GameState extends ChangeNotifier {
  GameStatus _status = GameStatus.loading;
  int _currentLevel = 1;
  int _highScore = 0;
  double _playTime = 0.0;

  int _totalFoodEaten = 0;
  int _totalKills = 0;
  int _maxLength = 0;

  DateTime? _sessionStartTime;

  GameStatus get status => _status;
  int get currentLevel => _currentLevel;
  int get highScore => _highScore;
  double get playTime => _playTime;
  int get totalFoodEaten => _totalFoodEaten;
  int get totalKills => _totalKills;
  int get maxLength => _maxLength;

  bool get isPlaying => _status == GameStatus.playing;
  bool get isPaused => _status == GameStatus.paused;
  bool get isGameOver => _status == GameStatus.gameOver;


  void startGame() {
    _status = GameStatus.playing;
    _sessionStartTime = DateTime.now();
    _playTime = 0.0;
    _totalFoodEaten = 0;
    _totalKills = 0;
    notifyListeners();
  }

  void pauseGame() {
    if (_status == GameStatus.playing) {
      _status = GameStatus.paused;
      notifyListeners();
    }
  }

  void resumeGame() {
    if (_status == GameStatus.paused) {
      _status = GameStatus.playing;
      notifyListeners();
    }
  }

  void endGame({required int finalScore, required int finalLength}) {
    _status = GameStatus.gameOver;

    if (finalScore > _highScore) {
      _highScore = finalScore;
    }

    if (finalLength > _maxLength) {
      _maxLength = finalLength;
    }

    notifyListeners();
  }

  void resetGame() {
    _status = GameStatus.ready;
    _playTime = 0.0;
    _sessionStartTime = null;
    notifyListeners();
  }


  void incrementFoodEaten() {
    _totalFoodEaten++;
    notifyListeners();
  }

  void incrementKills() {
    _totalKills++;
    notifyListeners();
  }

  void updatePlayTime(double dt) {
    if (_status == GameStatus.playing) {
      _playTime += dt;
    }
  }

  void updateMaxLength(int length) {
    if (length > _maxLength) {
      _maxLength = length;
      notifyListeners();
    }
  }


  void levelUp() {
    _currentLevel++;
    notifyListeners();
  }

  void setLevel(int level) {
    _currentLevel = level;
    notifyListeners();
  }


  Map<String, dynamic> toMap() {
    return {
      'highScore': _highScore,
      'currentLevel': _currentLevel,
      'maxLength': _maxLength,
      'totalFoodEaten': _totalFoodEaten,
      'totalKills': _totalKills,
      'totalPlayTime': _playTime,
    };
  }

  void fromMap(Map<String, dynamic> map) {
    _highScore = map['highScore'] ?? 0;
    _currentLevel = map['currentLevel'] ?? 1;
    _maxLength = map['maxLength'] ?? 0;
    _totalFoodEaten = map['totalFoodEaten'] ?? 0;
    _totalKills = map['totalKills'] ?? 0;
    _playTime = map['totalPlayTime'] ?? 0.0;
    notifyListeners();
  }


  @override
  String toString() {
    return 'GameState(status: $_status, level: $_currentLevel, score: $_highScore)';
  }
}