import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';
import '../config/game_constants.dart';
import 'game_map.dart';

/// Ilon komponenti - Optimizatsiya qilingan
class Snake extends PositionComponent {
  Vector2 _direction = Vector2(1, 0);
  double _speed = GameConstants.snakeInitialSpeed;
  double _currentRadius = GameConstants.snakeInitialRadius;
  bool _isAlive = true;

  late final Paint _headPaint;
  late final Paint _eyePaint;
  final GameMap _gameMap;

  Snake({
    required Vector2 position,
    required GameMap gameMap,
  }) : _gameMap = gameMap {
    this.position = position;
    anchor = Anchor.center;
    priority = 100; // ✅ Normal priority
    _initializePaints();
  }

  void _initializePaints() {
    _headPaint = Paint()
      ..shader = _createGradientShader()
      ..style = PaintingStyle.fill;

    _eyePaint = Paint()
      ..color = GameConstants.snakeEyeColor
      ..style = PaintingStyle.fill;
  }

  Shader _createGradientShader() {
    return LinearGradient(
      colors: [
        GameConstants.snakeHeadColor,
        GameConstants.snakeBodyColor,
      ],
    ).createShader(
      Rect.fromCircle(
        center: Offset.zero,
        radius: _currentRadius,
      ),
    );
  }

  // Getters
  bool get isAlive => _isAlive;
  double get speed => _speed;
  double get radius => _currentRadius;
  Vector2 get direction => _direction;

  // Direction o'rnatish
  void setDirection(Vector2 newDirection) {
    if (newDirection.length > 0) {
      _direction = newDirection.normalized();
    }
  }

  // Tezlikni oshirish
  void increaseSpeed() {
    _speed = min(
      _speed + GameConstants.snakeSpeedIncrement,
      GameConstants.snakeMaxSpeed,
    );
  }

  // O'sish
  void grow(double amount) {
    _currentRadius += amount;
    size = Vector2.all(_currentRadius * 2);
    _headPaint.shader = _createGradientShader();
  }

  // O'lim
  void kill() {
    _isAlive = false;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!_isAlive) return;

    // ✅ Harakat (optimizatsiya qilingan)
    final movement = _direction * _speed * dt;
    position.add(movement);

    // ✅ Chegara tekshiruvi
    _checkBoundaries();
  }

  void _checkBoundaries() {
    bool hitBoundary = false;

    if (position.x - _currentRadius < 0) {
      position.x = _currentRadius;
      hitBoundary = true;
    } else if (position.x + _currentRadius > _gameMap.mapSize.x) {
      position.x = _gameMap.mapSize.x - _currentRadius;
      hitBoundary = true;
    }

    if (position.y - _currentRadius < 0) {
      position.y = _currentRadius;
      hitBoundary = true;
    } else if (position.y + _currentRadius > _gameMap.mapSize.y) {
      position.y = _gameMap.mapSize.y - _currentRadius;
      hitBoundary = true;
    }

    // Chegara bilan to'qnashganda tezlikni kamaytirish
    if (hitBoundary) {
      _speed = max(_speed * 0.95, GameConstants.snakeInitialSpeed);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Ilon boshi
    canvas.drawCircle(Offset.zero, _currentRadius, _headPaint);

    // Ko'zlar
    _renderEyes(canvas);
  }

  void _renderEyes(Canvas canvas) {
    final angle = atan2(_direction.y, _direction.x);
    final eyeOffset = GameConstants.snakeEyeOffsetDistance;
    final eyeRadius = GameConstants.snakeEyeRadius;
    final angleOffset = GameConstants.snakeEyeAngleOffset;

    // Chap ko'z
    final leftEye = Offset(
      eyeOffset * cos(angle + angleOffset),
      eyeOffset * sin(angle + angleOffset),
    );

    // O'ng ko'z
    final rightEye = Offset(
      eyeOffset * cos(angle - angleOffset),
      eyeOffset * sin(angle - angleOffset),
    );

    canvas.drawCircle(leftEye, eyeRadius, _eyePaint);
    canvas.drawCircle(rightEye, eyeRadius, _eyePaint);
  }

  // Boshqaruv metodlari
  void pause() => _isAlive = false;
  void resume() => _isAlive = true;

  void reset(Vector2 newPosition) {
    position = newPosition;
    _direction = Vector2(1, 0);
    _speed = GameConstants.snakeInitialSpeed;
    _currentRadius = GameConstants.snakeInitialRadius;
    _isAlive = true;
    size = Vector2.all(_currentRadius * 2);
    _headPaint.shader = _createGradientShader();
  }
}