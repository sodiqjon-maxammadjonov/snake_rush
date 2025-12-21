import 'dart:math' as dart_math;

import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/cupertino.dart';

import 'config/game_constants.dart';
import 'core/game_state.dart';
import 'world/game_map.dart';
import 'entities/snake/snake.dart';
import 'entities/food/food_manager.dart';
import 'entities/powerup/powerup_manager.dart';
import 'entities/bot/bot_snake.dart';
import 'ui/components/game_joystick.dart';
import 'ui/components/mini_map.dart';
import 'ui/components/score_display.dart';
import 'managers/camera_manager.dart';
import 'managers/collision_manager.dart';
import 'vfx/particle_system.dart';
import 'audio/sound_manager.dart';
import '../utils/services/service_locator.dart';
import '../utils/services/storage/storage_service.dart';

class HungrySnakeGame extends FlameGame with PanDetector {
  late final GameState gameState;
  late final SoundManager soundManager;
  late final ParticleSystem particleSystem;

  late GameMap _gameMap;
  late Snake _playerSnake;
  late FoodManager _foodManager;
  late PowerUpManager _powerUpManager;
  late CollisionManager _collisionManager;
  late CameraManager _cameraManager;

  final List<BotSnake> _bots = [];
  final int _maxBots = 10;

  late MiniMap _miniMap;
  late ScoreDisplay _scoreDisplay;
  GameJoystick? _joystick;

  late final StorageService _storage;
  bool _useJoystick = true;
  String _joystickSide = 'left';

  Function()? onGameOver;

  @override
  Future<void> onLoad() async {
    await _initializeSystems();
    await _loadSettings();
    await _initializeWorld();
    await _initializeUI();
    await _spawnBots();

    gameState.startGame();
  }

  Future<void> _initializeSystems() async {
    gameState = GameState();
    soundManager = SoundManager();
    await soundManager.initialize();

    particleSystem = ParticleSystem();
    await world.add(particleSystem);
  }

  Future<void> _loadSettings() async {
    _storage = getIt<StorageService>();
    _useJoystick = _storage.joystickEnabled;
    _joystickSide = _storage.joystickSide;
  }

  Future<void> _initializeWorld() async {
    _gameMap = GameMap();
    await world.add(_gameMap);

    _collisionManager = CollisionManager();
    _collisionManager.onSnakeCollision = _handleSnakeCollision;
    _collisionManager.onFoodCollision = _handleFoodCollision;
    await world.add(_collisionManager);

    _foodManager = FoodManager(map: _gameMap, collisionManager: _collisionManager);
    _foodManager.onFoodEaten = (points) {
      gameState.incrementFoodEaten();
      soundManager.playFoodEat();
    };
    await world.add(_foodManager);

    _powerUpManager = PowerUpManager(map: _gameMap);
    _powerUpManager.onPowerUpCollected = _handlePowerUpCollected;
    await world.add(_powerUpManager);

    _playerSnake = Snake(
      map: _gameMap,
      foodManager: _foodManager,
      isPlayer: true,
    );
    await world.add(_playerSnake);
    _collisionManager.registerSnake(_playerSnake);

    _cameraManager = CameraManager(camera);
    _cameraManager.setupBounds();
    _cameraManager.followTarget(_playerSnake);
    _cameraManager.setInitialZoom();
  }

  Future<void> _initializeUI() async {
    if (_useJoystick) {
      _createJoystick();
    }

    _miniMap = MiniMap(player: _playerSnake);
    camera.viewport.add(_miniMap);

    _scoreDisplay = ScoreDisplay(player: _playerSnake);
    camera.viewport.add(_scoreDisplay);
  }

  void _createJoystick() {
    final margin = _joystickSide == 'left'
        ? const EdgeInsets.only(left: 45, bottom: 45)
        : const EdgeInsets.only(right: 45, bottom: 45);

    _joystick = GameJoystick(margin: margin);
    camera.viewport.add(_joystick!);
  }

  Future<void> _spawnBots() async {
    for (int i = 0; i < _maxBots; i++) {
      await _spawnBot();
    }
  }

  Future<void> _spawnBot() async {
    final bot = BotSnake(
      map: _gameMap,
      foodManager: _foodManager,
      collisionManager: _collisionManager,
      difficulty: _getRandomDifficulty(),
    );

    await world.add(bot);
    _bots.add(bot);
    _collisionManager.registerSnake(bot);
  }

  BotDifficulty _getRandomDifficulty() {
    final rand = dart_math.Random().nextDouble();
    if (rand < 0.5) return BotDifficulty.easy;
    if (rand < 0.85) return BotDifficulty.medium;
    return BotDifficulty.hard;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!gameState.isPlaying) return;

    if (_useJoystick &&
        _joystick != null &&
        _joystick!.direction != JoystickDirection.idle) {
      _playerSnake.targetDirection = _joystick!.relativeDelta;
    }

    _powerUpManager.checkPowerUpCollisions(_playerSnake, dt);

    gameState.updatePlayTime(dt);
    gameState.updateMaxLength(_playerSnake.currentLength);

    _respawnBotsIfNeeded();
  }

  void _respawnBotsIfNeeded() {
    if (_bots.length < _maxBots) {
    }
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (!_useJoystick && gameState.isPlaying) {
      _playerSnake.targetDirection = info.delta.global.normalized();
    }
  }

  void _handleSnakeCollision(Snake attacker, Snake victim) {
    particleSystem.spawnDeathEffect(
      victim.position,
      victim.currentRadius,
      const Color(0xFFFF5722),
    );

    soundManager.playKill();

    if (attacker == _playerSnake) {
      gameState.incrementKills();
    }

    if (victim == _playerSnake) {
      _handlePlayerDeath();
    } else if (victim is BotSnake) {
      _spawnFoodAtPosition(victim.position, victim.totalScore);
      _bots.remove(victim);
      _collisionManager.unregisterSnake(victim);
    }
  }

  void _spawnFoodAtPosition(Vector2 position, int scoreAmount) {
    final foodCount = (scoreAmount / 10).clamp(5, 50).toInt();
    _foodManager.spawnFoodCluster(position, foodCount);
  }

  void _handleFoodCollision(Snake snake, food) {
    particleSystem.spawnFoodEatEffect(
      food.position,
      food.type.color,
    );
  }

  void _handlePowerUpCollected(Snake snake, type) {
    particleSystem.spawnPowerUpEffect(
      snake.position,
      type.color,
    );

    soundManager.playPowerUp();
  }

  void _handlePlayerDeath() {
    gameState.endGame(
      finalScore: _playerSnake.totalScore,
      finalLength: _playerSnake.currentLength,
    );

    soundManager.playDeath();

    onGameOver?.call();
  }

  void updateSettings() {
    final newJoystickState = _storage.joystickEnabled;
    final newSide = _storage.joystickSide;

    if (newJoystickState != _useJoystick || newSide != _joystickSide) {
      _useJoystick = newJoystickState;
      _joystickSide = newSide;

      _clearUI();
      _initializeUI();
    }
  }

  void _clearUI() {
    camera.viewport.children
        .whereType<GameJoystick>()
        .forEach((c) => c.removeFromParent());
    camera.viewport.children
        .whereType<MiniMap>()
        .forEach((c) => c.removeFromParent());
    camera.viewport.children
        .whereType<ScoreDisplay>()
        .forEach((c) => c.removeFromParent());
  }

  void restart() {
    _playerSnake.removeFromParent();
    for (final bot in _bots) {
      bot.removeFromParent();
    }
    _bots.clear();

    _foodManager.clearAll();
    _powerUpManager.clearAll();
    _collisionManager.clear();
    particleSystem.clear();

    onLoad();
  }

  void revivePlayer() {
    _playerSnake.position = Vector2(
      GameConstants.mapWidth / 2,
      GameConstants.mapHeight / 2,
    );

    gameState.startGame();
  }

  Snake get playerSnake => _playerSnake;
  FoodManager get foodManager => _foodManager;
  PowerUpManager get powerUpManager => _powerUpManager;
  List<BotSnake> get bots => List.unmodifiable(_bots);
}