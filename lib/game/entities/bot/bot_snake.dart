import 'dart:math' as math;
import 'package:flame/components.dart';
import '../../config/game_constants.dart';
import '../snake/snake.dart';
import '../food/food_manager.dart';
import '../../world/game_map.dart';
import '../../managers/collision_manager.dart';

class BotSnake extends Snake {
  final CollisionManager collisionManager;
  final String name;
  final BotDifficulty difficulty;
  final double? startScore;

  double _thinkTimer = 0.0;
  double _thinkInterval = 0.3;

  Vector2? _targetFood;
  Snake? _targetEnemy;
  bool _isEvading = false;
  bool _isTrapping = false; // Yangi: tuzoq qurish rejimi
  double _trapAngle = 0.0;
  Vector2? _trapCenter;

  BotSnake({
    required super.map,
    required super.foodManager,
    required this.collisionManager,
    this.difficulty = BotDifficulty.medium,
    this.startScore,
    this.name = 'Bot',
  }) : super(isPlayer: false);

  @override
  Future<void> onLoad() async {
    if (startScore != null) {
      score = startScore!;
    } else {
      score = _getRandomStartScore();
    }

    _thinkInterval = difficulty.reactionTime;

    await super.onLoad();
  }

  double _getRandomStartScore() {
    final random = math.Random();

    switch (difficulty) {
      case BotDifficulty.easy:
        return 50 + random.nextDouble() * 400;
      case BotDifficulty.medium:
        return 200 + random.nextDouble() * 800;
      case BotDifficulty.hard:
        return 500 + random.nextDouble() * 1500;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    _thinkTimer += dt;
    if (_thinkTimer >= _thinkInterval) {
      _thinkTimer = 0.0;
      _makeDecision();
    }

    _updateBoostBehavior();
  }

  void _makeDecision() {
    final nearbyEnemies = collisionManager.getSnakesInRadius(
      position,
      currentRadius * 10,
    );

    // 1. XAVFLI DUSHMAN - qoch!
    final dangerousEnemy = _findDangerousEnemy(nearbyEnemies);
    if (dangerousEnemy != null) {
      _evadeEnemy(dangerousEnemy);
      return;
    }

    // 2. KUCHSIZ DUSHMAN - tuzoq qur!
    final weakEnemy = _findWeakEnemy(nearbyEnemies);
    if (weakEnemy != null && _shouldAttack(weakEnemy)) {
      _trapEnemy(weakEnemy); // ✅ O'zgarish: to'g'ridan-to'g'ri hujum emas!
      return;
    }

    // 3. OVQAT YIG'ISH
    _seekFood();
  }

  void _updateBoostBehavior() {
    // Boost faqat qochishda va tuzoq qurishda ishlatiladi
    if (difficulty == BotDifficulty.hard && boostEnergy > 60) {
      if (_isEvading) {
        setBoost(true); // Qochishda boost
      } else if (_isTrapping && _targetEnemy != null) {
        setBoost(true); // Tuzoq qurishda boost
      } else {
        setBoost(false);
      }
    } else if (difficulty == BotDifficulty.medium && boostEnergy > 80) {
      if (_isEvading) {
        setBoost(true);
      } else {
        setBoost(false);
      }
    } else {
      setBoost(false);
    }
  }

  // ==================== YANGI: TUZOQ QURISH ====================

  /// Dushmanni tuzoqqa tushirish strategiyasi
  void _trapEnemy(Snake enemy) {
    _isEvading = false;
    _isTrapping = true;
    _targetEnemy = enemy;

    final toEnemy = enemy.position - position;
    final distance = toEnemy.length;

    // Agar yetarlicha yaqin bo'lsa, aylana chizish
    if (distance < currentRadius * 8) {
      _circleAroundEnemy(enemy);
    } else {
      // Uzoqdan yaqinlashish
      _approachFromSide(enemy);
    }
  }

  /// Dushman atrofida aylana chizish (tuzoq)
  void _circleAroundEnemy(Snake enemy) {
    // Dushman oldinga harakat qilayotgan yo'nalishini bashorat qilish
    final enemyFuturePos = enemy.position + (enemy.direction * currentRadius * 3);

    // Bot dushman oldida turishi kerak
    _trapAngle += difficulty.trapSpeed; // Aylana tezligi

    final circleRadius = currentRadius * 5; // Tuzoq radiusi
    final targetX = enemyFuturePos.x + math.cos(_trapAngle) * circleRadius;
    final targetY = enemyFuturePos.y + math.sin(_trapAngle) * circleRadius;

    final targetPos = Vector2(targetX, targetY);
    targetDirection = (targetPos - position).normalized();

    // Agar dushman juda yaqin kelsa, tanani oldinga cho'zish
    final distanceToEnemy = position.distanceTo(enemy.position);
    if (distanceToEnemy < currentRadius * 3) {
      // Dushmanni o'z tanasiga urilishga majburlash
      final blockDirection = (enemy.position - position).normalized();
      final perpendicular = Vector2(-blockDirection.y, blockDirection.x);

      // Dushman yo'lini to'sish
      targetDirection = perpendicular;
    }
  }

  /// Yon tomondan yaqinlashish
  void _approachFromSide(Snake enemy) {
    // Dushman yo'nalishini bashorat qilish
    final enemyDirection = enemy.direction;

    // Yon tomonga harakat qilish (dushman boshiga emas!)
    final perpendicular = Vector2(-enemyDirection.y, enemyDirection.x);

    // Dushmanning yon tomoniga borish
    final sidePosition = enemy.position + (perpendicular * currentRadius * 5);

    targetDirection = (sidePosition - position).normalized();
    targetDirection = _avoidWalls(targetDirection);
  }

  // ==================== QOCHISH (o'zgarishsiz) ====================

  void _evadeEnemy(Snake enemy) {
    _isEvading = true;
    _isTrapping = false;
    _targetEnemy = enemy;

    Vector2 escapeDirection = (position - enemy.position).normalized();

    final perpendicular = Vector2(-escapeDirection.y, escapeDirection.x);
    if (math.Random().nextDouble() < 0.5) {
      escapeDirection += perpendicular * 0.3;
    } else {
      escapeDirection -= perpendicular * 0.3;
    }

    targetDirection = _avoidWalls(escapeDirection.normalized());
  }

  // ==================== OVQAT YIGISH ====================

  void _seekFood() {
    _isEvading = false;
    _isTrapping = false;

    final foodInRange = _findNearestFood();

    if (foodInRange != null) {
      _targetFood = foodInRange;
      final direction = (foodInRange - position).normalized();
      targetDirection = _avoidWalls(direction);
    } else {
      _wanderSmart();
    }
  }

  void _wanderSmart() {
    if (math.Random().nextDouble() < 0.15) {
      final centerX = GameConstants.mapWidth / 2;
      final centerY = GameConstants.mapHeight / 2;
      final toCenter = Vector2(centerX, centerY) - position;

      if (toCenter.length > GameConstants.mapWidth * 0.3) {
        targetDirection = toCenter.normalized();
      } else {
        final randomAngle = math.Random().nextDouble() * math.pi * 2;
        targetDirection = Vector2(
          math.cos(randomAngle),
          math.sin(randomAngle),
        );
      }
    }
  }

  // ==================== DUSHMAN TOPISH ====================

  Snake? _findDangerousEnemy(List<Snake> enemies) {
    for (final enemy in enemies) {
      // Agar dushman bizdan 50% katta bo'lsa - xavfli!
      if (enemy.currentRadius > currentRadius * 1.5) {
        return enemy;
      }
    }
    return null;
  }

  Snake? _findWeakEnemy(List<Snake> enemies) {
    Snake? weakest;
    double minRadius = double.infinity;

    for (final enemy in enemies) {
      // Faqat bizdan 40% kichik dushmanlarga hujum qilamiz
      if (enemy.currentRadius < currentRadius * 0.6 &&
          enemy.currentRadius < minRadius) {
        weakest = enemy;
        minRadius = enemy.currentRadius;
      }
    }

    return weakest;
  }

  bool _shouldAttack(Snake enemy) {
    // Agar biz dushmandan kamida 40% katta bo'lsak, hujum qilamiz
    if (currentRadius < enemy.currentRadius * 1.4) return false;

    final attackChance = difficulty.attackProbability;
    return math.Random().nextDouble() < attackChance;
  }

  Vector2? _findNearestFood() {
    return null;
  }

  Vector2 _avoidWalls(Vector2 direction) {
    const safeMargin = 300.0;
    Vector2 avoidance = Vector2.zero();

    if (position.x < safeMargin) {
      avoidance.x += 1.5;
    } else if (position.x > map.width - safeMargin) {
      avoidance.x -= 1.5;
    }

    if (position.y < safeMargin) {
      avoidance.y += 1.5;
    } else if (position.y > map.height - safeMargin) {
      avoidance.y -= 1.5;
    }

    if (!avoidance.isZero()) {
      return (direction + avoidance).normalized();
    }

    return direction;
  }
}

enum BotDifficulty {
  easy(
    reactionTime: 0.5,
    attackProbability: 0.3,
    evasionSkill: 0.5,
    trapSpeed: 0.03, // Sekin tuzoq
  ),
  medium(
    reactionTime: 0.3,
    attackProbability: 0.6,
    evasionSkill: 0.7,
    trapSpeed: 0.05, // O'rtacha tuzoq
  ),
  hard(
    reactionTime: 0.15,
    attackProbability: 0.85,
    evasionSkill: 0.95,
    trapSpeed: 0.08, // Tez tuzoq
  );

  final double reactionTime;
  final double attackProbability;
  final double evasionSkill;
  final double trapSpeed; // Yangi: tuzoq qurish tezligi

  const BotDifficulty({
    required this.reactionTime,
    required this.attackProbability,
    required this.evasionSkill,
    required this.trapSpeed,
  });
}