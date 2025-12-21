import 'dart:math' as dart_math;

import 'package:flutter/material.dart';

/// Power-up turlari va xususiyatlari
enum PowerUpType {
  // ==================== KUCH ====================
  speedBoost(
    id: 'speed_boost',
    name: 'Speed Boost',
    description: 'Tezlikni 50% oshiradi (5 soniya)',
    duration: 5.0,
    color: Color(0xFFFFEB3B),
    icon: '⚡',
    rarity: PowerUpRarity.common,
  ),

  magnetism(
    id: 'magnetism',
    name: 'Magnetism',
    description: 'Ovqatlar avtomatik tortiladi (8 soniya)',
    duration: 8.0,
    color: Color(0xFF2196F3),
    icon: '🧲',
    rarity: PowerUpRarity.common,
  ),

  invincibility(
    id: 'invincibility',
    name: 'Shield',
    description: 'Bir marta to\'qnashuvdan himoya',
    duration: 10.0,
    color: Color(0xFF00BCD4),
    icon: '🛡️',
    rarity: PowerUpRarity.rare,
  ),

  // ==================== O'SISH ====================
  instantGrowth(
    id: 'instant_growth',
    name: 'Instant Growth',
    description: '+50 segment darhol',
    duration: 0.0, // Instant
    color: Color(0xFF4CAF50),
    icon: '📈',
    rarity: PowerUpRarity.uncommon,
  ),

  doublePoints(
    id: 'double_points',
    name: 'Double Points',
    description: '2x score (10 soniya)',
    duration: 10.0,
    color: Color(0xFFFF9800),
    icon: '💎',
    rarity: PowerUpRarity.uncommon,
  ),

  // ==================== MAXSUS ====================
  ghost(
    id: 'ghost',
    name: 'Ghost Mode',
    description: 'Boshqa ilonlar orqali o\'tish (6 soniya)',
    duration: 6.0,
    color: Color(0xFF9C27B0),
    icon: '👻',
    rarity: PowerUpRarity.epic,
  ),

  bomb(
    id: 'bomb',
    name: 'Bomb',
    description: 'Atrofdagi kichik ilonlarni yo\'q qilish',
    duration: 0.0, // Instant
    color: Color(0xFFF44336),
    icon: '💣',
    rarity: PowerUpRarity.rare,
  ),

  teleport(
    id: 'teleport',
    name: 'Teleport',
    description: 'Random xavfsiz joyga teleport',
    duration: 0.0, // Instant
    color: Color(0xFFE91E63),
    icon: '🌀',
    rarity: PowerUpRarity.epic,
  ),

  // ==================== LEGENDARY ====================
  timeFreeze(
    id: 'time_freeze',
    name: 'Time Freeze',
    description: 'Barcha ilonlar 3 soniya muzlaydi',
    duration: 3.0,
    color: Color(0xFF00E5FF),
    icon: '❄️',
    rarity: PowerUpRarity.legendary,
  ),

  megaGrowth(
    id: 'mega_growth',
    name: 'Mega Growth',
    description: '+200 segment va 3x radius',
    duration: 15.0,
    color: Color(0xFFFFD700),
    icon: '👑',
    rarity: PowerUpRarity.legendary,
  );

  final String id;
  final String name;
  final String description;
  final double duration; // 0 = instant
  final Color color;
  final String icon;
  final PowerUpRarity rarity;

  const PowerUpType({
    required this.id,
    required this.name,
    required this.description,
    required this.duration,
    required this.color,
    required this.icon,
    required this.rarity,
  });

  bool get isInstant => duration == 0.0;
  bool get isDuration => duration > 0.0;
}

// ==================== POWER-UP RARITY ====================

enum PowerUpRarity {
  common(
    spawnChance: 0.70, // 70%
    color: Color(0xFF9E9E9E),
    glowIntensity: 0.3,
  ),
  uncommon(
    spawnChance: 0.20, // 20%
    color: Color(0xFF4CAF50),
    glowIntensity: 0.5,
  ),
  rare(
    spawnChance: 0.07, // 7%
    color: Color(0xFF2196F3),
    glowIntensity: 0.7,
  ),
  epic(
    spawnChance: 0.025, // 2.5%
    color: Color(0xFF9C27B0),
    glowIntensity: 0.85,
  ),
  legendary(
    spawnChance: 0.005, // 0.5%
    color: Color(0xFFFFD700),
    glowIntensity: 1.0,
  );

  final double spawnChance;
  final Color color;
  final double glowIntensity;

  const PowerUpRarity({
    required this.spawnChance,
    required this.color,
    required this.glowIntensity,
  });
}

// ==================== SPAWN HELPER ====================

class PowerUpSpawner {
  static PowerUpType getRandomPowerUp() {
    final random = dart_math.Random();
    final chance = random.nextDouble();

    double accumulated = 0.0;

    for (final type in PowerUpType.values) {
      accumulated += type.rarity.spawnChance;
      if (chance <= accumulated) {
        return type;
      }
    }

    return PowerUpType.speedBoost; // Fallback
  }

  /// Rarity bo'yicha spawn ehtimoli
  static PowerUpType? trySpawn() {
    final random = dart_math.Random();

    // 5% ehtimol bilan power-up spawn bo'ladi
    if (random.nextDouble() > 0.05) {
      return null;
    }

    return getRandomPowerUp();
  }
}
