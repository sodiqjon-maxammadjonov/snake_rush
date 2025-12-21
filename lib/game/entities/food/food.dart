import 'dart:ui';
import 'dart:math' as dart_math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'food_type.dart';

/// Ovqat entity - bitta ovqat ob'ekti
class Food extends PositionComponent {
  final FoodType type;
  bool isBeingPulled = false;
  double _pulseAnimation = 0.0;

  Food({
    required Vector2 pos,
    required this.type,
  }) {
    position = pos;
    size = Vector2.all(type.radius * 2);
    anchor = Anchor.center;
  }

  /// Ilonga tortilish harakati
  void pullTowards(Vector2 target, double dt) {
    if (!isBeingPulled) {
      isBeingPulled = true;
    }

    final direction = (target - position).normalized();
    const pullSpeed = 400.0;
    position.add(direction * pullSpeed * dt);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Pulsatsiya animatsiyasi
    _pulseAnimation += dt * 2.0;
    if (_pulseAnimation > 6.28) _pulseAnimation = 0.0; // 2*PI
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(width / 2, height / 2);
    final animatedRadius = type.radius + (isBeingPulled ? 2.0 : 0.0);

    // Asosiy sharcha
    final mainPaint = Paint()..color = type.color;
    canvas.drawCircle(center, animatedRadius, mainPaint);

    // Yorug'lik effekti (highlight)
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(center.dx - animatedRadius * 0.3, center.dy - animatedRadius * 0.3),
      animatedRadius * 0.4,
      highlightPaint,
    );

    // Tortilish effekti
    if (isBeingPulled) {
      final pulseRadius = animatedRadius * (1.3 + 0.1 * (1.0 + dart_math.sin(_pulseAnimation)));
      final pulsePaint = Paint()
        ..color = type.color.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(center, pulseRadius, pulsePaint);
    }
  }
}