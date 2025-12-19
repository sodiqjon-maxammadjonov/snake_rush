import 'dart:ui';
import 'package:flame/components.dart';
import '../config/game_constants.dart';

class GameMap extends PositionComponent with HasGameRef {
  late final Paint _bgPaint;
  late final Paint _gridPaint;
  late final Paint _borderPaint;
  late final Rect _mapRect;

  @override
  Future<void> onLoad() async {
    size = Vector2(GameConstants.mapWidth, GameConstants.mapHeight);
    priority = -100;

    _bgPaint = Paint()..color = GameConstants.mapBackground..style = PaintingStyle.fill;
    _gridPaint = Paint()..color = GameConstants.mapGrid..style = PaintingStyle.stroke..strokeWidth = 1.0;
    _borderPaint = Paint()..color = GameConstants.mapBorder..style = PaintingStyle.stroke..strokeWidth = 10.0;

    _mapRect = Rect.fromLTWH(0, 0, width, height);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(_mapRect, _bgPaint);

    _renderVisibleGrid(canvas);

    canvas.drawRect(_mapRect, _borderPaint);
  }

  void _renderVisibleGrid(Canvas canvas) {
    final visible = gameRef.camera.visibleWorldRect;
    final grid = GameConstants.gridSize;

    final double startX = (visible.left / grid).floor() * grid;
    final double endX = (visible.right / grid).ceil() * grid;
    final double startY = (visible.top / grid).floor() * grid;
    final double endY = (visible.bottom / grid).ceil() * grid;

    final left = startX.clamp(0.0, width);
    final right = endX.clamp(0.0, width);
    final top = startY.clamp(0.0, height);
    final bottom = endY.clamp(0.0, height);

    for (double x = left; x <= right; x += grid) {
      canvas.drawLine(Offset(x, top), Offset(x, bottom), _gridPaint);
    }
    for (double y = top; y <= bottom; y += grid) {
      canvas.drawLine(Offset(left, y), Offset(right, y), _gridPaint);
    }
  }
}