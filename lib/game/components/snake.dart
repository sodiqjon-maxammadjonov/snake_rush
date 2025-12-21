import 'dart:ui';
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../utils/services/service_locator.dart';
import '../../utils/services/storage/storage_service.dart';
import '../config/game_constants.dart';
import '../core/skin.dart';
import 'game_map.dart';
import 'food_manager.dart';

class Snake extends PositionComponent with HasGameRef {
  final GameMap map;
  final FoodManager foodManager;

  double score = 10000.0;
  double currentRadius = GameConstants.minSnakeRadius;

 int get totalScore => score.toInt();
  int get currentLength => _segmentPositions.length;

  Vector2 direction = Vector2(1, 0);
  Vector2 targetDirection = Vector2(1, 0);

  final List<Vector2> _pathPoints = [];
  final List<Vector2> _segmentPositions = [];
  late SnakeSkin _activeSkin;

  final double _turnSpeed = 6.5;

  Snake({required this.map, required this.foodManager}) : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    final storage = getIt<StorageService>();
    _activeSkin = SkinLibrary.getSkin(storage.selectedSkin);
    position = Vector2(GameConstants.startX, GameConstants.startY);
    size = Vector2.all(currentRadius * 2);
    for (int i = 0; i < 2000; i++) _pathPoints.add(position.clone());
  }

  void grow(int points) {
    score += points;
  }

  @override
  void update(double dt) {
    super.update(dt);
    currentRadius = GameConstants.minSnakeRadius + (math.log(score / 50 + 1) * 8.0);
    currentRadius = currentRadius.clamp(GameConstants.minSnakeRadius, GameConstants.maxSnakeRadius);

    _rotateTowardsTarget(dt);
    double weightPenalty = (currentRadius / GameConstants.maxSnakeRadius) * 0.4;
    double speed = GameConstants.baseSnakeSpeed * (1.1 - weightPenalty);

    position.add(direction * speed * dt);
    position.x = position.x.clamp(0, GameConstants.mapWidth);
    position.y = position.y.clamp(0, GameConstants.mapHeight);

    if (_pathPoints.isEmpty || position.distanceTo(_pathPoints.first) > 2.0) {
      _pathPoints.insert(0, position.clone());
      if (_pathPoints.length > 5000) _pathPoints.removeLast();
    }

    foodManager.checkFoodInteractions(position, currentRadius, dt, (p) => grow(p));
    _updateSegments();

    double targetZoom = (GameConstants.baseCameraZoom - (currentRadius / 280)).clamp(0.45, 1.1);
    gameRef.camera.viewfinder.zoom += (targetZoom - gameRef.camera.viewfinder.zoom) * 2.0 * dt;
  }

  void _updateSegments() {
    _segmentPositions.clear();
    int segmentCount = (score / 1.5).floor().clamp(10, 1500);
    double spacing = currentRadius * 0.45;
    double accumulatedDist = 0;
    int pointIdx = 0;

    for (int i = 0; i < segmentCount; i++) {
      double target = i * spacing;
      while (pointIdx < _pathPoints.length - 1) {
        double d = _pathPoints[pointIdx].distanceTo(_pathPoints[pointIdx + 1]);
        if (accumulatedDist + d >= target) {
          double ratio = (target - accumulatedDist) / (d > 0 ? d : 1.0);
          _segmentPositions.add(_pathPoints[pointIdx] + (_pathPoints[pointIdx + 1] - _pathPoints[pointIdx]) * ratio);
          break;
        }
        accumulatedDist += d;
        pointIdx++;
      }
    }
  }

  void _rotateTowardsTarget(double dt) {
    if (targetDirection.isZero()) return;
    double diff = direction.angleToSigned(targetDirection);
    double step = _turnSpeed * dt;
    direction.rotate(diff.abs() <= step ? diff : (diff > 0 ? step : -step));
    direction.normalize();
  }

  @override
  void render(Canvas canvas) {
    final shadowPaint = Paint()..color = Colors.black.withOpacity(0.15)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    for (int i = _segmentPositions.length - 1; i >= 0; i -= 8) {
      canvas.drawCircle(_segmentPositions[i].toOffset() - position.toOffset() + const Offset(4, 4) + (size/2).toOffset(), currentRadius, shadowPaint);
    }
    for (int i = _segmentPositions.length - 1; i >= 0; i--) {
      double prog = i / _segmentPositions.length;
      double r = currentRadius * (1.0 - prog * 0.25);
      _activeSkin.renderSegment(canvas, (_segmentPositions[i] - position + (size / 2)).toOffset(), r, i, prog);
    }
    _renderEyes(canvas);
  }

  void _renderEyes(Canvas canvas) {
    final headCenter = (size / 2).toOffset();
    double angle = math.atan2(direction.y, direction.x);
    canvas.save();
    canvas.translate(headCenter.dx, headCenter.dy);
    canvas.rotate(angle);
    double eyeOff = currentRadius * 0.55;
    double eyeSize = currentRadius * 0.35;
    canvas.drawCircle(Offset(eyeOff, -eyeOff / 1.5), eyeSize, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(eyeOff, eyeOff / 1.5), eyeSize, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(eyeOff + eyeSize*0.3, -eyeOff / 1.5), eyeSize*0.5, Paint()..color = Colors.black);
    canvas.drawCircle(Offset(eyeOff + eyeSize*0.3, eyeOff / 1.5), eyeSize*0.5, Paint()..color = Colors.black);
    canvas.restore();
  }
}