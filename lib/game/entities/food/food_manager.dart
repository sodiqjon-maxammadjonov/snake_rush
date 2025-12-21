import 'dart:math' as math;
import 'package:flame/components.dart';
import '../../config/game_constants.dart';
import '../../world/game_map.dart';
import '../../managers/collision_manager.dart';
import 'food.dart';
import 'food_type.dart';

class FoodManager extends Component {
  final GameMap map;
  final CollisionManager collisionManager;
  final List<Food> _foods = [];
  final math.Random _random = math.Random();

  Function(int points)? onFoodEaten;

  int get foodCount => _foods.length;

  FoodManager({required this.map, required this.collisionManager});

  @override
  void update(double dt) {
    super.update(dt);

    if (_foods.length < GameConstants.maxFoodCount) {
      _spawnFood();
    }
  }

  void _spawnFood() {
    final x = _random.nextDouble() * GameConstants.mapWidth;
    final y = _random.nextDouble() * GameConstants.mapHeight;

    final chance = _random.nextDouble();
    final type = FoodType.getRandomType(chance);

    final food = Food(pos: Vector2(x, y), type: type);
    _foods.add(food);
    collisionManager.registerFood(food);
    map.add(food);
  }

  void spawnFoodCluster(Vector2 center, int count) {
    const radius = 150.0;

    for (int i = 0; i < count; i++) {
      final angle = _random.nextDouble() * math.pi * 2;
      final distance = _random.nextDouble() * radius;

      final x = center.x + math.cos(angle) * distance;
      final y = center.y + math.sin(angle) * distance;

      final chance = _random.nextDouble();
      final type = FoodType.getRandomType(chance);

      final food = Food(pos: Vector2(x, y), type: type);
      _foods.add(food);
      collisionManager.registerFood(food);
      map.add(food);
    }
  }

  void checkFoodInteractions(
      Vector2 snakePosition,
      double snakeRadius,
      double dt,
      Function(int) onEat,
      ) {
    final magnetRange = snakeRadius * 4;

    for (int i = _foods.length - 1; i >= 0; i--) {
      final food = _foods[i];
      final distance = food.position.distanceTo(snakePosition);

      if (distance < magnetRange) {
        food.pullTowards(snakePosition, dt);
      } else {
        food.isBeingPulled = false;
      }

      if (distance < snakeRadius + food.type.radius) {
        onEat(food.type.points);
        collisionManager.unregisterFood(food);
        food.removeFromParent();
        _foods.removeAt(i);

        onFoodEaten?.call(food.type.points);
      }
    }
  }

  void clearAll() {
    for (final food in _foods) {
      collisionManager.unregisterFood(food);
      food.removeFromParent();
    }
    _foods.clear();
  }

  int getFoodInArea(Vector2 center, double radius) {
    return _foods.where((food) {
      return food.position.distanceTo(center) < radius;
    }).length;
  }
}