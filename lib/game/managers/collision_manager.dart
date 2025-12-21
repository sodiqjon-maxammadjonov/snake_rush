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

    for (final snake in snakesCopy) {
      final nearbySnakes = _getNeighboringSnakes(snake.position);

      for (final other in nearbySnakes) {
        if (snake == other) continue;
        if (!_snakes.contains(snake) || !_snakes.contains(other)) continue;

        if (_checkHeadToBodyCollision(snake, other)) {
          _handleSnakeCollision(snake, other);
        }

        if (_checkHeadToHeadCollision(snake, other)) {
          _handleHeadToHeadCollision(snake, other);
        }
      }

      if (_snakes.contains(snake) && _checkSelfCollision(snake)) {
        _handleSelfCollision(snake);
      }
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

  bool _checkHeadToBodyCollision(Snake attacker, Snake victim) {
    final headPos = attacker.position;
    final headRadius = attacker.currentRadius;

    final segments = victim.segmentPositions;

    for (int i = 5; i < segments.length; i += 2) {
      final segmentPos = segments[i];
      final distance = headPos.distanceTo(segmentPos);

      if (distance < (headRadius + victim.currentRadius * 0.5)) {
        return true;
      }
    }

    return false;
  }

  bool _checkHeadToHeadCollision(Snake snake1, Snake snake2) {
    final distance = snake1.position.distanceTo(snake2.position);
    return distance < (snake1.currentRadius + snake2.currentRadius);
  }

  void _handleHeadToHeadCollision(Snake snake1, Snake snake2) {
    Snake winner, loser;

    if (snake1.currentRadius > snake2.currentRadius) {
      winner = snake1;
      loser = snake2;
    } else {
      winner = snake2;
      loser = snake1;
    }

    onSnakeCollision?.call(winner, loser);

    loser.removeFromParent();
    unregisterSnake(loser);

    winner.grow(loser.totalScore ~/ 2);
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

  void _handleSnakeCollision(Snake attacker, Snake victim) {
    if (attacker.currentRadius > victim.currentRadius * 1.2) {
      onSnakeCollision?.call(attacker, victim);

      victim.removeFromParent();
      unregisterSnake(victim);

      attacker.grow(victim.totalScore ~/ 2);
    }
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