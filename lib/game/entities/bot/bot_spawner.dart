import 'dart:math' as math;
import 'package:flame/components.dart';
import '../../world/game_map.dart';
import '../food/food_manager.dart';
import '../../managers/collision_manager.dart';
import 'bot_snake.dart';

/// Bot spawn va boshqaruv tizimi
class BotSpawner extends Component {
  final GameMap map;
  final FoodManager foodManager;
  final CollisionManager collisionManager;

  final List<BotSnake> _activeBots = [];
  final int _maxBots = 15; // Maksimal bot soni

  double _spawnTimer = 0.0;
  final double _spawnInterval = 10.0; // Har 10 soniyada spawn

  final math.Random _random = math.Random();

  BotSpawner({
    required this.map,
    required this.foodManager,
    required this.collisionManager,
  });

  @override
  void update(double dt) {
    super.update(dt);

    // O'lgan botlarni tozalash
    _activeBots.removeWhere((bot) => bot.isRemoved);

    // Yangi bot spawn qilish
    _spawnTimer += dt;
    if (_spawnTimer >= _spawnInterval && _activeBots.length < _maxBots) {
      _spawnTimer = 0.0;
      _spawnBot();
    }
  }

  // ==================== SPAWN LOGIC ====================

  /// Yangi bot yaratish
  Future<void> _spawnBot() async {
    final config = _generateBotConfig();

    final bot = BotSnake(
      map: map,
      foodManager: foodManager,
      collisionManager: collisionManager,
      difficulty: config.difficulty,
      startScore: config.startScore,
      name: config.name,
    );

    await parent?.add(bot);
    _activeBots.add(bot);
    collisionManager.registerSnake(bot);
  }

  /// Bot konfiguratsiyasini yaratish
  BotConfig _generateBotConfig() {
    // Qiyinlik tanlash (ko'pchilik easy/medium)
    final difficultyRand = _random.nextDouble();
    BotDifficulty difficulty;

    if (difficultyRand < 0.60) {
      difficulty = BotDifficulty.easy;
    } else if (difficultyRand < 0.90) {
      difficulty = BotDifficulty.medium;
    } else {
      difficulty = BotDifficulty.hard;
    }

    // Boshlang'ich score (har xil o'lchamda)
    final startScore = _getRandomScore(difficulty);

    // Random ism
    final name = _getRandomName();

    return BotConfig(
      difficulty: difficulty,
      startScore: startScore,
      name: name,
    );
  }

  /// Qiyinlikka qarab random score
  double _getRandomScore(BotDifficulty difficulty) {
    switch (difficulty) {
      case BotDifficulty.easy:
      // 50-800 (juda kichik)
        return 50 + _random.nextDouble() * 750;

      case BotDifficulty.medium:
      // 200-1500 (kichik-o'rta)
        return 200 + _random.nextDouble() * 1300;

      case BotDifficulty.hard:
      // 800-3000 (o'rta-katta)
        return 800 + _random.nextDouble() * 2200;
    }
  }

  /// Random bot ismi
  String _getRandomName() {
    final names = [
      // Ilon nomlari
      'Viper', 'Python', 'Cobra', 'Mamba', 'Anaconda',
      'Rattler', 'Adder', 'Boa', 'Asp', 'Krait',

      // Qo'rqinchli nomlar
      'Shadow', 'Phantom', 'Ghost', 'Reaper', 'Demon',
      'Titan', 'Beast', 'Monster', 'Hunter', 'Predator',

      // Kuchli nomlar
      'Rex', 'King', 'Lord', 'Master', 'Champion',
      'Warrior', 'Knight', 'Dragon', 'Phoenix', 'Thunder',

      // Cool nomlar
      'Neon', 'Blaze', 'Storm', 'Frost', 'Nova',
      'Laser', 'Pulse', 'Volt', 'Surge', 'Shock',
    ];

    final name = names[_random.nextInt(names.length)];
    final number = _random.nextInt(999) + 1;

    return '$name$number';
  }

  // ==================== SPAWN STRATEGIES ====================

  /// Boshlang'ich spawn (o'yin boshida)
  Future<void> spawnInitialBots(int count) async {
    for (int i = 0; i < count && i < _maxBots; i++) {
      await _spawnBot();

      // Bir vaqtning o'zida juda ko'p spawn bo'lmasligi uchun
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  /// Muayyan qiyinlikda bot spawn qilish
  Future<void> spawnBotWithDifficulty(BotDifficulty difficulty) async {
    final config = BotConfig(
      difficulty: difficulty,
      startScore: _getRandomScore(difficulty),
      name: _getRandomName(),
    );

    final bot = BotSnake(
      map: map,
      foodManager: foodManager,
      collisionManager: collisionManager,
      difficulty: config.difficulty,
      startScore: config.startScore,
      name: config.name,
    );

    await parent?.add(bot);
    _activeBots.add(bot);
    collisionManager.registerSnake(bot);
  }

  /// Muayyan score bilan bot spawn qilish
  Future<void> spawnBotWithScore(double score) async {
    final difficulty = _getDifficultyByScore(score);

    final bot = BotSnake(
      map: map,
      foodManager: foodManager,
      collisionManager: collisionManager,
      difficulty: difficulty,
      startScore: score,
      name: _getRandomName(),
    );

    await parent?.add(bot);
    _activeBots.add(bot);
    collisionManager.registerSnake(bot);
  }

  BotDifficulty _getDifficultyByScore(double score) {
    if (score < 1000) return BotDifficulty.easy;
    if (score < 3000) return BotDifficulty.medium;
    return BotDifficulty.hard;
  }

  // ==================== BALANCE ====================

  /// O'yinchi score'iga qarab bot spawn qilish
  Future<void> balanceBotsForPlayer(double playerScore) async {
    // Agar o'yinchi katta bo'lsa, kuchliroq botlar spawn bo'ladi
    if (playerScore > 5000 && _activeBots.length < _maxBots) {
      // Hard botlar ko'proq spawn qilish
      if (_random.nextDouble() < 0.4) {
        await spawnBotWithDifficulty(BotDifficulty.hard);
      }
    } else if (playerScore < 1000) {
      // Agar o'yinchi kichik bo'lsa, easy botlar
      if (_random.nextDouble() < 0.6) {
        await spawnBotWithDifficulty(BotDifficulty.easy);
      }
    }
  }

  // ==================== QUERIES ====================

  List<BotSnake> get activeBots => List.unmodifiable(_activeBots);
  int get botCount => _activeBots.length;

  /// Eng katta bot
  BotSnake? get largestBot {
    if (_activeBots.isEmpty) return null;
    return _activeBots.reduce((a, b) =>
    a.totalScore > b.totalScore ? a : b
    );
  }

  /// Eng kichik bot
  BotSnake? get smallestBot {
    if (_activeBots.isEmpty) return null;
    return _activeBots.reduce((a, b) =>
    a.totalScore < b.totalScore ? a : b
    );
  }

  /// O'rtacha bot score
  double get averageBotScore {
    if (_activeBots.isEmpty) return 0;
    final total = _activeBots.fold<double>(
      0,
          (sum, bot) => sum + bot.totalScore,
    );
    return total / _activeBots.length;
  }

  // ==================== CLEANUP ====================

  void clearAllBots() {
    for (final bot in _activeBots) {
      collisionManager.unregisterSnake(bot);
      bot.removeFromParent();
    }
    _activeBots.clear();
  }
}

// ==================== BOT CONFIG ====================

class BotConfig {
  final BotDifficulty difficulty;
  final double startScore;
  final String name;

  BotConfig({
    required this.difficulty,
    required this.startScore,
    required this.name,
  });
}