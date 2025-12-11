import 'package:flutter/material.dart';

// =============================================================================
// DIFFICULTY ENUM - Qiyinchilik darajalari
// =============================================================================

enum Difficulty {
  easy,    // Oson
  medium,  // O'rtacha
  hard,    // Qiyin
}

// Difficulty uchun yordamchi extension
extension DifficultyExtension on Difficulty {
  // Boshlang'ich tezlik
  double get initialSpeed {
    switch (this) {
      case Difficulty.easy:
        return 0.20; // Juda sekin (200ms)
      case Difficulty.medium:
        return 0.15; // O'rtacha (150ms)
      case Difficulty.hard:
        return 0.10; // Tez (100ms)
    }
  }

  // Minimal tezlik (eng tez)
  double get minSpeed {
    switch (this) {
      case Difficulty.easy:
        return 0.12; // 120ms (sekinroq)
      case Difficulty.medium:
        return 0.08; // 80ms (o'rtacha)
      case Difficulty.hard:
        return 0.05; // 50ms (juda tez!)
    }
  }

  // Har ovqatda tezlik oshishi
  double get speedIncrease {
    switch (this) {
      case Difficulty.easy:
        return 0.001; // Sekin tezlashadi
      case Difficulty.medium:
        return 0.002; // O'rtacha tezlashadi
      case Difficulty.hard:
        return 0.003; // Tez tezlashadi
    }
  }

  // Ochko multiplier (koeffitsient)
  double get scoreMultiplier {
    switch (this) {
      case Difficulty.easy:
        return 1.0; // x1 (oddiy)
      case Difficulty.medium:
        return 1.5; // x1.5 (50% ko'proq)
      case Difficulty.hard:
        return 2.0; // x2 (2 barobar ko'p!)
    }
  }

  // Coin multiplier
  double get coinMultiplier {
    switch (this) {
      case Difficulty.easy:
        return 1.0; // x1
      case Difficulty.medium:
        return 1.5; // x1.5
      case Difficulty.hard:
        return 2.5; // x2.5 (2.5 barobar!)
    }
  }

  // Nomi
  String get name {
    switch (this) {
      case Difficulty.easy:
        return 'Oson';
      case Difficulty.medium:
        return 'O\'rtacha';
      case Difficulty.hard:
        return 'Qiyin';
    }
  }

  // Tavsif
  String get description {
    switch (this) {
      case Difficulty.easy:
        return 'Boshlovchilar uchun';
      case Difficulty.medium:
        return 'Standart rejim';
      case Difficulty.hard:
        return 'Tajribalilar uchun';
    }
  }

  // Emoji
  String get emoji {
    switch (this) {
      case Difficulty.easy:
        return '😊';
      case Difficulty.medium:
        return '😎';
      case Difficulty.hard:
        return '🔥';
    }
  }

  // Rang
  Color get color {
    switch (this) {
      case Difficulty.easy:
        return const Color(0xFF4ECCA3); // Yashil
      case Difficulty.medium:
        return const Color(0xFFFFD93D); // Sariq
      case Difficulty.hard:
        return const Color(0xFFFF6B6B); // Qizil
    }
  }
}