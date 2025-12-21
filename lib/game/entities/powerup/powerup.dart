import 'dart:ui';
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'powerup_type.dart';

/// Power-up entity - o'yinda paydo bo'ladigan bonus
class PowerUp extends PositionComponent {
  final PowerUpType type;

  double _lifeTime = 0.0;
  final double _maxLifeTime = 30.0; // 30 soniyadan keyin yo'qoladi

  double _rotationAngle = 0.0;
  double _pulseAnimation = 0.0;
  double _glowAnimation = 0.0;

  bool isBeingPulled = false;

  PowerUp({
    required Vector2 pos,
    required this.type,
  }) {
    position = pos;
    size = Vector2.all(40); // Base size
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Lifetime
    _lifeTime += dt;
    if (_lifeTime >= _maxLifeTime) {
      _fadeOut();
    }

    // Animations
    _rotationAngle += dt * 2.0;
    _pulseAnimation += dt * 3.0;
    _glowAnimation += dt * 2.5;

    // Loop animations
    if (_rotationAngle > math.pi * 2) _rotationAngle = 0.0;
    if (_pulseAnimation > math.pi * 2) _pulseAnimation = 0.0;
    if (_glowAnimation > math.pi * 2) _glowAnimation = 0.0;
  }

  @override
  void render(Canvas canvas) {
    final center = (size / 2).toOffset();

    // Glow effect (rarity'ga qarab)
    _renderGlow(canvas, center);

    // Rotating border
    _renderBorder(canvas, center);

    // Main body
    _renderBody(canvas, center);

    // Icon/Symbol
    _renderIcon(canvas, center);

    // Lifetime indicator
    _renderLifetimeBar(canvas);
  }

  // ==================== RENDER METHODS ====================

  void _renderGlow(Canvas canvas, Offset center) {
    final glowSize = 20 + (8 * math.sin(_glowAnimation));
    final glowRadius = (size.x / 2) + glowSize;

    final glowPaint = Paint()
      ..color = type.color.withOpacity(type.rarity.glowIntensity * 0.3)
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        glowSize * type.rarity.glowIntensity,
      );

    canvas.drawCircle(center, glowRadius, glowPaint);
  }

  void _renderBorder(Canvas canvas, Offset center) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(_rotationAngle);

    final borderRadius = size.x / 2;
    final borderPaint = Paint()
      ..color = type.rarity.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Hexagon yoki doira
    if (type.rarity.index >= PowerUpRarity.rare.index) {
      _drawHexagon(canvas, borderRadius, borderPaint);
    } else {
      canvas.drawCircle(Offset.zero, borderRadius, borderPaint);
    }

    canvas.restore();
  }

  void _renderBody(Canvas canvas, Offset center) {
    final pulseScale = 1.0 + (0.1 * math.sin(_pulseAnimation));
    final bodyRadius = (size.x / 2 - 5) * pulseScale;

    // Gradient fill
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          type.color.withOpacity(0.9),
          type.color.withOpacity(0.6),
          type.color.withOpacity(0.3),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: bodyRadius));

    canvas.drawCircle(center, bodyRadius, bodyPaint);
  }

  void _renderIcon(Canvas canvas, Offset center) {
    // Icon yoki text renderer
    final textPainter = TextPainter(
      text: TextSpan(
        text: type.icon,
        style: TextStyle(
          fontSize: 20,
          color: Colors.white.withOpacity(0.9),
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  void _renderLifetimeBar(Canvas canvas) {
    if (_lifeTime < _maxLifeTime * 0.7) return; // Oxirgi 30% da ko'rsatish

    final barWidth = size.x;
    final barHeight = 3.0;
    final barY = size.y + 5;

    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, barY, barWidth, barHeight),
      Paint()..color = Colors.black.withOpacity(0.3),
    );

    // Progress
    final progress = 1.0 - (_lifeTime / _maxLifeTime);
    final progressWidth = barWidth * progress;

    canvas.drawRect(
      Rect.fromLTWH(0, barY, progressWidth, barHeight),
      Paint()..color = Colors.yellow.withOpacity(0.8),
    );
  }

  void _drawHexagon(Canvas canvas, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * math.pi / 180;
      final x = radius * math.cos(angle);
      final y = radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  // ==================== BEHAVIOR ====================

  /// Ilonga tortilish
  void pullTowards(Vector2 target, double dt) {
    isBeingPulled = true;
    final direction = (target - position).normalized();
    const pullSpeed = 300.0;
    position.add(direction * pullSpeed * dt);
  }

  /// Fade out animatsiyasi
  void _fadeOut() {
    // TODO: Tween animation bilan yo'qolish
    removeFromParent();
  }

  /// Olinish effekti
  void collect() {
    // Particle effect
    // Sound effect
    removeFromParent();
  }
}