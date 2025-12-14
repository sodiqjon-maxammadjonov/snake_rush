import 'package:flutter/cupertino.dart';

class AppColors {
  AppColors._();

  static const primary = Color(0xFF667EEA);
  static const secondary = Color(0xFF764BA2);
  static const accent = Color(0xFFF093FB);

  static const bgDark = Color(0xFF0A0A0F);
  static const bgMedium = Color(0xFF1A1A2E);

  static Color glassLight = CupertinoColors.white.withOpacity(0.15);
  static Color glassMedium = CupertinoColors.white.withOpacity(0.1);
  static Color glassBorder = CupertinoColors.white.withOpacity(0.2);

  static const textPrimary = CupertinoColors.white;
  static const textSecondary = CupertinoColors.systemGrey;
  static const textMuted = CupertinoColors.systemGrey2;

  static const mainGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF667EEA),
      Color(0xFF764BA2),
      Color(0xFFF093FB),
    ],
  );

  static const coinGradient = LinearGradient(
    colors: [
      Color(0xFFFBBF24),
      Color(0xFFF59E0B),
      Color(0xFFF97316),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const playButtonGradient = LinearGradient(
    colors: [
      Color(0xFF34D399),
      Color(0xFF10B981),
    ],
  );

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: CupertinoColors.black.withOpacity(0.2),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: primary.withOpacity(0.4),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> coinShadow = [
    BoxShadow(
      color: CupertinoColors.systemYellow.withOpacity(0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}