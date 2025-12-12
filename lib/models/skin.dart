import 'package:flutter/material.dart';

// =============================================================================
// SKIN MODEL - Ilon skinlari
// =============================================================================

class SnakeSkin {
  final String id;
  final String name;
  final String emoji;
  final Color color;
  final Color? secondaryColor; // Gradient uchun
  final int price; // 0 = bepul
  final SkinRarity rarity;
  final String unlockMethod; // 'default', 'score', 'coins'
  final int? unlockScore; // Score bo'yicha ochilishi uchun

  const SnakeSkin({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    this.secondaryColor,
    required this.price,
    required this.rarity,
    required this.unlockMethod,
    this.unlockScore,
  });

  bool get isFree => price == 0;
  bool get hasGradient => secondaryColor != null;
}

// =============================================================================
// SKIN RARITY - Skin darajalari
// =============================================================================

enum SkinRarity {
  common,
  rare,
  epic,
  legendary,
}

extension SkinRarityExtension on SkinRarity {
  String get name {
    switch (this) {
      case SkinRarity.common:
        return 'Oddiy';
      case SkinRarity.rare:
        return 'Kam uchraydigan';
      case SkinRarity.epic:
        return 'Epic';
      case SkinRarity.legendary:
        return 'Legendary';
    }
  }

  Color get color {
    switch (this) {
      case SkinRarity.common:
        return const Color(0xFF9E9E9E); // Kulrang
      case SkinRarity.rare:
        return const Color(0xFF2196F3); // Ko'k
      case SkinRarity.epic:
        return const Color(0xFF9C27B0); // Binafsha
      case SkinRarity.legendary:
        return const Color(0xFFFFD700); // Oltin
    }
  }
}

// =============================================================================
// PREDEFINED SKINS - Barcha skinlar ro'yxati
// =============================================================================

class SnakeSkins {
  // COMMON SKINS (Bepul va oson ochiladi)
  static const green = SnakeSkin(
    id: 'green',
    name: 'Yashil Ilon',
    emoji: '🟢',
    color: Color(0xFF4ECCA3),
    price: 0,
    rarity: SkinRarity.common,
    unlockMethod: 'default',
  );

  static const blue = SnakeSkin(
    id: 'blue',
    name: 'Ko\'k Ilon',
    emoji: '🔵',
    color: Color(0xFF45B7D1),
    price: 0,
    rarity: SkinRarity.common,
    unlockMethod: 'score',
    unlockScore: 100,
  );

  static const yellow = SnakeSkin(
    id: 'yellow',
    name: 'Sariq Ilon',
    emoji: '🟡',
    color: Color(0xFFFFD93D),
    price: 0,
    rarity: SkinRarity.common,
    unlockMethod: 'score',
    unlockScore: 200,
  );

  static const red = SnakeSkin(
    id: 'red',
    name: 'Qizil Ilon',
    emoji: '🔴',
    color: Color(0xFFFF6B6B),
    price: 100,
    rarity: SkinRarity.common,
    unlockMethod: 'coins',
  );

  static const pink = SnakeSkin(
    id: 'pink',
    name: 'Pushti Ilon',
    emoji: '🌸',
    color: Color(0xFFFF69B4),
    price: 100,
    rarity: SkinRarity.common,
    unlockMethod: 'coins',
  );

  // RARE SKINS
  static const orange = SnakeSkin(
    id: 'orange',
    name: 'To\'q Sariq Ilon',
    emoji: '🟠',
    color: Color(0xFFFF8C42),
    price: 150,
    rarity: SkinRarity.rare,
    unlockMethod: 'coins',
  );

  static const gradient = SnakeSkin(
    id: 'gradient',
    name: 'Gradient Ilon',
    emoji: '🌈',
    color: Color(0xFFFF6B9D),
    secondaryColor: Color(0xFFC06C84),
    price: 200,
    rarity: SkinRarity.rare,
    unlockMethod: 'coins',
  );

  // EPIC SKINS
  static const neon = SnakeSkin(
    id: 'neon',
    name: 'Neon Ilon',
    emoji: '💚',
    color: Color(0xFF39FF14),
    price: 300,
    rarity: SkinRarity.epic,
    unlockMethod: 'coins',
  );

  static const uzbek = SnakeSkin(
    id: 'uzbek',
    name: 'O\'zbek Andijasi',
    emoji: '🇺🇿',
    color: Color(0xFF0099B5),
    secondaryColor: Color(0xFF1EB53A),
    price: 400,
    rarity: SkinRarity.epic,
    unlockMethod: 'coins',
  );

  // LEGENDARY SKIN
  static const diamond = SnakeSkin(
    id: 'diamond',
    name: 'Olmos Ilon',
    emoji: '💎',
    color: Color(0xFFB9F2FF),
    secondaryColor: Color(0xFF00D9FF),
    price: 500,
    rarity: SkinRarity.legendary,
    unlockMethod: 'coins',
  );

  // Barcha skinlar ro'yxati
  static const List<SnakeSkin> all = [
    green,
    blue,
    yellow,
    red,
    pink,
    orange,
    gradient,
    neon,
    uzbek,
    diamond,
  ];

  // ID bo'yicha skin topish
  static SnakeSkin? getById(String id) {
    try {
      return all.firstWhere((skin) => skin.id == id);
    } catch (e) {
      return null;
    }
  }

  // Rarity bo'yicha skinlar
  static List<SnakeSkin> getByRarity(SkinRarity rarity) {
    return all.where((skin) => skin.rarity == rarity).toList();
  }
}