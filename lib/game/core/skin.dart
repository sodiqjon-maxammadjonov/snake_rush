import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';

abstract class SnakeSkin {
  final String id;
  final String name;
  SnakeSkin(this.id, this.name);
  void renderSegment(Canvas canvas, Offset offset, double radius, int index, double progress);
}

// 🐍 HAQIQIY ILON - Realistik po'st naqshlari bilan
class RealisticSnakeSkin extends SnakeSkin {
  final Color primaryColor;
  final Color patternColor;

  RealisticSnakeSkin(super.id, super.name, this.primaryColor, this.patternColor);

  // Public getter
  Color get mainColor => primaryColor;

  @override
  void renderSegment(Canvas canvas, Offset offset, double radius, int index, double progress) {
    // Asosiy tana - 3D Gradient
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

    // Po'st naqshlari (Pattern scales)
    if (index % 3 == 0) {
      final scalePaint = Paint()
        ..color = patternColor.withOpacity(0.6)
        ..style = PaintingStyle.fill;

      // Diamond shaklidagi tarozichalar
      final path = Path();
      path.moveTo(0, -radius * 0.5);
      path.lineTo(radius * 0.4, 0);
      path.lineTo(0, radius * 0.5);
      path.lineTo(-radius * 0.4, 0);
      path.close();

      canvas.drawPath(path, scalePaint);

      // Tarozichalar atrofida border
      canvas.drawPath(path, Paint()
        ..color = patternColor.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0);
    }

    // Hajmli ko'rinish uchun highlight
    final highlightPaint = Paint()
      ..color = const Color(0x33FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(offset.dx - radius * 0.2, offset.dy - radius * 0.2),
        radius * 0.4, highlightPaint);

    // Soya effekti (pastki qism qorongroq)
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

// 🔥 OT ILONI - Lavaga o'xshagan
class FireSnakeSkin extends SnakeSkin {
  FireSnakeSkin() : super('fire', 'Inferno Dragon');

  @override
  void renderSegment(Canvas canvas, Offset offset, double radius, int index, double progress) {
    // Yumshoq glow (kamroq yorqin)
    final glowPaint = Paint()
      ..color = const Color(0xFFFF5722).withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(offset, radius * 1.15, glowPaint);

    // Asosiy gradiyent (Olovli)
    final firePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.2, -0.2),
        colors: [
          const Color(0xFFFFEB3B), // Sariq (eng issiq)
          const Color(0xFFFF9800), // To'q sariq
          const Color(0xFFFF5722), // Qizil
          const Color(0xFFD84315), // To'q qizil
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: offset, radius: radius));

    canvas.drawCircle(offset, radius, firePaint);

    // Harakatlanuvchi olov chiziqlar
    if (index % 2 == 0) {
      final flamePath = Path();
      final flameHeight = radius * 0.6;

      flamePath.moveTo(-radius * 0.3, flameHeight);
      flamePath.quadraticBezierTo(0, -flameHeight * 0.5, radius * 0.3, flameHeight);

      canvas.drawPath(flamePath, Paint()
        ..color = const Color(0xFFFFD54F).withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0);
    }

    // Yorug'lik zarrachalar
    if (index % 5 == 0) {
      canvas.drawCircle(Offset(radius * 0.3, -radius * 0.4), 1.2,
          Paint()..color = const Color(0xCCFFFFFF));
    }
  }
}

// 💎 KRISTAL ILON - Shaffof va yorqin
class CrystalSnakeSkin extends SnakeSkin {
  CrystalSnakeSkin() : super('crystal', 'Ice Crystal');

  @override
  void renderSegment(Canvas canvas, Offset offset, double radius, int index, double progress) {
    // Yumshoq glow (kamroq yorqin)
    final glowPaint = Paint()
      ..color = const Color(0xFF00BCD4).withOpacity(0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(offset, radius * 1.2, glowPaint);

    // Asosiy kristal tanasi
    final crystalPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFE1F5FE),
          const Color(0xFF81D4FA),
          const Color(0xFF0288D1),
        ],
      ).createShader(Rect.fromCircle(center: offset, radius: radius));

    canvas.drawCircle(offset, radius, crystalPaint);

    // Ichki aks-sado (Refraction)
    final innerPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(offset.dx - radius * 0.3, offset.dy - radius * 0.3),
        radius * 0.4, innerPaint);

    // Kristal qirralari
    final edgePaint = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final hexPath = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * math.pi / 180;
      final x = offset.dx + radius * 0.7 * math.cos(angle);
      final y = offset.dy + radius * 0.7 * math.sin(angle);
      if (i == 0) {
        hexPath.moveTo(x, y);
      } else {
        hexPath.lineTo(x, y);
      }
    }
    hexPath.close();
    canvas.drawPath(hexPath, edgePaint);

    // Yorug'lik zarrachalar
    if (index % 4 == 0) {
      canvas.drawCircle(Offset(radius * 0.4, -radius * 0.3), 1.0,
          Paint()..color = Colors.white.withOpacity(0.8));
    }
  }
}

// 🌌 GALAKTIKA ILONI - Koinot manzarasi
class GalaxySnakeSkin extends SnakeSkin {
  GalaxySnakeSkin() : super('galaxy', 'Cosmic Serpent');

  @override
  void renderSegment(Canvas canvas, Offset offset, double radius, int index, double progress) {
    // Yumshoq kosmos glow
    final glowPaint = Paint()
      ..color = const Color(0xFF7B1FA2).withOpacity(0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(offset, radius * 1.25, glowPaint);

    // Galaktika gradiyenti
    final galaxyPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          const Color(0xFF1A237E),
          const Color(0xFF4A148C),
          const Color(0xFF880E4F),
          const Color(0xFF311B92),
          const Color(0xFF1A237E),
        ],
      ).createShader(Rect.fromCircle(center: offset, radius: radius));

    canvas.drawCircle(offset, radius, galaxyPaint);

    // Yulduzlar (Random joylashtirilgan)
    final starPaint = Paint()..color = Colors.white.withOpacity(0.9);
    if (index % 2 == 0) {
      canvas.drawCircle(Offset(offset.dx + radius * 0.3, offset.dy - radius * 0.4),
          1.2, starPaint);
      canvas.drawCircle(Offset(offset.dx - radius * 0.4, offset.dy + radius * 0.2),
          0.8, starPaint);
    }

    // Yumshoq nebula effekti
    final nebulaPaint = Paint()
      ..color = const Color(0xFFE91E63).withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(Offset(offset.dx + radius * 0.2, offset.dy - radius * 0.2),
        radius * 0.5, nebulaPaint);

    // Spiral chizig'i
    if (index % 3 == 0) {
      final spiralPaint = Paint()
        ..color = const Color(0xFF64FFDA).withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      final path = Path();
      for (double i = 0; i < 360; i += 15) {
        final angle = i * math.pi / 180;
        final r = radius * 0.3 + (i / 360) * radius * 0.4;
        final x = offset.dx + r * math.cos(angle);
        final y = offset.dy + r * math.sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, spiralPaint);
    }
  }
}

// ⚡ ELEKTR ILONI - Neon effektlar bilan
class ElectricSnakeSkin extends SnakeSkin {
  ElectricSnakeSkin() : super('electric', 'Lightning Bolt');

  @override
  void renderSegment(Canvas canvas, Offset offset, double radius, int index, double progress) {
    // Yumshoq elektr halo
    final haloPaint = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
    canvas.drawCircle(offset, radius * 1.3, haloPaint);

    // Neon gradiyent
    final neonPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFFFFF),
          const Color(0xFF00E5FF),
          const Color(0xFF0091EA),
        ],
      ).createShader(Rect.fromCircle(center: offset, radius: radius));

    canvas.drawCircle(offset, radius, neonPaint);

    // Elektr chiziqlar (Zigzag)
    if (index % 2 == 0) {
      final boltPaint = Paint()
        ..color = const Color(0xFFFFFFFF).withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;

      final path = Path();
      path.moveTo(offset.dx - radius * 0.6, offset.dy - radius * 0.3);
      path.lineTo(offset.dx - radius * 0.2, offset.dy + radius * 0.1);
      path.lineTo(offset.dx + radius * 0.1, offset.dy - radius * 0.2);
      path.lineTo(offset.dx + radius * 0.5, offset.dy + radius * 0.4);

      canvas.drawPath(path, boltPaint);
    }

    // Energiya zarrachalar
    final particlePaint = Paint()..color = const Color(0xFF76FF03).withOpacity(0.8);
    if (index % 3 == 0) {
      canvas.drawCircle(Offset(offset.dx + radius * 0.4, offset.dy - radius * 0.5),
          1.2, particlePaint);
      canvas.drawCircle(Offset(offset.dx - radius * 0.3, offset.dy + radius * 0.4),
          1.0, particlePaint);
    }

    // Ichki yadro
    canvas.drawCircle(offset, radius * 0.3,
        Paint()..color = Colors.white.withOpacity(0.7));
  }
}

// 🐉 AJDAHO ILONI - Tarozichalar va chiziqlarga ega
class DragonSnakeSkin extends SnakeSkin {
  DragonSnakeSkin() : super('dragon', 'Ancient Dragon');

  @override
  void renderSegment(Canvas canvas, Offset offset, double radius, int index, double progress) {
    // Asosiy qora-kulrang tana
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF424242),
          const Color(0xFF212121),
          const Color(0xFF000000),
        ],
      ).createShader(Rect.fromCircle(center: offset, radius: radius));

    canvas.drawCircle(offset, radius, bodyPaint);

    // Qizil tarozichalar (Orqa chizig'i)
    final scalePaint = Paint()
      ..color = const Color(0xFFD32F2F)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(offset.dx + radius * 0.7, offset.dy);
    path.lineTo(offset.dx, offset.dy - radius * 0.6);
    path.lineTo(offset.dx - radius * 0.3, offset.dy);
    path.lineTo(offset.dx, offset.dy + radius * 0.6);
    path.close();

    canvas.drawPath(path, scalePaint);

    // Tarozichalar atrofi
    canvas.drawPath(path, Paint()
      ..color = const Color(0xFFFF5252).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);

    // Oltin chiziqlari
    if (index % 4 == 0) {
      final goldPaint = Paint()
        ..color = const Color(0xFFFFD700).withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      canvas.drawLine(
        Offset(offset.dx - radius * 0.4, offset.dy - radius * 0.2),
        Offset(offset.dx + radius * 0.4, offset.dy - radius * 0.2),
        goldPaint,
      );
    }
  }
}

// 🌈 RANGLAR ILONI - O'zgaruvchan ranglar
class RainbowSnakeSkin extends SnakeSkin {
  RainbowSnakeSkin() : super('rainbow', 'Rainbow Dream');

  @override
  void renderSegment(Canvas canvas, Offset offset, double radius, int index, double progress) {
    // Har segment alohida rang oladi
    final colors = [
      const Color(0xFFE91E63), // Pushti
      const Color(0xFF9C27B0), // Binafsha
      const Color(0xFF3F51B5), // Ko'k
      const Color(0xFF00BCD4), // Moviy
      const Color(0xFF4CAF50), // Yashil
      const Color(0xFFFFEB3B), // Sariq
      const Color(0xFFFF9800), // To'q sariq
    ];

    final colorIndex = index % colors.length;
    final currentColor = colors[colorIndex];

    // Yumshoq glow
    final glowPaint = Paint()
      ..color = currentColor.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(offset, radius * 1.15, glowPaint);

    // Gradient rang
    final rainbowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          currentColor.withOpacity(0.9),
          currentColor,
          currentColor.withOpacity(0.6),
        ],
      ).createShader(Rect.fromCircle(center: offset, radius: radius));

    canvas.drawCircle(offset, radius, rainbowPaint);

    // Oq nurlar
    final shimmerPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(offset.dx - radius * 0.2, offset.dy - radius * 0.2),
        radius * 0.5, shimmerPaint);

    // Zarrachalar
    if (index % 2 == 0) {
      canvas.drawCircle(Offset(offset.dx + radius * 0.4, offset.dy),
          1.2, Paint()..color = Colors.white.withOpacity(0.8));
    }
  }
}

class SkinLibrary {
  static final List<SnakeSkin> allSkins = [
    // Realistik ilon skinlari
    RealisticSnakeSkin('python', 'Python', const Color(0xFF2E7D32), const Color(0xFF1B5E20)),
    RealisticSnakeSkin('cobra', 'King Cobra', const Color(0xFFD84315), const Color(0xFF4E342E)),
    RealisticSnakeSkin('viper', 'Green Viper', const Color(0xFF558B2F), const Color(0xFF33691E)),

    // Fantastik skinlar
    FireSnakeSkin(),
    CrystalSnakeSkin(),
    GalaxySnakeSkin(),
    ElectricSnakeSkin(),
    DragonSnakeSkin(),
    RainbowSnakeSkin(),
  ];

  static SnakeSkin getSkin(String id) {
    return allSkins.firstWhere((s) => s.id == id, orElse: () => allSkins[0]);
  }
}