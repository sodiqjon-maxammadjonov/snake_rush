import 'package:shared_preferences/shared_preferences.dart';
import '../models/difficulty.dart';

// =============================================================================
// STORAGE MANAGER - Ma'lumotlarni saqlash va yuklash
// =============================================================================

class StorageManager {
  static StorageManager? _instance;
  static StorageManager get instance {
    _instance ??= StorageManager._();
    return _instance!;
  }

  StorageManager._();

  SharedPreferences? _prefs;

  // Initialize
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ---------------------------------------------------------------------------
  // COINS - Coinlar
  // ---------------------------------------------------------------------------

  Future<void> addCoins(int amount) async {
    final current = getCoins();
    await _prefs?.setInt('coins', current + amount);
  }

  int getCoins() {
    return _prefs?.getInt('coins') ?? 0;
  }

  Future<void> spendCoins(int amount) async {
    final current = getCoins();
    if (current >= amount) {
      await _prefs?.setInt('coins', current - amount);
    }
  }

  // ---------------------------------------------------------------------------
  // BEST SCORE - Eng yaxshi natija (har difficulty uchun alohida)
  // ---------------------------------------------------------------------------

  Future<bool> saveBestScore(int score, Difficulty difficulty) async {
    final key = 'best_score_${difficulty.name.toLowerCase()}';
    final currentBest = getBestScore(difficulty);
    if (score > currentBest) {
      await _prefs?.setInt(key, score);
      return true; // Yangi rekord!
    }
    return false;
  }

  int getBestScore([Difficulty? difficulty]) {
    if (difficulty == null) {
      // Umumiy eng yaxshi score (barcha difficultdan)
      final easy = _prefs?.getInt('best_score_oson') ?? 0;
      final medium = _prefs?.getInt('best_score_o\'rtacha') ?? 0;
      final hard = _prefs?.getInt('best_score_qiyin') ?? 0;
      return [easy, medium, hard].reduce((a, b) => a > b ? a : b);
    } else {
      final key = 'best_score_${difficulty.name.toLowerCase()}';
      return _prefs?.getInt(key) ?? 0;
    }
  }

  // ---------------------------------------------------------------------------
  // SKINS - Skinlar
  // ---------------------------------------------------------------------------

  Future<void> unlockSkin(String skinId) async {
    final unlocked = getUnlockedSkins();
    if (!unlocked.contains(skinId)) {
      unlocked.add(skinId);
      await _prefs?.setStringList('unlocked_skins', unlocked);
    }
  }

  List<String> getUnlockedSkins() {
    return _prefs?.getStringList('unlocked_skins') ?? ['green'];
  }

  bool isSkinUnlocked(String skinId) {
    return getUnlockedSkins().contains(skinId);
  }

  // ---------------------------------------------------------------------------
  // SELECTED SKIN - Tanlangan skin
  // ---------------------------------------------------------------------------

  Future<void> setSelectedSkin(String skinId) async {
    await _prefs?.setString('selected_skin', skinId);
  }

  String getSelectedSkin() {
    return _prefs?.getString('selected_skin') ?? 'green';
  }

  // ---------------------------------------------------------------------------
  // ACHIEVEMENTS - Achievementlar
  // ---------------------------------------------------------------------------

  Future<void> unlockAchievement(String achievementId) async {
    final unlocked = getUnlockedAchievements();
    if (!unlocked.contains(achievementId)) {
      unlocked.add(achievementId);
      await _prefs?.setStringList('unlocked_achievements', unlocked);
    }
  }

  List<String> getUnlockedAchievements() {
    return _prefs?.getStringList('unlocked_achievements') ?? [];
  }

  bool isAchievementUnlocked(String achievementId) {
    return getUnlockedAchievements().contains(achievementId);
  }

  // ---------------------------------------------------------------------------
  // STATISTICS - Statistika
  // ---------------------------------------------------------------------------

  Future<void> incrementGamesPlayed() async {
    final current = getGamesPlayed();
    await _prefs?.setInt('games_played', current + 1);
  }

  int getGamesPlayed() {
    return _prefs?.getInt('games_played') ?? 0;
  }

  Future<void> incrementTotalFoodEaten() async {
    final current = getTotalFoodEaten();
    await _prefs?.setInt('total_food_eaten', current + 1);
  }

  int getTotalFoodEaten() {
    return _prefs?.getInt('total_food_eaten') ?? 0;
  }

  // ---------------------------------------------------------------------------
  // DAILY STREAK - Kunlik ketma-ketlik
  // ---------------------------------------------------------------------------

  Future<void> updateDailyStreak() async {
    final lastPlayDate = getLastPlayDate();
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month}-${today.day}';

    if (lastPlayDate == todayString) {
      // Bugun allaqachon o'ynagan
      return;
    }

    final yesterday = today.subtract(const Duration(days: 1));
    final yesterdayString = '${yesterday.year}-${yesterday.month}-${yesterday.day}';

    if (lastPlayDate == yesterdayString) {
      // Kecha ham o'ynagan - streak davom etadi
      final currentStreak = getDailyStreak();
      await _prefs?.setInt('daily_streak', currentStreak + 1);
    } else {
      // Streak uzildi - qaytadan boshlash
      await _prefs?.setInt('daily_streak', 1);
    }

    await _prefs?.setString('last_play_date', todayString);
  }

  int getDailyStreak() {
    return _prefs?.getInt('daily_streak') ?? 0;
  }

  String getLastPlayDate() {
    return _prefs?.getString('last_play_date') ?? '';
  }

  // ---------------------------------------------------------------------------
  // SETTINGS - Sozlamalar
  // ---------------------------------------------------------------------------

  Future<void> setSoundEnabled(bool enabled) async {
    await _prefs?.setBool('sound_enabled', enabled);
  }

  bool isSoundEnabled() {
    return _prefs?.getBool('sound_enabled') ?? true;
  }

  Future<void> setMusicEnabled(bool enabled) async {
    await _prefs?.setBool('music_enabled', enabled);
  }

  bool isMusicEnabled() {
    return _prefs?.getBool('music_enabled') ?? true;
  }

  // ---------------------------------------------------------------------------
  // REVIVE SYSTEM - Qayta tirilish
  // ---------------------------------------------------------------------------

  // Bugungi bepul revive ishlatilganmi
  bool hasUsedFreeReviveToday() {
    final lastReviveDate = _prefs?.getString('last_free_revive_date') ?? '';
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month}-${today.day}';
    return lastReviveDate == todayString;
  }

  // Bepul revive ishlatish
  Future<void> useFreeRevive() async {
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month}-${today.day}';
    await _prefs?.setString('last_free_revive_date', todayString);
  }

  // Jami revive soni
  Future<void> incrementTotalRevives() async {
    final current = getTotalRevives();
    await _prefs?.setInt('total_revives', current + 1);
  }

  int getTotalRevives() {
    return _prefs?.getInt('total_revives') ?? 0;
  }

  // ---------------------------------------------------------------------------
  // RESET - Hammasini o'chirish (debug uchun)
  // ---------------------------------------------------------------------------

  Future<void> resetAll() async {
    await _prefs?.clear();
  }
}