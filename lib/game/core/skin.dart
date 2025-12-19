import 'dart:ui';
import 'package:flutter/cupertino.dart';

abstract class SnakeSkin {
  final String id;
  final String name;
  SnakeSkin(this.id, this.name);

  void renderSegment(Canvas canvas, Offset offset, double radius, int index, double progress);
}


class ClassicSkin extends SnakeSkin {
  final Color color;
  ClassicSkin(super.id, super.name, this.color);

  @override
  void renderSegment(Canvas canvas, Offset offset, double radius, int index, double progress) {
    canvas.drawCircle(offset, radius, Paint()..color = color);
  }
}

class GalaxySkin extends SnakeSkin {
  GalaxySkin() : super('galaxy', 'Galaxy');

  @override
  void renderSegment(Canvas canvas, Offset offset, double radius, int index, double progress) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFF6A1B9A), const Color(0xFF283593), const Color(0xFF000000)],
      ).createShader(Rect.fromCircle(center: offset, radius: radius));

    canvas.drawCircle(offset, radius, paint);

    if (index % 5 == 0) {
      canvas.drawCircle(offset + const Offset(2, -2), 1.5, Paint()..color = CupertinoColors.white);
    }
  }
}

class DragonSkin extends SnakeSkin {
  DragonSkin() : super('dragon', 'Shadow Dragon');

  @override
  void renderSegment(Canvas canvas, Offset offset, double radius, int index, double progress) {
    final bodyPaint = Paint()..color = const Color(0xFF212121);
    canvas.drawCircle(offset, radius, bodyPaint);

    final scalePaint = Paint()
      ..color = const Color(0xFFD32F2F).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawArc(Rect.fromCircle(center: offset, radius: radius * 0.8), 0, 3, false, scalePaint);
  }
}

class ElectricSkin extends SnakeSkin {
  ElectricSkin() : super('electric', 'Volt Hunter');

  @override
  void renderSegment(Canvas canvas, Offset offset, double radius, int index, double progress) {
    final glowPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 5);
    canvas.drawCircle(offset, radius, glowPaint);

    final innerPaint = Paint()..color = const Color(0xFFE0F7FA);
    canvas.drawCircle(offset, radius * 0.7, innerPaint);
  }
}

class SkinLibrary {
  static final List<SnakeSkin> allSkins = [
    ClassicSkin('classic', 'Default', const Color(0xFF34D399)),
    ClassicSkin('ocean', 'Ocean Blue', CupertinoColors.activeBlue),
    ClassicSkin('lava', 'Volcano Red', const Color(0xFFFF3D00)),
    ClassicSkin('night', 'Dark Night', const Color(0xFF37474F)),
    GalaxySkin(),
    DragonSkin(),
    ElectricSkin(),
  ];

  static SnakeSkin getSkin(String id) {
    return allSkins.firstWhere((s) => s.id == id, orElse: () => allSkins[0]);
  }
}