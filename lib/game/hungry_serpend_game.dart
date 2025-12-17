import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'components/game_camera.dart';
import 'components/game_joystick.dart';
import 'components/game_map.dart';
import 'components/mini_map.dart';
import 'components/snake.dart';
import 'config/game_constants.dart';

/// Asosiy o'yin klassi - Performance optimizatsiya qilingan
class HungrySerpentGame extends FlameGame with ScaleDetector {
  late final GameMap _gameMap;
  late final Snake _snake;
  late final MiniMap _miniMap;
  late final GameJoystick _joystick;
  late final GameCameraController _cameraController;

  // Getters
  GameMap get gameMap => _gameMap;
  Snake get snake => _snake;
  MiniMap get miniMap => _miniMap;
  GameJoystick get joystick => _joystick;
  GameCameraController get cameraController => _cameraController;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _initializeGame();
  }

  /// O'yinni boshlang'ich holatga o'rnatish
  Future<void> _initializeGame() async {
    _cameraController = GameCameraController(world: world);
    await add(_cameraController.camera);

    _gameMap = GameMap();
    await world.add(_gameMap);

    final startPosition = Vector2(
      GameConstants.mapWidth / 2,
      GameConstants.mapHeight / 2,
    );

    _snake = Snake(
      position: startPosition,
      gameMap: _gameMap,
    );
    await world.add(_snake);

    _cameraController.followSnake(_snake);

    _miniMap = MiniMap(
      mapSize: _gameMap.mapSize,
      snake: _snake,
    );
    await _cameraController.camera.viewport.add(_miniMap);

    _joystick = GameJoystick();
    await _cameraController.camera.viewport.add(_joystick.component);
  }


  @override
  void update(double dt) {
    super.update(dt);
    _updateSnakeMovement();
  }

  /// Ilonni joystick bilan harakatlantirish
  void _updateSnakeMovement() {
    if (!_joystick.isIdle && _snake.isAlive) {
      _snake.setDirection(_joystick.relativeDelta);
    }
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    final scale = info.scale.global;

    // Pinch to zoom
    if (scale.length != 1.0) {
      _cameraController.zoom(scale.length);
    }
  }

  /// O'yinni pause qilish
  void pauseGame() {
    pauseEngine();
    _snake.pause();
  }

  /// O'yinni davom ettirish
  void resumeGame() {
    resumeEngine();
    _snake.resume();
  }

  /// O'yinni qayta boshlash
  void resetGame() {
    final startPosition = Vector2(
      GameConstants.mapWidth / 2,
      GameConstants.mapHeight / 2,
    );

    _snake.reset(startPosition);
    _cameraController.reset();
  }

  /// FPS optimization
  @override
  int? get refreshRate => 60; // 60 FPS

  @override
  void onRemove() {
    // Tozalash
    super.onRemove();
  }
}