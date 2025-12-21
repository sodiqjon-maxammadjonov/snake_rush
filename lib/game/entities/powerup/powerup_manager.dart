import 'dart:math' as math;
import 'package:flame/components.dart';
import '../../world/game_map.dart';
import '../../config/game_constants.dart';
import '../snake/snake.dart';
import 'powerup.dart';
import 'powerup_type.dart';

/// Power-up spawn va boshqaruv
class PowerUpManager extends Component {
  final GameMap map;

  final List<PowerUp> _activePowerUps = [];
  double _spawnTimer = 0.0;
  final double _spawnInterval = 8.0; // Har 8 soniyada spawn
  final math.Random _random = math.Random();

  // Active effects
  final Map<Snake, List<ActiveEffect>> _activeEffects = {};

  // Callbacks
  Function(Snake snake, PowerUpType type)? onPowerUpCollected;

  PowerUpManager({required this.map});

  @override
  void update(double dt) {
    super.update(dt);

    // Spawn timer
    _spawnTimer += dt;
    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0.0;
      _trySpawnPowerUp();
    }

    // Active effects update
    _updateActiveEffects(dt);
  }

  // ==================== SPAWNING ====================

  void _trySpawnPowerUp() {
    // Maksimal 5 ta power-up bir vaqtda
    if (_activePowerUps.length >= 5) return;

    final powerUpType = PowerUpSpawner.trySpawn();
    if (powerUpType == null) return;

    final position = _getRandomPosition();
    final powerUp = PowerUp(pos: position, type: powerUpType);

    _activePowerUps.add(powerUp);
    map.add(powerUp);
  }

  Vector2 _getRandomPosition() {
    const margin = 200.0;
    return Vector2(
      margin + _random.nextDouble() * (GameConstants.mapWidth - margin * 2),
      margin + _random.nextDouble() * (GameConstants.mapHeight - margin * 2),
    );
  }

  // ==================== COLLISION CHECK ====================

  void checkPowerUpCollisions(Snake snake, double dt) {
    for (int i = _activePowerUps.length - 1; i >= 0; i--) {
      final powerUp = _activePowerUps[i];
      final distance = powerUp.position.distanceTo(snake.position);

      // Magnet effect
      if (distance < snake.currentRadius * 5) {
        powerUp.pullTowards(snake.position, dt);
      }

      // Collection
      if (distance < snake.currentRadius + 20) {
        _collectPowerUp(snake, powerUp);
        powerUp.collect();
        _activePowerUps.removeAt(i);
      }
    }
  }

  // ==================== POWER-UP EFFECTS ====================

  void _collectPowerUp(Snake snake, PowerUp powerUp) {
    final type = powerUp.type;

    onPowerUpCollected?.call(snake, type);

    // Instant effects
    if (type.isInstant) {
      _applyInstantEffect(snake, type);
    }
    // Duration effects
    else {
      _applyDurationEffect(snake, type);
    }
  }

  void _applyInstantEffect(Snake snake, PowerUpType type) {
    switch (type) {
      case PowerUpType.instantGrowth:
        snake.grow(50 * 10); // 50 segment = 500 points
        break;

      case PowerUpType.bomb:
        _explosionEffect(snake.position);
        break;

      case PowerUpType.teleport:
        _teleportSnake(snake);
        break;

      default:
        break;
    }
  }

  void _applyDurationEffect(Snake snake, PowerUpType type) {
    // Active effects ro'yxatiga qo'shish
    _activeEffects.putIfAbsent(snake, () => []);

    final effect = ActiveEffect(
      type: type,
      remainingTime: type.duration,
    );

    _activeEffects[snake]!.add(effect);
  }

  void _updateActiveEffects(double dt) {
    for (final entry in _activeEffects.entries) {
      final snake = entry.key;
      final effects = entry.value;

      for (int i = effects.length - 1; i >= 0; i--) {
        final effect = effects[i];
        effect.remainingTime -= dt;

        // Effekt tugadi
        if (effect.remainingTime <= 0) {
          _removeEffect(snake, effect);
          effects.removeAt(i);
        }
      }
    }
  }

  void _removeEffect(Snake snake, ActiveEffect effect) {
    // Effekt tugaganda cleanup
    switch (effect.type) {
      case PowerUpType.megaGrowth:
      // Radius'ni normal holatga qaytarish
        break;
      default:
        break;
    }
  }

  // ==================== SPECIAL EFFECTS ====================

  void _explosionEffect(Vector2 center) {
    // TODO: Atrofdagi kichik snakelarni yo'q qilish
    // TODO: Particle effect
  }

  void _teleportSnake(Snake snake) {
    // Random xavfsiz joyga ko'chirish
    snake.position = _getRandomPosition();
  }

  // ==================== QUERIES ====================

  /// Snake uchun active effectlar
  List<PowerUpType> getActiveEffects(Snake snake) {
    return _activeEffects[snake]?.map((e) => e.type).toList() ?? [];
  }

  /// Ma'lum effect faolmi?
  bool hasEffect(Snake snake, PowerUpType type) {
    final effects = _activeEffects[snake];
    if (effects == null) return false;

    return effects.any((e) => e.type == type);
  }

  /// Effect qolgan vaqti
  double? getEffectRemainingTime(Snake snake, PowerUpType type) {
    final effects = _activeEffects[snake];
    if (effects == null) return null;

    final effect = effects.firstWhere(
          (e) => e.type == type,
      orElse: () => ActiveEffect(type: type, remainingTime: 0),
    );

    return effect.remainingTime > 0 ? effect.remainingTime : null;
  }

  /// Barcha effectlarni tozalash
  void clearEffects(Snake snake) {
    _activeEffects.remove(snake);
  }

  /// Barcha power-uplarni tozalash
  void clearAll() {
    for (final powerUp in _activePowerUps) {
      powerUp.removeFromParent();
    }
    _activePowerUps.clear();
    _activeEffects.clear();
  }
}

// ==================== ACTIVE EFFECT ====================

class ActiveEffect {
  final PowerUpType type;
  double remainingTime;

  ActiveEffect({
    required this.type,
    required this.remainingTime,
  });
}