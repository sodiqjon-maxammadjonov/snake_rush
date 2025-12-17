import 'dart:ui';
import 'package:flame/components.dart';
import '../config/game_constants.dart';

/// O'yin mapini boshqaruvchi komponent
class GameMap extends PositionComponent {
  late final Paint _borderPaint;
  late final Paint _gridPaint;
  late final Paint _backgroundPaint;

  final Vector2 mapSize = Vector2(
    GameConstants.mapWidth,
    GameConstants.mapHeight,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = mapSize;
    position = Vector2.zero();
    anchor = Anchor.topLeft;

    _initializePaints();
  }

  void _initializePaints() {
    _backgroundPaint = Paint()
      ..color = GameConstants.mapBackgroundColor
      ..style = PaintingStyle.fill;

    _gridPaint = Paint()
      ..color = GameConstants.mapGridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    _borderPaint = Paint()
      ..color = GameConstants.mapBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = GameConstants.mapBorderWidth
      ..maskFilter = MaskFilter.blur(
        BlurStyle.outer,
        GameConstants.mapBorderBlurRadius,
      );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    _renderBackground(canvas);
    _renderGrid(canvas);
    _renderBorder(canvas);
  }

  void _renderBackground(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, mapSize.x, mapSize.y),
      _backgroundPaint,
    );
  }

  void _renderGrid(Canvas canvas) {
    // Vertikal chiziqlar
    for (double x = 0; x <= mapSize.x; x += GameConstants.mapGridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, mapSize.y),
        _gridPaint,
      );
    }

    // Gorizontal chiziqlar
    for (double y = 0; y <= mapSize.y; y += GameConstants.mapGridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(mapSize.x, y),
        _gridPaint,
      );
    }
  }

  void _renderBorder(Canvas canvas) {
    final borderRect = Rect.fromLTWH(
      GameConstants.mapBorderWidth / 2,
      GameConstants.mapBorderWidth / 2,
      mapSize.x - GameConstants.mapBorderWidth,
      mapSize.y - GameConstants.mapBorderWidth,
    );
    canvas.drawRect(borderRect, _borderPaint);
  }

  /// Map chegaralarida ekanligini tekshirish
  bool isNearBorder(Vector2 position, double threshold) {
    return position.x < threshold ||
        position.x > mapSize.x - threshold ||
        position.y < threshold ||
        position.y > mapSize.y - threshold;
  }

  /// Pozitsiya map ichida ekanligini tekshirish
  bool isInsideMap(Vector2 position, double radius) {
    return position.x >= radius &&
        position.x <= mapSize.x - radius &&
        position.y >= radius &&
        position.y <= mapSize.y - radius;
  }

  /// Pozitsiyani map ichida cheklash
  Vector2 clampPosition(Vector2 position, double radius) {
    return Vector2(
      position.x.clamp(radius, mapSize.x - radius),
      position.y.clamp(radius, mapSize.y - radius),
    );
  }
}