import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import '../config/game_constants.dart';

/// Kamera boshqaruvchisi - smooth follow va zoom
class CameraManager {
  final CameraComponent camera;
  PositionComponent? _target;

  CameraManager(this.camera);

  /// Kamera chegaralarini o'rnatish
  void setupBounds() {
    camera.setBounds(
      Rectangle.fromLTWH(
        0,
        0,
        GameConstants.mapWidth,
        GameConstants.mapHeight,
      ),
    );
  }

  /// Maqsadni kuzatish
  void followTarget(PositionComponent target) {
    _target = target;
    camera.follow(target);
  }

  /// Boshlang'ich zoom
  void setInitialZoom() {
    camera.viewfinder.zoom = GameConstants.baseCameraZoom;
  }

  /// Smooth zoom yangilash
  void updateZoom(double targetZoom, double dt) {
    final currentZoom = camera.viewfinder.zoom;
    final zoomDelta = (targetZoom - currentZoom) *
        GameConstants.cameraZoomSpeed * dt;

    camera.viewfinder.zoom = (currentZoom + zoomDelta).clamp(
      GameConstants.minCameraZoom,
      GameConstants.maxCameraZoom,
    );
  }

  /// Kamera shake effekti (kelajakda)
  void shake({double intensity = 5.0, double duration = 0.3}) {
    // TODO: Kamera titrash effektini qo'shish
  }

  /// Maqsadni olish
  PositionComponent? get target => _target;
}