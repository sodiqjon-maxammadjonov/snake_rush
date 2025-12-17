import 'package:flame/components.dart';
import '../config/game_constants.dart';
import 'snake.dart';

/// Kamera boshqaruvi uchun controller
class GameCameraController {
  late final CameraComponent camera;
  double _currentZoom = GameConstants.cameraInitialZoom;

  GameCameraController({required World world}) {
    camera = CameraComponent(world: world);
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.zoom = _currentZoom;
  }

  /// Kamerani ilonga qaratish
  void followSnake(Snake snake) {
    camera.follow(snake);
  }

  /// Zoom qilish
  void zoom(double scale) {
    _currentZoom = (_currentZoom * scale).clamp(
      GameConstants.cameraMinZoom,
      GameConstants.cameraMaxZoom,
    );
    camera.viewfinder.zoom = _currentZoom;
  }

  /// Zoom darajasini o'rnatish
  void setZoom(double value) {
    _currentZoom = value.clamp(
      GameConstants.cameraMinZoom,
      GameConstants.cameraMaxZoom,
    );
    camera.viewfinder.zoom = _currentZoom;
  }

  /// Hozirgi zoom darajasini olish
  double get currentZoom => _currentZoom;

  /// Kamerani reset qilish
  void reset() {
    _currentZoom = GameConstants.cameraInitialZoom;
    camera.viewfinder.zoom = _currentZoom;
  }

  /// Kamerani ma'lum pozitsiyaga o'tkazish (smooth)
  void moveTo(Vector2 position, {double duration = 1.0}) {
    camera.moveTo(position);
  }

  /// Kamera harakatini to'xtatish
  void stopFollow() {
    camera.stop();
  }
}