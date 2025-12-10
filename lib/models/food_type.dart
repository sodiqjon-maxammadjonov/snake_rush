import 'package:flutter/material.dart';
import '../utils/constants.dart';

enum FoodType {
  normal,
  golden,
  power,
}

extension FoodTypeExtension on FoodType {
  Color get color {
    switch (this) {
      case FoodType.normal:
        return GameConstants.normalAppleColor;
      case FoodType.golden:
        return GameConstants.goldenAppleColor;
      case FoodType.power:
        return GameConstants.powerAppleColor;
    }
  }

  int get score {
    switch (this) {
      case FoodType.normal:
        return GameConstants.normalAppleScore;
      case FoodType.golden:
        return GameConstants.goldenAppleScore;
      case FoodType.power:
        return GameConstants.powerAppleScore;
    }
  }

  int get growth {
    switch (this) {
      case FoodType.normal:
        return 1;
      case FoodType.golden:
        return 2;
      case FoodType.power:
        return 1;
    }
  }

  bool get isPowerUp {
    return this == FoodType.power;
  }

  // Ovqat nomini qaytaradi
  String get name {
    switch (this) {
      case FoodType.normal:
        return 'Oddiy Olma';
      case FoodType.golden:
        return 'Oltin Olma';
      case FoodType.power:
        return 'Power Olma';
    }
  }

  // Emoji ko'rinishda
  String get emoji {
    switch (this) {
      case FoodType.normal:
        return '🍎';
      case FoodType.golden:
        return '🌟';
      case FoodType.power:
        return '⚡';
    }
  }
}