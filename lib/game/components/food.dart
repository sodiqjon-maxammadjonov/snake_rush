import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

enum FoodType {
  small(points: 1, radius: 6, color: Color(0xFFFF6B9D), magnetRange: 80),
  medium(points: 3, radius: 9, color: Color(0xFF4ECDC4), magnetRange: 100),
  large(points: 8, radius: 12, color: Color(0xFFFFE66D), magnetRange: 130),
  super_(points: 25, radius: 16, color: Color(0xFFFF5722), magnetRange: 160);

  final int points;
  final double radius;
  final Color color;
  final double magnetRange;
  const FoodType({required this.points, required this.radius, required this.color, required this.magnetRange});
}

class Food extends PositionComponent {
  final FoodType type;
  bool isBeingPulled = false;

  Food({required Vector2 pos, required this.type}) {
    position = pos;
    size = Vector2.all(type.radius * 2);
    anchor = Anchor.center;
  }

  void pullTowards(Vector2 target, double dt) {
    isBeingPulled = true;
    Vector2 dir = target - position;
    double pullSpeed = 400.0; // Tortilish tezligi
    position.add(dir.normalized() * pullSpeed * dt);
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(width / 2, height / 2);
    final paint = Paint()..color = type.color;

    // Asosiy sharcha
    canvas.drawCircle(center, type.radius, paint);

    // Ustki jilo
    canvas.drawCircle(center, type.radius * 0.4, Paint()..color = Colors.white.withOpacity(0.5));

    // Agar tortilayotgan bo'lsa effekt beramiz
    if (isBeingPulled) {
      canvas.drawCircle(center, type.radius * 1.3, Paint()..color = type.color.withOpacity(0.2)..style = PaintingStyle.stroke..strokeWidth = 2);
    }
  }
}