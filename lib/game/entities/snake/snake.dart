import 'dart:ui';
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../utils/services/service_locator.dart';
import '../../../utils/services/storage/storage_service.dart';
import '../../config/game_constants.dart';
import '../../config/growth_config.dart';
import '../../core/skin.dart';
import '../../world/game_map.dart';
import '../food/food_manager.dart';
import 'snake_renderer.dart';

class Snake extends PositionComponent with HasGameRef {
  final GameMap map;
  final FoodManager foodManager;
  final bool isPlayer;

  double score = 10.0;
  double currentRadius = GameConstants.minSnakeRadius;

  int get totalScore => score.toInt();
  int get currentLength => _segmentPositions.length;

  Vector2 direction = Vector2(1, 0);
  Vector2 targetDirection = Vector2(1, 0);

  final List<Vector2> _pathPoints = [];
  final List<Vector2> _segmentPositions = [];
  late SnakeRenderer _renderer;

  int _targetSegmentCount = GrowthConfig.startLength;

  bool _isBoosting = false;
  double _boostEnergy = 100.0;
  final double _maxBoostEnergy = 100.0;
  final double _boostEnergyDrain = 25.0;
  final double _boostEnergyRegen = 15.0;

  Snake({
    required this.map,
    required this.foodManager,
    this.isPlayer = true,
  }) : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    final storage = getIt<StorageService>();
    String skinId = storage.selectedSkin;

    if (!isPlayer) {
      skinId = _getRandomBotSkin();
    }

    final skin = SkinLibrary.getSkin(skinId);
    _renderer = SnakeRenderer(skin);

    position = _getRandomSpawnPosition();
    size = Vector2.all(currentRadius * 2);

    for (int i = 0; i < 500; i++) {
      _pathPoints.add(position.clone());
    }
  }

  Vector2 _getRandomSpawnPosition() {
    if (isPlayer) {
      return Vector2(GameConstants.startX, GameConstants.startY);
    }

    final random = math.Random();
    const margin = 500.0;
    return Vector2(
      margin + random.nextDouble() * (GameConstants.mapWidth - margin * 2),
      margin + random.nextDouble() * (GameConstants.mapHeight - margin * 2),
    );
  }

  String _getRandomBotSkin() {
    final random = math.Random();
    final skins = ['python', 'cobra', 'viper', 'fire', 'crystal'];
    return skins[random.nextInt(skins.length)];
  }

  void grow(int points) {
    final multiplier = GrowthConfig.getScoreMultiplier(currentLength);
    score += points * multiplier;

    final growth = GrowthConfig.calculateGrowth(currentLength, points);
    _targetSegmentCount += growth;
    _targetSegmentCount = _targetSegmentCount.clamp(
        GrowthConfig.startLength,
        GrowthConfig.maxLength
    );
  }

  void setBoost(bool boosting) {
    if (boosting && _boostEnergy > 0) {
      _isBoosting = true;
    } else {
      _isBoosting = false;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    _updateRadius();
    _updateBoostEnergy(dt);
    _updateMovement(dt);
    _updatePath();
    _checkFoodCollisions(dt);
    _updateSegments();

    if (isPlayer) {
      _updateCamera(dt);
    }
  }

  void _updateRadius() {
    currentRadius = GrowthConfig.calculateRadiusGrowth(score);
    currentRadius = currentRadius.clamp(
      GameConstants.minSnakeRadius,
      GameConstants.maxSnakeRadius,
    );
  }

  void _updateBoostEnergy(double dt) {
    if (_isBoosting && _boostEnergy > 0) {
      _boostEnergy -= _boostEnergyDrain * dt;
      if (_boostEnergy <= 0) {
        _boostEnergy = 0;
        _isBoosting = false;
      }

      score -= 0.5 * dt;
      if (score < 10) {
        score = 10;
        _isBoosting = false;
      }
    } else if (!_isBoosting && _boostEnergy < _maxBoostEnergy) {
      _boostEnergy += _boostEnergyRegen * dt;
      _boostEnergy = _boostEnergy.clamp(0, _maxBoostEnergy);
    }
  }

  void _updateMovement(double dt) {
    _rotateTowardsTarget(dt);

    final baseSpeed = GameConstants.baseSnakeSpeed;
    final speedMultiplier = _isBoosting ? 1.8 : 1.0;

    final sizeSlowdown = (currentRadius / GameConstants.maxSnakeRadius) * 0.15;
    final finalSpeed = baseSpeed * speedMultiplier * (1.0 - sizeSlowdown);

    position.add(direction * finalSpeed * dt);

    position.x = position.x.clamp(50, GameConstants.mapWidth - 50);
    position.y = position.y.clamp(50, GameConstants.mapHeight - 50);
  }

  void _updatePath() {
    if (_pathPoints.isEmpty ||
        position.distanceTo(_pathPoints.first) > GameConstants.pathPointSpacing) {
      _pathPoints.insert(0, position.clone());

      final maxPoints = (_targetSegmentCount * 1.5).toInt();
      if (_pathPoints.length > maxPoints) {
        _pathPoints.removeLast();
      }
    }
  }

  void _checkFoodCollisions(double dt) {
    foodManager.checkFoodInteractions(
      position,
      currentRadius,
      dt,
          (points) => grow(points),
    );
  }

  void _updateSegments() {
    _segmentPositions.clear();

    final spacing = currentRadius * 0.6;
    double accumulatedDistance = 0;
    int pointIndex = 0;

    for (int i = 0; i < _targetSegmentCount && pointIndex < _pathPoints.length - 1; i++) {
      final targetDistance = i * spacing;

      while (pointIndex < _pathPoints.length - 1) {
        final distance = _pathPoints[pointIndex]
            .distanceTo(_pathPoints[pointIndex + 1]);

        if (accumulatedDistance + distance >= targetDistance) {
          final ratio = (targetDistance - accumulatedDistance) /
              (distance > 0 ? distance : 1.0);
          final segmentPos = _pathPoints[pointIndex] +
              (_pathPoints[pointIndex + 1] -
                  _pathPoints[pointIndex]) * ratio;
          _segmentPositions.add(segmentPos);
          break;
        }

        accumulatedDistance += distance;
        pointIndex++;
      }
    }
  }

  void _rotateTowardsTarget(double dt) {
    if (targetDirection.isZero()) return;

    final angleDifference = direction.angleToSigned(targetDirection);
    final rotationStep = GameConstants.turnSpeed * dt;

    if (angleDifference.abs() <= rotationStep) {
      direction.rotate(angleDifference);
    } else {
      direction.rotate(angleDifference > 0 ? rotationStep : -rotationStep);
    }

    direction.normalize();
  }

  void _updateCamera(double dt) {
    final targetZoom = (GameConstants.baseCameraZoom -
        (currentRadius / 350)).clamp(
      GameConstants.minCameraZoom,
      GameConstants.maxCameraZoom,
    );

    gameRef.camera.viewfinder.zoom +=
        (targetZoom - gameRef.camera.viewfinder.zoom) *
            GameConstants.cameraZoomSpeed * dt;
  }

  @override
  void render(Canvas canvas) {
    if (_isBoosting) {
      _renderBoostTrail(canvas);
    }

    _renderer.renderSegments(
      canvas,
      _segmentPositions,
      position,
      size,
      currentRadius,
    );
    _renderer.renderEyes(canvas, size, direction, currentRadius);
  }

  void _renderBoostTrail(Canvas canvas) {
    for (int i = 0; i < _segmentPositions.length; i += 3) {
      if (i >= _segmentPositions.length) break;

      final segmentPos = _segmentPositions[i];
      final offset = (segmentPos - position + (size / 2)).toOffset();

      canvas.drawCircle(
        offset,
        currentRadius * 0.3,
        Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
  }

  void changeSkin(String skinId) {
    final newSkin = SkinLibrary.getSkin(skinId);
    _renderer = SnakeRenderer(newSkin);
  }

  List<Vector2> get segmentPositions => List.unmodifiable(_segmentPositions);
  bool get isBoosting => _isBoosting;
  double get boostEnergy => _boostEnergy;
  double get maxBoostEnergy => _maxBoostEnergy;
}