import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';
import '../../utils/services/service_locator.dart';
import '../../utils/services/storage/storage_service.dart';
import '../config/game_constants.dart';
import '../core/skin.dart';
import 'game_map.dart';

class Snake extends PositionComponent {
  final GameMap map;

  final List<Vector2> _pathHistory = [];

  Vector2 direction = Vector2(1, 0);

  static const double _jointDistance = 8.0;
  int currentLength = 90;

  late SnakeSkin _activeSkin;

  late Paint _whitePaint;
  late Paint _blackPaint;

  final List<_SegmentData> _cachedSegments = [];

  double _headAngle = 0.0;

  static const int _maxPathLength = 2000;

  Snake({required this.map}) : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    final String selectedSkinId = getIt<StorageService>().selectedSkin;
    _activeSkin = SkinLibrary.getSkin(selectedSkinId);

    size = Vector2.all(GameConstants.snakeRadius * 2);
    position = Vector2(GameConstants.startX, GameConstants.startY);

    _whitePaint = Paint()..color = CupertinoColors.white;
    _blackPaint = Paint()..color = CupertinoColors.black;

    final initialCount = (currentLength * _jointDistance * 1.5).round();
    for (int i = 0; i < initialCount; i++) {
      _pathHistory.add(position.clone());
    }

    for (int i = 0; i < currentLength; i++) {
      _cachedSegments.add(_SegmentData());
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (direction.isZero()) return;

    final velocity = direction.normalized() * GameConstants.snakeSpeed * dt;
    position.add(velocity);

    position.x = position.x.clamp(size.x / 2, GameConstants.mapWidth - size.x / 2);
    position.y = position.y.clamp(size.y / 2, GameConstants.mapHeight - size.y / 2);

    _headAngle = direction.screenAngle();

    if (_pathHistory.isEmpty || position.distanceTo(_pathHistory.first) > 2.5) {
      _pathHistory.insert(0, position.clone());

      if (_pathHistory.length > _maxPathLength) {
        _pathHistory.removeLast();
      }
    }

    _updateSegmentPositions();
  }

  void _updateSegmentPositions() {
    if (_pathHistory.length < 2) return;

    double accumulatedDistance = 0.0;
    int pathIndex = 0;
    int segmentCount = 0;

    while (segmentCount < currentLength && pathIndex < _pathHistory.length - 1) {
      final current = _pathHistory[pathIndex];
      final next = _pathHistory[pathIndex + 1];
      final stepDistance = current.distanceTo(next);

      accumulatedDistance += stepDistance;

      if (accumulatedDistance >= _jointDistance) {
        final overflow = accumulatedDistance - _jointDistance;
        final ratio = 1.0 - (overflow / stepDistance);

        final segmentData = _cachedSegments[segmentCount];
        segmentData.position.x = next.x + (current.x - next.x) * ratio;
        segmentData.position.y = next.y + (current.y - next.y) * ratio;

        final progress = segmentCount / currentLength;
        segmentData.radius = GameConstants.snakeRadius * (1.0 - (progress * 0.4));
        segmentData.progress = progress;

        segmentCount++;
        accumulatedDistance = overflow;
      }

      pathIndex++;
    }

    for (int i = segmentCount; i < _cachedSegments.length; i++) {
      _cachedSegments[i].visible = false;
    }
    for (int i = 0; i < segmentCount; i++) {
      _cachedSegments[i].visible = true;
    }
  }

  @override
  void render(Canvas canvas) {
    for (int i = _cachedSegments.length - 1; i >= 0; i--) {
      final segment = _cachedSegments[i];
      if (!segment.visible) continue;

      final relativePos = segment.position - position;
      final offset = Offset(
        relativePos.x + size.x / 2,
        relativePos.y + size.y / 2,
      );

      _activeSkin.renderSegment(
        canvas,
        offset,
        segment.radius,
        i,
        segment.progress,
      );
    }

    _renderHead(canvas);
  }

  void _renderHead(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);

    canvas.save();

    canvas.translate(center.dx, center.dy);
    canvas.rotate(_headAngle);
    final Paint headPaint;
    if (_activeSkin is ClassicSkin) {
      headPaint = Paint()..color = (_activeSkin as ClassicSkin).color;
      canvas.drawCircle(Offset.zero, GameConstants.snakeRadius, headPaint);
    } else {
      canvas.save();
      canvas.translate(-center.dx, -center.dy);
      _activeSkin.renderSegment(canvas, center, GameConstants.snakeRadius, 0, 0.0);
      canvas.restore();
    }

    _drawEyes(canvas);

    canvas.restore();
  }

  void _drawEyes(Canvas canvas) {
    // Ko'zlar markazdan (0,0) hisoblanadi
    // +X oldinga, +Y o'ngga, -Y chapga
    const eyeOffsetX = 10.0;  // Oldinda (bosh yo'nalishida)
    const eyeOffsetY = 5.0;   // Yon tomonlarda

    // Yuqori va pastki ko'zlar
    final eye1 = Offset(eyeOffsetX, -eyeOffsetY); // Yuqori
    final eye2 = Offset(eyeOffsetX, eyeOffsetY);  // Pastki

    // Qorachiqlar oldinga qarab
    final pupil1 = Offset(eyeOffsetX + 2.5, -eyeOffsetY);
    final pupil2 = Offset(eyeOffsetX + 2.5, eyeOffsetY);

    // Ko'z oqlari
    canvas.drawCircle(eye1, 4.5, _whitePaint);
    canvas.drawCircle(eye2, 4.5, _whitePaint);

    // Qorachiqlar
    canvas.drawCircle(pupil1, 2.0, _blackPaint);
    canvas.drawCircle(pupil2, 2.0, _blackPaint);
  }

  void grow(int amount) {
    currentLength += amount;

    for (int i = 0; i < amount; i++) {
      _cachedSegments.add(_SegmentData());
    }
  }

  List<Vector2> get visibleSegmentPositions {
    return _cachedSegments
        .where((s) => s.visible)
        .map((s) => s.position)
        .toList(growable: false);
  }
}

class _SegmentData {
  final Vector2 position = Vector2.zero();
  double radius = 0.0;
  double progress = 0.0;
  bool visible = true;
}