import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
// MUHIM: Rectangle klassi mana shu experimental paket ichida
import 'package:flame/experimental.dart';
import 'package:flutter/cupertino.dart';
import 'package:snake_rush/utils/services/storage/storage_service.dart';
import '../utils/services/service_locator.dart';

import 'config/game_constants.dart';
import 'components/game_map.dart';
import 'components/snake.dart';
import 'components/game_joystick.dart';
import 'components/mini_map.dart';
import 'components/food_manager.dart';
import 'components/score_display.dart'; // Buni ham qo'shdik

class HungrySnakeGame extends FlameGame with PanDetector {
  late GameMap _gameMap;
  late Snake _snake;
  late FoodManager _foodManager;
  late MiniMap _miniMap;
  late ScoreDisplay _scoreDisplay;

  GameJoystick? _joystick;
  bool _useJoystick = true;
  String _side = 'left';

  @override
  Future<void> onLoad() async {
    final storage = getIt<StorageService>();
    _useJoystick = storage.joystickEnabled;
    _side = storage.joystickSide;

    // 1. Dunyoni (Map) sozlash
    _gameMap = GameMap();
    await world.add(_gameMap);

    // 2. Managerlarni sozlash
    _foodManager = FoodManager(map: _gameMap);
    await world.add(_foodManager);

    // 3. Snake (Ilon)
    _snake = Snake(map: _gameMap, foodManager: _foodManager);
    await world.add(_snake);

    // 4. Camera Setup
    // TO'G'IRLANDI: Rectangle.fromLTWH ishlatish uchun Flame'ning experimental kutubxonasi kuchi ishlatiladi
    camera.setBounds(
      Rectangle.fromLTWH(0, 0, GameConstants.mapWidth, GameConstants.mapHeight),
    );

    camera.follow(_snake);
    // GameConstants'da bu qiymat baseCameraZoom deb nomlangan bo'lishi kerak
    camera.viewfinder.zoom = GameConstants.baseCameraZoom;

    _setupUI();
  }

  void _setupUI() {
    // Eskilarini tozalash (updateSettings chaqirilganda kerak bo'ladi)
    _joystick?.removeFromParent();

    // Joystickni viewportga qo'shish
    if (_useJoystick) {
      final margin = _side == 'left'
          ? const EdgeInsets.only(left: 45, bottom: 45)
          : const EdgeInsets.only(right: 45, bottom: 45);

      _joystick = GameJoystick(margin: margin);
      camera.viewport.add(_joystick!);
    }

    // MiniMapni viewportga qo'shish (Ilon bilan birga yurishi uchun emas, ekranda turishi uchun)
    _miniMap = MiniMap(player: _snake);
    camera.viewport.add(_miniMap);

    // ScoreDisplay (Statistika va Leaderboard)ni qo'shish
    _scoreDisplay = ScoreDisplay(player: _snake);
    camera.viewport.add(_scoreDisplay);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Joystick harakatini boshqarish
    if (_useJoystick && _joystick != null && _joystick!.direction != JoystickDirection.idle) {
      _snake.targetDirection = _joystick!.relativeDelta;
    }
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    // Agar joystick o'chirilgan bo'lsa, ekran surish orqali boshqarish
    if (!_useJoystick) {
      _snake.targetDirection = info.delta.global.normalized();
    }
  }

  void updateSettings() {
    // Sozlamalar o'zgarganda UI'ni qayta yuklash
    final storage = getIt<StorageService>();
    if (storage.joystickEnabled != _useJoystick || storage.joystickSide != _side) {
      _useJoystick = storage.joystickEnabled;
      _side = storage.joystickSide;

      // Viewportdagi eski UI elementlarini o'chirib, qayta qo'shish
      camera.viewport.children.whereType<GameJoystick>().forEach((c) => c.removeFromParent());
      camera.viewport.children.whereType<MiniMap>().forEach((c) => c.removeFromParent());
      camera.viewport.children.whereType<ScoreDisplay>().forEach((c) => c.removeFromParent());

      _setupUI();
    }
  }
}