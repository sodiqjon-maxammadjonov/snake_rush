import 'package:flame/components.dart';
import 'dart:math' as math;
import '../entities/snake/snake.dart';
import '../entities/food/food.dart';

class CollisionManager extends Component {
  final List<Snake> _snakes = [];
  final List<Food> _foods = [];

  final Map<String, List<Snake>> _snakeGrid = {};
  final double _gridCellSize = 200.0;

  Function(Snake attacker, Snake victim)? onSnakeCollision;
  Function(Snake snake, Food food)? onFoodCollision;

  void registerSnake(Snake snake) {
    if (!_snakes.contains(snake)) {
      _snakes.add(snake);
    }
  }

  void unregisterSnake(Snake snake) {
    _snakes.remove(snake);
  }

  void registerFood(Food food) {
    if (!_foods.contains(food)) {
      _foods.add(food);
    }
  }

  void unregisterFood(Food food) {
    _foods.remove(food);
  }

  @override
  void update(double dt) {
    super.update(dt);

    _updateSpatialGrid();
    _checkSnakeToSnakeCollisions();
    _checkSnakeToFoodCollisions();
  }

  void _updateSpatialGrid() {
    _snakeGrid.clear();

    for (final snake in _snakes) {
      final cellKey = _getCellKey(snake.position);
      _snakeGrid.putIfAbsent(cellKey, () => []).add(snake);
    }
  }

  String _getCellKey(Vector2 position) {
    final cellX = (position.x / _gridCellSize).floor();
    final cellY = (position.y / _gridCellSize).floor();
    return '$cellX,$cellY';
  }

  List<Snake> _getNeighboringSnakes(Vector2 position) {
    final neighbors = <Snake>[];
    final cellX = (position.x / _gridCellSize).floor();
    final cellY = (position.y / _gridCellSize).floor();

    for (int dx = -1; dx <= 1; dx++) {
      for (int dy = -1; dy <= 1; dy++) {
        final key = '${cellX + dx},${cellY + dy}';
        neighbors.addAll(_snakeGrid[key] ?? []);
      }
    }

    return neighbors;
  }

  void _checkSnakeToSnakeCollisions() {
    final snakesCopy = List<Snake>.from(_snakes);
    final collisionPairs = <_CollisionPair>[];

    // Birinchi o'tish: Barcha collisionlarni topish
    for (final snake in snakesCopy) {
      if (!_snakes.contains(snake)) continue;

      final nearbySnakes = _getNeighboringSnakes(snake.position);

      for (final other in nearbySnakes) {
        if (snake == other) continue;
        if (!_snakes.contains(snake) || !_snakes.contains(other)) continue;

        // snake boshi bilan other tanasiga urildi
        if (_checkHeadToBodyCollision(snake, other)) {
          collisionPairs.add(_CollisionPair(
            attacker: snake,
            victim: other,
          ));
        }
      }

      // O'z-o'ziga urilish
      if (_snakes.contains(snake) && _checkSelfCollision(snake)) {
        _handleSelfCollision(snake);
      }
    }

    // Ikkinchi o'tish: Collisionlarni hal qilish
    _resolveCollisions(collisionPairs);
  }

  /// Collisionlarni to'g'ri tartibda hal qilish
  void _resolveCollisions(List<_CollisionPair> pairs) {
    final processedSnakes = <Snake>{};

    for (final pair in pairs) {
      // Agar bu ilon allaqachon o'lgan bo'lsa, o'tkazib yuborish
      if (processedSnakes.contains(pair.attacker) ||
          processedSnakes.contains(pair.victim)) {
        continue;
      }

      // Agar ikkalasi ham bir-biriga urilgan bo'lsa
      final reverseCollision = pairs.any((p) =>
      p.attacker == pair.victim && p.victim == pair.attacker);

      if (reverseCollision) {
        // Ikki tomonlama collision - hech kim o'lmaydi
        // (bosh bilan bosh kabi)
        continue;
      }

      // Normal collision - boshi bilan urgan o'ladi
      _handleCollision(winner: pair.victim, loser: pair.attacker);
      processedSnakes.add(pair.attacker);
      processedSnakes.add(pair.victim);
    }
  }

  void _checkSnakeToFoodCollisions() {
    for (final snake in _snakes) {
      for (int i = _foods.length - 1; i >= 0; i--) {
        final food = _foods[i];

        if (_checkCircleCollision(
          snake.position,
          snake.currentRadius,
          food.position,
          food.type.radius,
        )) {
          onFoodCollision?.call(snake, food);
          _foods.removeAt(i);
        }
      }
    }
  }

  /// Bosh bilan tanaga urilishni tekshirish
  /// attacker - kim hujum qilmoqda (boshi bilan) - BU O'LADI!
  /// victim - kimning tanasiga urilmoqda - BU YUTADI!
  bool _checkHeadToBodyCollision(Snake attacker, Snake victim) {
    final headPos = attacker.position;
    final headRadius = attacker.currentRadius;

    final segments = victim.segmentPositions;

    // Qurbonning tanasini tekshiramiz
    // Birinchi 5 segmentni o'tkazib yuboramiz (bu bosh qismi)
    for (int i = 5; i < segments.length; i += 2) {
      final segmentPos = segments[i];
      final distance = headPos.distanceTo(segmentPos);

      if (distance < (headRadius + victim.currentRadius * 0.5)) {
        return true;
      }
    }

    return false;
  }

  bool _checkSelfCollision(Snake snake) {
    if (snake.currentLength < 30) return false;

    final headPos = snake.position;
    final headRadius = snake.currentRadius;
    final segments = snake.segmentPositions;

    for (int i = 20; i < segments.length; i += 3) {
      final segmentPos = segments[i];
      final distance = headPos.distanceTo(segmentPos);

      if (distance < headRadius * 0.8) {
        return true;
      }
    }

    return false;
  }

  bool _checkCircleCollision(
      Vector2 pos1,
      double radius1,
      Vector2 pos2,
      double radius2,
      ) {
    final distance = pos1.distanceTo(pos2);
    return distance < (radius1 + radius2);
  }

  /// ✅ TO'G'RI COLLISION HANDLER
  /// winner - g'olib (kimning TANASIGA urilgan)
  /// loser - mag'lub (kim BOSHI bilan urgan)
  void _handleCollision({
    required Snake winner,
    required Snake loser,
  }) {
    // Callback chaqirish
    onSnakeCollision?.call(winner, loser);

    // Boshi bilan urgan ilon O'LADI
    loser.removeFromParent();
    unregisterSnake(loser);

    // Tanasiga urilgan ilon YUTADI va ochko oladi
    winner.grow(loser.totalScore ~/ 2);
  }

  void _handleSelfCollision(Snake snake) {
    if (snake.isPlayer) {
      onSnakeCollision?.call(snake, snake);
    }
  }

  List<Snake> get allSnakes => List.unmodifiable(_snakes);
  List<Food> get allFoods => List.unmodifiable(_foods);

  List<Snake> getSnakesInRadius(Vector2 center, double radius) {
    return _snakes.where((snake) {
      return snake.position.distanceTo(center) < radius;
    }).toList();
  }

  Snake? getNearestSnake(Vector2 position, {Snake? exclude}) {
    Snake? nearest;
    double minDistance = double.infinity;

    for (final snake in _snakes) {
      if (snake == exclude) continue;

      final distance = snake.position.distanceTo(position);
      if (distance < minDistance) {
        minDistance = distance;
        nearest = snake;
      }
    }

    return nearest;
  }

  void clear() {
    _snakes.clear();
    _foods.clear();
    _snakeGrid.clear();
  }
}

/// Collision juftligini saqlash uchun helper class
class _CollisionPair {
  final Snake attacker; // Kim boshi bilan urdi
  final Snake victim;   // Kimning tanasiga urildi

  _CollisionPair({
    required this.attacker,
    required this.victim,
  });
}