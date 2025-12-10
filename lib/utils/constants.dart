import 'package:flutter/material.dart';

// =============================================================================
// GAME CONSTANTS - O'yin uchun doimiy qiymatlar
// =============================================================================

class GameConstants {
  // ---------------------------------------------------------------------------
  // GRID SETTINGS - Maydon sozlamalari
  // ---------------------------------------------------------------------------
  static const int gridWidth = 20;  // Maydon kengligi (20 katak)
  static const int gridHeight = 20; // Maydon balandligi (20 katak)
  static const double cellSize = 15.0; // Har bir katak o'lchami (15 piksel)

  // ---------------------------------------------------------------------------
  // GAME SPEED - O'yin tezligi (sekundlarda)
  // ---------------------------------------------------------------------------
  static const double initialSpeed = 0.15; // Boshlang'ich tezlik (0.15 sek = har 150ms da yangilanadi)
  static const double minSpeed = 0.08;     // Maksimal tezlik (eng tez)
  static const double speedIncrease = 0.002; // Har ovqatda tezlik oshishi

  // ---------------------------------------------------------------------------
  // SCORES - Ochkolar
  // ---------------------------------------------------------------------------
  static const int normalAppleScore = 10;  // Oddiy olma
  static const int goldenAppleScore = 50;  // Oltin olma
  static const int powerAppleScore = 25;   // Power olma

  // ---------------------------------------------------------------------------
  // FOOD SPAWN CHANCES - Ovqat paydo bo'lish ehtimolligi (%)
  // ---------------------------------------------------------------------------
  static const int normalAppleChance = 70;  // 70% oddiy olma
  static const int goldenAppleChance = 25;  // 25% oltin olma
  static const int powerAppleChance = 5;    // 5% power olma

  // ---------------------------------------------------------------------------
  // POWER-UP DURATION - Power-up davomiyligi (sekundlarda)
  // ---------------------------------------------------------------------------
  static const double powerUpDuration = 3.0; // 3 soniya 2x ochko

  // ---------------------------------------------------------------------------
  // SNAKE STAGES - Ilon bosqichlari (ochko bo'yicha)
  // ---------------------------------------------------------------------------
  static const int stage2Score = 100;  // 2-bosqich (Ko'k ilon)
  static const int stage3Score = 300;  // 3-bosqich (Oltin ilon)
  static const int stage4Score = 500;  // 4-bosqich (Champion ilon)

  // ---------------------------------------------------------------------------
  // COLORS - Ranglar
  // ---------------------------------------------------------------------------

  // Background colors
  static const Color backgroundColor = Color(0xFF1A1A2E);
  static const Color gridColor = Color(0xFF16213E);

  // Snake colors (har bosqich uchun)
  static const Color snakeStage1Color = Color(0xFF4ECCA3); // Yashil
  static const Color snakeStage2Color = Color(0xFF45B7D1); // Ko'k
  static const Color snakeStage3Color = Color(0xFFFFC107); // Oltin
  static const Color snakeStage4Color = Color(0xFFE91E63); // Pushti (Champion)

  // Food colors
  static const Color normalAppleColor = Color(0xFFFF6B6B); // Qizil
  static const Color goldenAppleColor = Color(0xFFFFD93D); // Oltin
  static const Color powerAppleColor = Color(0xFF6BCB77);  // Yashil

  // UI colors
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color secondaryColor = Color(0xFF4ECCA3);
  static const Color accentColor = Color(0xFFFFD93D);
  static const Color textColor = Color(0xFFFFFFFF);
  static const Color textSecondaryColor = Color(0xFFB0B0B0);

  // ---------------------------------------------------------------------------
  // COINS - Coin hisoblash
  // ---------------------------------------------------------------------------
  static const int coinsPerTenPoints = 1; // Har 10 ochkoga 1 coin

  // Milestone bonuses (bonus coinlar)
  static const Map<int, int> milestoneBonus = {
    50: 10,   // 50 ochko = +10 coins
    100: 25,  // 100 ochko = +25 coins
    300: 75,  // 300 ochko = +75 coins
    500: 150, // 500 ochko = +150 coins
  };

  // ---------------------------------------------------------------------------
  // DAILY REWARDS - Kunlik mukofotlar
  // ---------------------------------------------------------------------------
  static const int dailyReward = 20;        // Har kuni 1 o'yin = 20 coins
  static const int streakReward3Days = 50;  // 3 kun ketma-ket = 50 coins
  static const int streakReward7Days = 100; // 7 kun ketma-ket = 100 coins

  // ---------------------------------------------------------------------------
  // SKINS - Skin narxlari
  // ---------------------------------------------------------------------------
  static const Map<String, int> skinPrices = {
    'green': 0,      // Default - bepul
    'blue': 0,       // 100 ochkoda ochiladi
    'yellow': 0,     // 200 ochkoda ochiladi
    'red': 100,      // 100 coins
    'pink': 100,     // 100 coins
    'orange': 150,   // 150 coins
    'gradient': 200, // 200 coins
    'neon': 300,     // 300 coins
    'uzbek': 400,    // 400 coins
    'diamond': 500,  // 500 coins
  };

  // ---------------------------------------------------------------------------
  // ACHIEVEMENTS
  // ---------------------------------------------------------------------------
  static const Map<String, int> achievementRewards = {
    'first_game': 10,
    'score_50': 20,
    'score_100': 30,
    'score_200': 50,
    'score_300': 75,
    'score_500': 150,
    'score_1000': 300,
    'golden_apple': 25,
    'power_apple': 25,
    'eat_20_foods': 40,
    'play_10_games': 50,
    'play_3_days_streak': 60,
    'eat_50_foods': 100,
    'play_50_games': 200,
    'unlock_all_skins': 500,
  };

  // ---------------------------------------------------------------------------
  // ANIMATION DURATIONS
  // ---------------------------------------------------------------------------
  static const int buttonAnimationDuration = 200;
  static const int pageTransitionDuration = 300;
  static const int gameOverAnimationDuration = 500;

  // ---------------------------------------------------------------------------
  // SOUND SETTINGS
  // ---------------------------------------------------------------------------
  static const double defaultVolume = 0.7;
  static const double musicVolume = 0.4;
}