import 'dart:ui';
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../utils/services/service_locator.dart';
import '../../utils/services/storage/storage_service.dart';
import '../config/game_constants.dart';
import '../core/skin.dart';
import 'game_map.dart';

class Snake extends PositionComponent {
  final GameMap map;
  final List<Vector2> _pathHistory = [];
  Vector2 direction = Vector2(1, 0);
  Vector2 targetDirection = Vector2(1, 0);

  static const double _turnSpeed = 6.0;
  static const double _jointDistance = 5.0;
  static const int _maxPathLength = 3500;

  int currentLength = 100;
  double currentMass = 100.0;
  late SnakeSkin _activeSkin;

  final List<_SegmentData> _cachedSegments = [];
  double _headAngle = 0.0;
  final Paint _shadowPaint = Paint()..color = const Color(0x55000000)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

  Snake({required this.map}) : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    final String selectedSkinId = getIt<StorageService>().selectedSkin;
    _activeSkin = SkinLibrary.getSkin(selectedSkinId);

    size = Vector2.all(GameConstants.snakeRadius * 2);
    position = Vector2(GameConstants.startX, GameConstants.startY);

    for (int i = 0; i < currentLength * 15; i++) _pathHistory.add(position.clone());
    for (int i = 0; i < 2000; i++) _cachedSegments.add(_SegmentData());
  }

  @override
  void update(double dt) {
    super.update(dt);
    _rotateTowardsTarget(dt);
    _moveWithSlidePhysics(dt);

    _headAngle = math.atan2(direction.y, direction.x);

    if (_pathHistory.isEmpty || position.distanceTo(_pathHistory.first) >= 1.0) {
      _pathHistory.insert(0, position.clone());
      if (_pathHistory.length > _maxPathLength) _pathHistory.removeLast();
    }
    _updateSegmentPositions();
  }

  void _rotateTowardsTarget(double dt) {
    if (targetDirection.isZero()) return;
    double angleDiff = direction.angleToSigned(targetDirection);
    double step = _turnSpeed * dt;
    direction.rotate(angleDiff.abs() <= step ? angleDiff : (angleDiff > 0 ? step : -step));
  }

  void _moveWithSlidePhysics(double dt) {
    double speed = GameConstants.snakeSpeed;
    double r = GameConstants.snakeRadius;
    if (position.x <= r && direction.x < 0) direction.x = 0;
    else if (position.x >= GameConstants.mapWidth - r && direction.x > 0) direction.x = 0;
    if (position.y <= r && direction.y < 0) direction.y = 0;
    else if (position.y >= GameConstants.mapHeight - r && direction.y > 0) direction.y = 0;

    if (direction.length < 0.1) {
      if (position.x <= r || position.x >= GameConstants.mapWidth - r) direction.y = targetDirection.y > 0 ? 1 : -1;
      else direction.x = targetDirection.x > 0 ? 1 : -1;
    }
    if (!direction.isZero()) direction.normalize();
    position.add(direction * speed * dt);
  }

  void _updateSegmentPositions() {
    double distUsed = 0;
    int hIdx = 0;
    for (int i = 0; i < currentLength; i++) {
      final seg = _cachedSegments[i];
      while (hIdx < _pathHistory.length - 1) {
        final p1 = _pathHistory[hIdx], p2 = _pathHistory[hIdx+1];
        final d = p1.distanceTo(p2);
        if (distUsed + d >= _jointDistance) {
          final t = (_jointDistance - distUsed) / (d > 0 ? d : 1.0);
          seg.position.setFrom(p1 + (p2 - p1) * t);
          final diff = p1 - p2;
          if (!diff.isZero()) seg.angle = math.atan2(diff.y, diff.x);
          seg.radius = GameConstants.snakeRadius * (1.0 - (i/currentLength * 0.45));
          seg.visible = true; distUsed = 0; break;
        } else { distUsed += d; hIdx++; }
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final cOffset = Offset(size.x/2, size.y/2);
    // Shadows
    for (int i = currentLength - 1; i >= 0; i--) {
      if (!_cachedSegments[i].visible) continue;
      final rel = _cachedSegments[i].position - position;
      canvas.drawCircle(Offset(rel.x + cOffset.dx + 4, rel.y + cOffset.dy + 4), _cachedSegments[i].radius, _shadowPaint);
    }
    // Body
    for (int i = currentLength - 1; i >= 0; i--) {
      final s = _cachedSegments[i]; if (!s.visible) continue;
      final rel = s.position - position;
      canvas.save();
      canvas.translate(rel.x + cOffset.dx, rel.y + cOffset.dy);
      canvas.rotate(s.angle);
      _activeSkin.renderSegment(canvas, Offset.zero, s.radius, i, i/currentLength);
      canvas.restore();
    }
    // Head with corrected 90-degree eyes
    _renderHead(canvas);
  }

  void _renderHead(Canvas canvas) {
    final center = Offset(size.x/2, size.y/2);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(_headAngle);
    _activeSkin.renderSegment(canvas, Offset.zero, GameConstants.snakeRadius, 0, 0);
    // Symmetric Eyes
    canvas.drawCircle(const Offset(8, -6.5), 4.8, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(8, 6.5), 4.8, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(9.5, -6.5), 2.2, Paint()..color = Colors.black);
    canvas.drawCircle(const Offset(9.5, 6.5), 2.2, Paint()..color = Colors.black);
    canvas.restore();
  }

  void grow(int amount) {
    currentLength = (currentLength + amount).clamp(0, 1999);
  }
}

class _SegmentData {
  final Vector2 position = Vector2.zero();
  double angle = 0, radius = 0;
  bool visible = false;
}