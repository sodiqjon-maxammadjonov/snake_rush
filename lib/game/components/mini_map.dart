import 'dart:ui';
import 'package:flame/components.dart';
import '../config/game_constants.dart';
import 'snake.dart';

/// MiniMap komponenti - to'g'ri nisbat bilan
class MiniMap extends PositionComponent {
  final Vector2 _mapSize;
  final Snake _snake;

  late final Paint _backgroundPaint;
  late final Paint _borderPaint;
  late final Paint _mapBorderPaint;
  late final Paint _snakeDotPaint;

  Vector2 _snakePosition = Vector2.zero();
  double _opacity = 1.0;

  MiniMap({
    required Vector2 mapSize,
    required Snake snake,
  })  : _mapSize = mapSize,
        _snake = snake;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    size = Vector2.all(GameConstants.miniMapSize);
    position = Vector2(
      GameConstants.miniMapPadding,
      GameConstants.miniMapPadding,
    );
    anchor = Anchor.topLeft;
    priority = 10000;

    _initializePaints();
  }

  void _initializePaints() {
    _backgroundPaint = Paint()
      ..color = GameConstants.miniMapBackgroundColor
      ..style = PaintingStyle.fill;

    _borderPaint = Paint()
      ..color = GameConstants.miniMapBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = GameConstants.miniMapBorderWidth;

    _mapBorderPaint = Paint()
      ..color = GameConstants.mapBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    _snakeDotPaint = Paint()
      ..color = GameConstants.miniMapSnakeColor
      ..style = PaintingStyle.fill;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _snakePosition = _snake.position;
  }

  @override
  void render(Canvas canvas) {
    canvas.saveLayer(
      null,
      Paint()..color = const Color(0xFFFFFFFF).withOpacity(_opacity),
    );

    super.render(canvas);

    final center = Offset(
      GameConstants.miniMapSize / 2,
      GameConstants.miniMapSize / 2,
    );
    final radius = GameConstants.miniMapSize / 2;

    // 1. Doira fon
    canvas.drawCircle(center, radius, _backgroundPaint);

    // 2. ✅ TO'G'RI NISBAT: Kvadrat map ko'rinishi
    final innerSize = GameConstants.miniMapSize -
        (GameConstants.miniMapInnerPadding * 2);

    // ✅ MUHIM: Map kvadrat bo'lishi kerak
    final mapDisplaySize = innerSize * 0.7; // 70% doira ichida
    final mapOffset = (innerSize - mapDisplaySize) / 2 +
        GameConstants.miniMapInnerPadding;

    final mapRect = Rect.fromLTWH(
      mapOffset,
      mapOffset,
      mapDisplaySize,
      mapDisplaySize,
    );

    canvas.drawRect(mapRect, _mapBorderPaint);

    // 3. Ilon pozitsiyasi
    _renderSnakePosition(canvas, mapDisplaySize, mapOffset);

    // 4. Doira chegara
    canvas.drawCircle(center, radius, _borderPaint);

    canvas.restore();
  }

  void _renderSnakePosition(Canvas canvas, double mapDisplaySize, double offset) {
    // ✅ Map koordinatalarini minimap koordinatalariga to'g'ri o'zgartirish
    // Map hajmi: 5000x5000 -> MiniMap: mapDisplaySize x mapDisplaySize
    final scaleX = mapDisplaySize / _mapSize.x;
    final scaleY = mapDisplaySize / _mapSize.y;

    final snakeX = offset + (_snakePosition.x * scaleX);
    final snakeY = offset + (_snakePosition.y * scaleY);

    // ✅ Ilon nuqtasi
    canvas.drawCircle(
      Offset(snakeX, snakeY),
      GameConstants.miniMapSnakeDotRadius,
      _snakeDotPaint,
    );
  }

  void hide() => _opacity = 0.0;
  void show() => _opacity = 1.0;
  void setOpacity(double value) => _opacity = value.clamp(0.0, 1.0);
}