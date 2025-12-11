import 'storage.dart';
import 'constants.dart';
import '../models/difficulty.dart';

// =============================================================================
// ACHIEVEMENT CHECKER - Achievement tekshirish va mukofot berish
// =============================================================================

class AchievementChecker {
  final StorageManager _storage = StorageManager.instance;

  // O'yin tugaganda achievementlarni tekshirish
  Future<List<Achievement>> checkAchievements({
    required int score,
    required int foodEaten,
    required Difficulty difficulty,
  }) async {
    final List<Achievement> newAchievements = [];

    // Birinchi o'yin
    if (_storage.getGamesPlayed() == 1) {
      if (await _unlockAchievement('first_game')) {
        newAchievements.add(Achievement(
          id: 'first_game',
          name: 'Birinchi O\'yin',
          description: 'Birinchi marta o\'ynash',
          reward: 10,
        ));
      }
    }

    // Score achievementlari (difficulty bo'yicha ko'payadi)
    final scoreMultiplier = difficulty.scoreMultiplier;

    if (score >= (50 * scoreMultiplier) && await _unlockAchievement('score_50_${difficulty.name}')) {
      newAchievements.add(Achievement(
        id: 'score_50_${difficulty.name}',
        name: '50 Ochko (${difficulty.emoji} ${difficulty.name})',
        description: '${difficulty.name} rejimida 50 ochkoga yetish',
        reward: (20 * difficulty.coinMultiplier).round(),
      ));
    }

    if (score >= (100 * scoreMultiplier) && await _unlockAchievement('score_100_${difficulty.name}')) {
      newAchievements.add(Achievement(
        id: 'score_100_${difficulty.name}',
        name: '100 Ochko (${difficulty.emoji} ${difficulty.name})',
        description: '${difficulty.name} rejimida 100 ochkoga yetish',
        reward: (30 * difficulty.coinMultiplier).round(),
      ));
    }

    if (score >= (200 * scoreMultiplier) && await _unlockAchievement('score_200_${difficulty.name}')) {
      newAchievements.add(Achievement(
        id: 'score_200_${difficulty.name}',
        name: '200 Ochko (${difficulty.emoji} ${difficulty.name})',
        description: '${difficulty.name} rejimida 200 ochkoga yetish',
        reward: (50 * difficulty.coinMultiplier).round(),
      ));
    }

    if (score >= (300 * scoreMultiplier) && await _unlockAchievement('score_300_${difficulty.name}')) {
      newAchievements.add(Achievement(
        id: 'score_300_${difficulty.name}',
        name: '300 Ochko (${difficulty.emoji} ${difficulty.name})',
        description: '${difficulty.name} rejimida 300 ochkoga yetish',
        reward: (75 * difficulty.coinMultiplier).round(),
      ));
    }

    if (score >= (500 * scoreMultiplier) && await _unlockAchievement('score_500_${difficulty.name}')) {
      newAchievements.add(Achievement(
        id: 'score_500_${difficulty.name}',
        name: '500 Ochko (${difficulty.emoji} ${difficulty.name})',
        description: '${difficulty.name} rejimida 500 ochkoga yetish',
        reward: (150 * difficulty.coinMultiplier).round(),
      ));
    }

    if (score >= (1000 * scoreMultiplier) && await _unlockAchievement('score_1000_${difficulty.name}')) {
      newAchievements.add(Achievement(
        id: 'score_1000_${difficulty.name}',
        name: '1000 Ochko! (${difficulty.emoji} ${difficulty.name})',
        description: '${difficulty.name} rejimida 1000 ochkoga yetish - Master!',
        reward: (300 * difficulty.coinMultiplier).round(),
      ));
    }

    // Food eaten achievementlari
    if (foodEaten >= 20 && await _unlockAchievement('eat_20_foods')) {
      newAchievements.add(Achievement(
        id: 'eat_20_foods',
        name: 'Ochko\'xo\'r',
        description: 'Bir o\'yinda 20ta ovqat yeyish',
        reward: 40,
      ));
    }

    if (foodEaten >= 50 && await _unlockAchievement('eat_50_foods')) {
      newAchievements.add(Achievement(
        id: 'eat_50_foods',
        name: 'Super Ochko\'xo\'r',
        description: 'Bir o\'yinda 50ta ovqat yeyish',
        reward: 100,
      ));
    }

    // Games played achievementlari
    final gamesPlayed = _storage.getGamesPlayed();
    if (gamesPlayed >= 10 && await _unlockAchievement('play_10_games')) {
      newAchievements.add(Achievement(
        id: 'play_10_games',
        name: 'Doimiy O\'yinchi',
        description: '10ta o\'yin o\'ynash',
        reward: 50,
      ));
    }

    if (gamesPlayed >= 50 && await _unlockAchievement('play_50_games')) {
      newAchievements.add(Achievement(
        id: 'play_50_games',
        name: 'Veteran',
        description: '50ta o\'yin o\'ynash',
        reward: 200,
      ));
    }

    // Daily streak
    final streak = _storage.getDailyStreak();
    if (streak >= 3 && await _unlockAchievement('play_3_days_streak')) {
      newAchievements.add(Achievement(
        id: 'play_3_days_streak',
        name: 'Muntazam',
        description: '3 kun ketma-ket o\'ynash',
        reward: 60,
      ));
    }

    // HARD mode maxsus achievementlar
    if (difficulty == Difficulty.hard) {
      if (score >= 500 && await _unlockAchievement('hard_master')) {
        newAchievements.add(Achievement(
          id: 'hard_master',
          name: '🔥 QIYIN REJIM USTASI',
          description: 'Qiyin rejimda 500 ochko!',
          reward: 500,
        ));
      }
    }

    // Mukofotlarni coinlarga qo'shish
    for (final achievement in newAchievements) {
      await _storage.addCoins(achievement.reward);
    }

    return newAchievements;
  }

  // Achievement unlock qilish va coinlarni berish
  Future<bool> _unlockAchievement(String achievementId) async {
    if (!_storage.isAchievementUnlocked(achievementId)) {
      await _storage.unlockAchievement(achievementId);
      return true; // Yangi achievement!
    }
    return false;
  }

  // Score bo'yicha skinlarni ochish
  Future<void> checkScoreBasedUnlocks(int score) async {
    // 100 ochko - ko'k skin
    if (score >= 100 && !_storage.isSkinUnlocked('blue')) {
      await _storage.unlockSkin('blue');
    }

    // 200 ochko - sariq skin
    if (score >= 200 && !_storage.isSkinUnlocked('yellow')) {
      await _storage.unlockSkin('yellow');
    }
  }
}

// =============================================================================
// ACHIEVEMENT MODEL
// =============================================================================

class Achievement {
  final String id;
  final String name;
  final String description;
  final int reward;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.reward,
  });
}