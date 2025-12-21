import 'dart:ui';
import 'package:flame/components.dart';
import '../config/game_constants.dart';

/// O'yin xaritasi - fon va grid
class GameMap extends PositionComponent with HasGameRef {
  late final Paint _bgPaint;
  late final Paint _gridPaint;
  late final Paint _borderPaint;
  late final Rect _mapRect;

  @override
  Future<void> onLoad() async {
    size = Vector2(GameConstants.mapWidth, GameConstants.mapHeight);
    priority = -100;

    _initializePaints();
    _mapRect = Rect.fromLTWH(0, 0, width, height);
  }

  void _initializePaints() {
    _bgPaint = Paint()
      ..color = GameConstants.mapBackground
      ..style = PaintingStyle.fill;

    _gridPaint = Paint()
      ..color = GameConstants.mapGrid
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    _borderPaint = Paint()
      ..color = GameConstants.mapBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0;
  }

  @override
  void render(Canvas canvas) {
    // Fon
    canvas.drawRect(_mapRect, _bgPaint);

    // Grid (faqat ko'ringan qismni chizish - performance uchun)
    _renderVisibleGrid(canvas);

    // Chegara
    canvas.drawRect(_mapRect, _borderPaint);
  }

  /// Faqat ko'rinayotgan grid chiziqlarini render qilish
  void _renderVisibleGrid(Canvas canvas) {
    final visible = gameRef.camera.visibleWorldRect;
    final gridSize = GameConstants.gridSize;

    // Ko'rinayotgan hudud chegaralari
    final startX = (visible.left / gridSize).floor() * gridSize;
    final endX = (visible.right / gridSize).ceil() * gridSize;
    final startY = (visible.top / gridSize).floor() * gridSize;
    final endY = (visible.bottom / gridSize).ceil() * gridSize;

    // Xarita chegaralarida cheklash
    final left = startX.clamp(0.0, width);
    final right = endX.clamp(0.0, width);
    final top = startY.clamp(0.0, height);
    final bottom = endY.clamp(0.0, height);

    // Vertikal chiziqlar
    for (double x = left; x <= right; x += gridSize) {
      canvas.drawLine(
        Offset(x, top),
        Offset(x, bottom),
        _gridPaint,
      );
    }

    // Gorizontal chiziqlar
    for (double y = top; y <= bottom; y += gridSize) {
      canvas.drawLine(
        Offset(left, y),
        Offset(right, y),
        _gridPaint,
      );
    }
  }
}