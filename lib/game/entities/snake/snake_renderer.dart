import 'dart:ui';
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../core/skin.dart';

/// Ilon render qilish - vizual qismni alohida class qilamiz
class SnakeRenderer {
  final SnakeSkin skin;

  SnakeRenderer(this.skin);

  /// Segmentlarni chizish
  void renderSegments(
      Canvas canvas,
      List<Vector2> segmentPositions,
      Vector2 position,
      Vector2 size,
      double currentRadius,
      ) {
    // Soya (har 8-segmentga)
    _renderShadows(canvas, segmentPositions, position, size, currentRadius);

    // Asosiy segmentlar
    for (int i = segmentPositions.length - 1; i >= 0; i--) {
      final progress = i / segmentPositions.length;
      final segmentRadius = currentRadius * (1.0 - progress * 0.25);
      final segmentOffset = (segmentPositions[i] - position + (size / 2)).toOffset();

      skin.renderSegment(canvas, segmentOffset, segmentRadius, i, progress);
    }
  }

  /// Soyalarni chizish
  void _renderShadows(
      Canvas canvas,
      List<Vector2> segmentPositions,
      Vector2 position,
      Vector2 size,
      double currentRadius,
      ) {
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    for (int i = segmentPositions.length - 1; i >= 0; i -= 8) {
      final shadowOffset = segmentPositions[i].toOffset() -
          position.toOffset() +
          const Offset(4, 4) +
          (size / 2).toOffset();
      canvas.drawCircle(shadowOffset, currentRadius, shadowPaint);
    }
  }

  /// Ko'zlarni chizish
  void renderEyes(
      Canvas canvas,
      Vector2 size,
      Vector2 direction,
      double currentRadius,
      ) {
    final headCenter = (size / 2).toOffset();
    final angle = math.atan2(direction.y, direction.x);

    canvas.save();
    canvas.translate(headCenter.dx, headCenter.dy);
    canvas.rotate(angle);

    final eyeOffset = currentRadius * 0.55;
    final eyeSize = currentRadius * 0.35;

    // Oq qism
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(eyeOffset, -eyeOffset / 1.5), eyeSize, whitePaint);
    canvas.drawCircle(Offset(eyeOffset, eyeOffset / 1.5), eyeSize, whitePaint);

    // Qora qism (ko'z qorachig'i)
    final blackPaint = Paint()..color = Colors.black;
    canvas.drawCircle(
      Offset(eyeOffset + eyeSize * 0.3, -eyeOffset / 1.5),
      eyeSize * 0.5,
      blackPaint,
    );
    canvas.drawCircle(
      Offset(eyeOffset + eyeSize * 0.3, eyeOffset / 1.5),
      eyeSize * 0.5,
      blackPaint,
    );

    canvas.restore();
  }
}