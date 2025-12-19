import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
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

  Vector2 _touchDirection = Vector2.zero();

  @override
  Future<void> onLoad() async {
    final storage = getIt<StorageService>();
    _useJoystick = storage.joystickEnabled;
    _side = storage.joystickSide;

    _gameMap = GameMap();
    await world.add(_gameMap);

    _snake = Snake(map: _gameMap);
    await world.add(_snake);

    camera.setBounds(
      Rectangle.fromLTWH(0, 0, GameConstants.mapWidth, GameConstants.mapHeight),
    );
    camera.follow(_snake);
    camera.viewfinder.zoom = GameConstants.cameraZoom;

    _setupJoystickAndUI();
    _isResourcesLoaded = true;
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
    textPainter.render(canvas, "LOADING...", Vector2(size.x/2 - 50, size.y/2));
  }

  void _setupJoystickAndUI() {
    if (_joystick != null) {
      if (_joystick!.parent != null) {
        _joystick!.removeFromParent();
      }
      _joystick = null;
    }

    if (_useJoystick) {
      EdgeInsets margin;

      if (_side == 'left') {
        margin = const EdgeInsets.only(left: 40, bottom: 40);
      } else {
        margin = const EdgeInsets.only(right: 40, bottom: 40);
      }

      _joystick = GameJoystick(margin: margin);
      camera.viewport.add(_joystick!);
    }

   try {
      bool miniMapExists = camera.viewport.children.any((c) => c is MiniMap);
      if (!miniMapExists) {
        _miniMap = MiniMap(player: _snake);
        camera.viewport.add(_miniMap);
      }
    } catch(e) {
      // ignore initialization error if first run
    }
  }

  void updateSettings() {
    final storage = getIt<StorageService>();
    bool newUse = storage.joystickEnabled;
    String newSide = storage.joystickSide;

    if (newUse != _useJoystick || newSide != _side) {
      _useJoystick = newUse;
      _side = newSide;
      _setupJoystickAndUI();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_useJoystick && _joystick != null) {
      if (_joystick!.direction != JoystickDirection.idle) {
        _snake.direction = _joystick!.relativeDelta;
      }
    }
    else {
      if (!_touchDirection.isZero()) {
        _snake.direction = _touchDirection;
      }
    }
  }


  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (_useJoystick) return;

    if (info.delta.global.length2 > 0) {
      _touchDirection = info.delta.global.normalized();
    }
  }

  @override
  void onPanEnd(DragEndInfo info) {
    //just swim
  }
}