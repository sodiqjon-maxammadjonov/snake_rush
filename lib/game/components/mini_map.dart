import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../config/game_constants.dart';
import 'snake.dart';

class MiniMap extends PositionComponent {
  final Snake player;
  late final Paint _bgPaint;
  late final Paint _playerDotPaint;
  late final Paint _borderPaint;

  MiniMap({required this.player}) {
    priority = 20;
  }

  @override
  Future<void> onLoad() async {
    size = Vector2.all(GameConstants.miniMapSize);
    position = Vector2(GameConstants.miniMapMargin, GameConstants.miniMapMargin);

    _bgPaint = Paint()..color = Colors.black.withOpacity(0.6)..style = PaintingStyle.fill;
    _borderPaint = Paint()..color = Colors.white.withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 2;
    _playerDotPaint = Paint()..color = GameConstants.snakeColor;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), _bgPaint);
    canvas.drawRect(size.toRect(), _borderPaint);

    double px = (player.position.x / GameConstants.mapWidth) * width;
    double py = (player.position.y / GameConstants.mapHeight) * height;

    px = px.clamp(0, width);
    py = py.clamp(0, height);

    canvas.drawCircle(Offset(px, py), 4, _playerDotPaint);
  }
}