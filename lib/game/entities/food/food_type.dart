import 'package:flutter/material.dart';

/// Ovqat turlari va ularning xususiyatlari
enum FoodType {
  small(
    points: 1,
    radius: 6,
    color: Color(0xFFFF6B9D),
    magnetRange: 80,
    spawnChance: 0.7, // 70% ehtimol
  ),
  medium(
    points: 3,
    radius: 9,
    color: Color(0xFF4ECDC4),
    magnetRange: 100,
    spawnChance: 0.9, // 90% gacha (20% gap)
  ),
  large(
    points: 8,
    radius: 12,
    color: Color(0xFFFFE66D),
    magnetRange: 130,
    spawnChance: 0.98, // 98% gacha (8% gap)
  ),
  super_(
    points: 25,
    radius: 16,
    color: Color(0xFFFF5722),
    magnetRange: 160,
    spawnChance: 1.0, // Qolgan 2%
  );

  final int points;
  final double radius;
  final Color color;
  final double magnetRange;
  final double spawnChance;

  const FoodType({
    required this.points,
    required this.radius,
    required this.color,
    required this.magnetRange,
    required this.spawnChance,
  });

  /// Random ovqat turini tanlash (ehtimolga asosan)
  static FoodType getRandomType(double chance) {
    if (chance < small.spawnChance) return small;
    if (chance < medium.spawnChance) return medium;
    if (chance < large.spawnChance) return large;
    return super_;
  }
}