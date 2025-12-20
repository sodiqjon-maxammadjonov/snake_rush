import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/cupertino.dart';
import 'package:snake_rush/utils/services/storage/storage_service.dart';
import '../utils/services/service_locator.dart';

import 'config/game_constants.dart';
import 'components/game_map.dart';
import 'components/snake.dart';
import 'components/game_joystick.dart';
import 'components/mini_map.dart';

class HungrySnakeGame extends FlameGame with PanDetector {
  late GameMap _gameMap;
  late Snake _snake;
  late MiniMap _miniMap;

  GameJoystick? _joystick;
  bool _isResourcesLoaded = false;
  bool _useJoystick = true;
  String _side = 'left';

  @override
  Future<void> onLoad() async {
    final storage = getIt<StorageService>();
    _useJoystick = storage.joystickEnabled;
    _side = storage.joystickSide;

    // 1. Dunyoni sozlash
    _gameMap = GameMap();
    await world.add(_gameMap);

    _snake = Snake(map: _gameMap);
    await world.add(_snake);

    // 2. Kamerani ilonga bog'lash
    camera.setBounds(
      Rectangle.fromLTWH(0, 0, GameConstants.mapWidth, GameConstants.mapHeight),
    );
    camera.follow(_snake);
    camera.viewfinder.zoom = GameConstants.cameraZoom;

    // 3. UI va Joystick
    _setupJoystickAndUI();
    _isResourcesLoaded = true;
  }

  void _setupJoystickAndUI() {
    _joystick?.removeFromParent();

    if (_useJoystick) {
      final margin = _side == 'left'
          ? const EdgeInsets.only(left: 40, bottom: 40)
          : const EdgeInsets.only(right: 40, bottom: 40);

      _joystick = GameJoystick(margin: margin);
      camera.viewport.add(_joystick!);
    }

    // MiniMapni viewportga qo'shamiz (ekran siljisa ham o'rnida turishi uchun)
    _miniMap = MiniMap(player: _snake);
    camera.viewport.add(_miniMap);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_useJoystick && _joystick != null) {
      if (_joystick!.direction != JoystickDirection.idle) {
        // ILONNING YO'NALISHINI EMAS, NISHONINI BELGILAYMIZ
        _snake.targetDirection = _joystick!.relativeDelta;
      }
    }
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (_useJoystick) return;

    // Joystick yo'q bo'lganda ekran bo'ylab surish orqali boshqarish
    if (info.delta.global.length2 > 0) {
      _snake.targetDirection = info.delta.global.normalized();
    }
  }

  @override
  void render(Canvas canvas) {
    if (!_isResourcesLoaded) {
      _drawLoadingText(canvas);
      return;
    }
    super.render(canvas);
  }

  void _drawLoadingText(Canvas canvas) {
    final textPainter = TextPaint(
      style: const TextStyle(color: CupertinoColors.white, fontSize: 24),
    );
    textPainter.render(canvas, "LOADING...", Vector2(size.x/2 - 60, size.y/2));
  }

  void updateSettings() {
    final storage = getIt<StorageService>();
    if (storage.joystickEnabled != _useJoystick || storage.joystickSide != _side) {
      _useJoystick = storage.joystickEnabled;
      _side = storage.joystickSide;
      _setupJoystickAndUI();
    }
  }
}