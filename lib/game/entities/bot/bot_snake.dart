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
  bool _isCircling = false;
  double _circleAngle = 0.0;

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

    final dangerousEnemy = _findDangerousEnemy(nearbyEnemies);
    if (dangerousEnemy != null) {
      _evadeEnemy(dangerousEnemy);
      return;
    }

    final weakEnemy = _findWeakEnemy(nearbyEnemies);
    if (weakEnemy != null && _shouldAttack(weakEnemy)) {
      _huntEnemy(weakEnemy);
      return;
    }

    _seekFood();
  }

  void _updateBoostBehavior() {
    if (difficulty == BotDifficulty.hard && boostEnergy > 60) {
      if (_targetEnemy != null && !_isEvading) {
        setBoost(true);
      } else {
        setBoost(false);
      }
    } else if (difficulty == BotDifficulty.medium && boostEnergy > 80) {
      if (_isEvading && math.Random().nextDouble() < 0.3) {
        setBoost(true);
      } else {
        setBoost(false);
      }
    } else {
      setBoost(false);
    }
  }

  void _seekFood() {
    _isEvading = false;
    _isCircling = false;

    final foodInRange = _findNearestFood();

    if (foodInRange != null) {
      _targetFood = foodInRange;
      final direction = (foodInRange - position).normalized();
      targetDirection = _avoidWalls(direction);
    } else {
      _wanderSmart();
    }
  }

  void _evadeEnemy(Snake enemy) {
    _isEvading = true;
    _isCircling = false;
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

  void _huntEnemy(Snake enemy) {
    _isEvading = false;
    _targetEnemy = enemy;

    if (difficulty == BotDifficulty.hard) {
      _circleAndAttack(enemy);
    } else {
      _directChase(enemy);
    }
  }

  void _circleAndAttack(Snake enemy) {
    _isCircling = true;

    final toEnemy = enemy.position - position;
    final distance = toEnemy.length;

    if (distance < currentRadius * 5) {
      _circleAngle += 0.05;

      final circleRadius = currentRadius * 4;
      final circleX = enemy.position.x + math.cos(_circleAngle) * circleRadius;
      final circleY = enemy.position.y + math.sin(_circleAngle) * circleRadius;

      final circleTarget = Vector2(circleX, circleY);
      targetDirection = (circleTarget - position).normalized();
    } else {
      _directChase(enemy);
    }
  }

  void _directChase(Snake enemy) {
    _isCircling = false;

    Vector2 predictedPos = enemy.position + (enemy.direction * currentRadius * 2);

    final chaseDirection = (predictedPos - position).normalized();
    targetDirection = _avoidWalls(chaseDirection);
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

  Snake? _findDangerousEnemy(List<Snake> enemies) {
    for (final enemy in enemies) {
      if (enemy.currentRadius > currentRadius * 1.4) {
        return enemy;
      }
    }
    return null;
  }

  Snake? _findWeakEnemy(List<Snake> enemies) {
    Snake? weakest;
    double minRadius = double.infinity;

    for (final enemy in enemies) {
      if (enemy.currentRadius < currentRadius * 0.6 &&
          enemy.currentRadius < minRadius) {
        weakest = enemy;
        minRadius = enemy.currentRadius;
      }
    }

    return weakest;
  }

  bool _shouldAttack(Snake enemy) {
    if (currentRadius < enemy.currentRadius * 1.3) return false;

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
  ),
  medium(
    reactionTime: 0.3,
    attackProbability: 0.6,
    evasionSkill: 0.7,
  ),
  hard(
    reactionTime: 0.15,
    attackProbability: 0.85,
    evasionSkill: 0.95,
  );

  final double reactionTime;
  final double attackProbability;
  final double evasionSkill;

  const BotDifficulty({
    required this.reactionTime,
    required this.attackProbability,
    required this.evasionSkill,
  });
}