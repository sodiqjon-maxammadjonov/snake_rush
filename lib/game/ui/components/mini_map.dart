import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../config/game_constants.dart';
import '../../entities/snake/snake.dart';

/// Mini xarita komponenti - o'yinchi pozitsiyasini ko'rsatadi
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
    position = Vector2(
      GameConstants.miniMapMargin,
      GameConstants.miniMapMargin,
    );

    _initializePaints();
  }

  void _initializePaints() {
    _bgPaint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    _borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    _playerDotPaint = Paint()..color = GameConstants.snakeColor;
  }

  @override
  void render(Canvas canvas) {
    // Fon
    canvas.drawRect(size.toRect(), _bgPaint);

    // Chegara
    canvas.drawRect(size.toRect(), _borderPaint);

    // O'yinchi pozitsiyasi
    _renderPlayerDot(canvas);
  }

  void _renderPlayerDot(Canvas canvas) {
    // Xarita koordinatalarini mini-mapga moslashtirish
    final relativeX = player.position.x / GameConstants.mapWidth;
    final relativeY = player.position.y / GameConstants.mapHeight;

    double dotX = relativeX * width;
    double dotY = relativeY * height;

    // Chegaralar ichida ushlab turish
    dotX = dotX.clamp(0, width);
    dotY = dotY.clamp(0, height);

    // Nuqtani chizish
    canvas.drawCircle(Offset(dotX, dotY), 4, _playerDotPaint);

    // Yo'nalish ko'rsatkichi (ixtiyoriy)
    _renderDirectionIndicator(canvas, dotX, dotY);
  }

  void _renderDirectionIndicator(Canvas canvas, double x, double y) {
    final direction = player.direction.normalized();
    final endX = x + direction.x * 8;
    final endY = y + direction.y * 8;

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(x, y), Offset(endX, endY), linePaint);
  }
}