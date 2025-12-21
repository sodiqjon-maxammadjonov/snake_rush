import 'dart:ui';
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Particle tizimi - turli effektlar
class ParticleSystem extends Component {
  final List<Particle> _particles = [];
  final int _maxParticles = 500; // Performance limit

  @override
  void update(double dt) {
    super.update(dt);

    // O'lgan particlelarni olib tashlash
    _particles.removeWhere((p) => p.isDead);

    // Har bir particle'ni yangilash
    for (final particle in _particles) {
      particle.update(dt);
    }
  }

  @override
  void render(Canvas canvas) {
    for (final particle in _particles) {
      particle.render(canvas);
    }
  }

  // ==================== EFFECT CREATORS ====================

  /// Ovqat yeyilganda
  void spawnFoodEatEffect(Vector2 position, Color color) {
    if (_particles.length >= _maxParticles) return;

    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * math.pi * 2;
      final velocity = Vector2(
        math.cos(angle) * 100,
        math.sin(angle) * 100,
      );

      _particles.add(Particle(
        position: position.clone(),
        velocity: velocity,
        color: color,
        size: 4,
        lifetime: 0.5,
      ));
    }
  }

  /// Ilon o'lganda
  void spawnDeathEffect(Vector2 position, double radius, Color color) {
    if (_particles.length >= _maxParticles) return;

    final random = math.Random();
    final particleCount = (radius * 2).toInt().clamp(20, 100);

    for (int i = 0; i < particleCount; i++) {
      final angle = random.nextDouble() * math.pi * 2;
      final speed = 50 + random.nextDouble() * 150;

      _particles.add(Particle(
        position: position.clone(),
        velocity: Vector2(
          math.cos(angle) * speed,
          math.sin(angle) * speed,
        ),
        color: color,
        size: 3 + random.nextDouble() * 5,
        lifetime: 0.8 + random.nextDouble() * 0.4,
      ));
    }
  }

  /// Power-up olinganda
  void spawnPowerUpEffect(Vector2 position, Color color) {
    if (_particles.length >= _maxParticles) return;

    final random = math.Random();

    for (int i = 0; i < 20; i++) {
      final angle = random.nextDouble() * math.pi * 2;
      final speed = 50 + random.nextDouble() * 100;

      _particles.add(Particle(
        position: position.clone(),
        velocity: Vector2(
          math.cos(angle) * speed,
          math.sin(angle) * speed,
        ),
        color: color,
        size: 3,
        lifetime: 1.0,
        glow: true,
      ));
    }
  }

  /// Trail effect (ilon izi)
  void spawnTrailEffect(Vector2 position, Color color, double radius) {
    if (_particles.length >= _maxParticles) return;

    _particles.add(Particle(
      position: position.clone(),
      velocity: Vector2.zero(),
      color: color,
      size: radius * 0.5,
      lifetime: 0.3,
      fadeOut: true,
    ));
  }

  /// Explosion effect
  void spawnExplosion(Vector2 position, {Color? color, double radius = 100}) {
    if (_particles.length >= _maxParticles) return;

    final random = math.Random();
    final particleColor = color ?? const Color(0xFFFF5722);

    for (int i = 0; i < 30; i++) {
      final angle = random.nextDouble() * math.pi * 2;
      final speed = 100 + random.nextDouble() * 200;

      _particles.add(Particle(
        position: position.clone(),
        velocity: Vector2(
          math.cos(angle) * speed,
          math.sin(angle) * speed,
        ),
        color: particleColor,
        size: 4 + random.nextDouble() * 6,
        lifetime: 0.6,
        glow: true,
      ));
    }
  }

  /// Barcha particlelarni tozalash
  void clear() {
    _particles.clear();
  }
}

// ==================== PARTICLE CLASS ====================

class Particle {
  Vector2 position;
  Vector2 velocity;
  Color color;
  double size;
  double lifetime;

  final bool glow;
  final bool fadeOut;

  double _age = 0.0;

  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.lifetime,
    this.glow = false,
    this.fadeOut = false,
  });

  void update(double dt) {
    _age += dt;

    // Harakat
    position.add(velocity * dt);

    // Gravity (ixtiyoriy)
    velocity.y += 100 * dt;

    // Friction
    velocity.scale(0.98);
  }

  void render(Canvas canvas) {
    if (isDead) return;

    final progress = _age / lifetime;
    final currentSize = fadeOut ? size * (1.0 - progress) : size;
    final alpha = fadeOut ? (1.0 - progress) : 1.0;

    final paint = Paint()
      ..color = color.withOpacity(alpha.clamp(0, 1));

    // Glow effect
    if (glow) {
      canvas.drawCircle(
        position.toOffset(),
        currentSize * 2,
        Paint()
          ..color = color.withOpacity(alpha * 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }

    // Main particle
    canvas.drawCircle(position.toOffset(), currentSize, paint);
  }

  bool get isDead => _age >= lifetime;
}

// ==================== SPECIALIZED EFFECTS ====================

/// Yulduzcha effekti (Power-up spawn)
class StarburstEffect extends Component {
  final Vector2 position;
  final Color color;

  double _age = 0.0;
  final double _lifetime = 0.8;

  StarburstEffect({
    required this.position,
    required this.color,
  });

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;

    if (_age >= _lifetime) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final progress = _age / _lifetime;
    final alpha = 1.0 - progress;
    final radius = 20 + (progress * 50);

    final paint = Paint()
      ..color = color.withOpacity(alpha * 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Yulduzcha chiziqlar
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * math.pi * 2;
      final end = position + Vector2(
        math.cos(angle) * radius,
        math.sin(angle) * radius,
      );

      canvas.drawLine(
        position.toOffset(),
        end.toOffset(),
        paint,
      );
    }
  }
}

/// Ring effekti (Collision)
class RingEffect extends Component {
  final Vector2 position;
  final Color color;
  final double maxRadius;

  double _age = 0.0;
  final double _lifetime = 0.6;

  RingEffect({
    required this.position,
    required this.color,
    this.maxRadius = 80,
  });

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;

    if (_age >= _lifetime) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final progress = _age / _lifetime;
    final alpha = 1.0 - progress;
    final radius = progress * maxRadius;

    canvas.drawCircle(
      position.toOffset(),
      radius,
      Paint()
        ..color = color.withOpacity(alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }
}