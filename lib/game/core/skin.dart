import 'dart:math' as math;
import 'package:flutter/material.dart';

abstract class SnakeSkin {
  final String id;
  final String name;

  SnakeSkin(this.id, this.name);

  void renderSegment(
      Canvas canvas,
      Offset offset,
      double radius,
      int index,
      double progress,
      );
}


class RealisticSnakeSkin extends SnakeSkin {
  final Color primaryColor;
  final Color patternColor;

  RealisticSnakeSkin(
      super.id,
      super.name,
      this.primaryColor,
      this.patternColor,
      );

  Color get mainColor => primaryColor;

  @override
  void renderSegment(
      Canvas canvas,
      Offset offset,
      double radius,
      int index,
      double progress,
      ) {
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [
          primaryColor.withOpacity(0.95),
          primaryColor,
          primaryColor.withOpacity(0.7),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: offset, radius: radius));

    canvas.drawCircle(offset, radius, bodyPaint);

    if (index % 3 == 0) {
      _renderScalePattern(canvas, offset, radius);
    }

    _renderHighlight(canvas, offset, radius);

    _renderShadow(canvas, offset, radius);
  }

  void _renderScalePattern(Canvas canvas, Offset offset, double radius) {
    final scalePaint = Paint()
      ..color = patternColor.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(offset.dx, offset.dy - radius * 0.5);
    path.lineTo(offset.dx + radius * 0.4, offset.dy);
    path.lineTo(offset.dx, offset.dy + radius * 0.5);
    path.lineTo(offset.dx - radius * 0.4, offset.dy);
    path.close();

    canvas.drawPath(path, scalePaint);
    canvas.drawPath(
      path,
      Paint()
        ..color = patternColor.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  void _renderHighlight(Canvas canvas, Offset offset, double radius) {
    canvas.drawCircle(
      Offset(offset.dx - radius * 0.2, offset.dy - radius * 0.2),
      radius * 0.4,
      Paint()
        ..color = const Color(0x33FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _renderShadow(Canvas canvas, Offset offset, double radius) {
    final shadowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.black.withOpacity(0.15),
        ],
      ).createShader(Rect.fromCircle(center: offset, radius: radius));

    canvas.drawCircle(offset, radius, shadowPaint);
  }
}

class FireSnakeSkin extends SnakeSkin {
  FireSnakeSkin() : super('fire', 'Inferno Dragon');

  @override
  void renderSegment(
      Canvas canvas,
      Offset offset,
      double radius,
      int index,
      double progress,
      ) {
    canvas.drawCircle(
      offset,
      radius * 1.15,
      Paint()
        ..color = const Color(0xFFFF5722).withOpacity(0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    canvas.drawCircle(
      offset,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: const [
            Color(0xFFFFEB3B),
            Color(0xFFFF9800),
            Color(0xFFFF5722),
            Color(0xFFD84315),
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ).createShader(Rect.fromCircle(center: offset, radius: radius)),
    );
  }
}

class CrystalSnakeSkin extends SnakeSkin {
  CrystalSnakeSkin() : super('crystal', 'Ice Crystal');

  @override
  void renderSegment(
      Canvas canvas,
      Offset offset,
      double radius,
      int index,
      double progress,
      ) {
    canvas.drawCircle(
      offset,
      radius * 1.2,
      Paint()
        ..color = const Color(0xFF00BCD4).withOpacity(0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    canvas.drawCircle(
      offset,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: const [
            Color(0xFFE1F5FE),
            Color(0xFF81D4FA),
            Color(0xFF0288D1),
          ],
        ).createShader(Rect.fromCircle(center: offset, radius: radius)),
    );

    if (index % 4 == 0) {
      _drawHexagon(canvas, offset, radius);
    }
  }

  void _drawHexagon(Canvas canvas, Offset offset, double radius) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * math.pi / 180;
      final x = offset.dx + radius * 0.7 * math.cos(angle);
      final y = offset.dy + radius * 0.7 * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF00E5FF).withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }
}


class SkinLibrary {
  static final List<SnakeSkin> allSkins = [
    RealisticSnakeSkin(
      'python',
      'Python',
      const Color(0xFF2E7D32),
      const Color(0xFF1B5E20),
    ),
    RealisticSnakeSkin(
      'cobra',
      'King Cobra',
      const Color(0xFFD84315),
      const Color(0xFF4E342E),
    ),
    RealisticSnakeSkin(
      'viper',
      'Green Viper',
      const Color(0xFF558B2F),
      const Color(0xFF33691E),
    ),

    FireSnakeSkin(),
    CrystalSnakeSkin(),
  ];

  static SnakeSkin getSkin(String id) {
    return allSkins.firstWhere(
          (skin) => skin.id == id,
      orElse: () => allSkins[0],
    );
  }

  static List<String> get skinNames =>
      allSkins.map((skin) => skin.name).toList();

  static List<String> get skinIds =>
      allSkins.map((skin) => skin.id).toList();
}