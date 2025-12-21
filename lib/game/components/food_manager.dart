import 'dart:math' as math;
import 'package:flame/components.dart';
import '../config/game_constants.dart';
import 'food.dart';
import 'game_map.dart';

class FoodManager extends Component {
  final GameMap map;
  final List<Food> _foods = [];
  final math.Random _random = math.Random();

  FoodManager({required this.map});

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

    double chance = _random.nextDouble();
    FoodType type;
    if (chance < 0.7) type = FoodType.small;
    else if (chance < 0.9) type = FoodType.medium;
    else if (chance < 0.98) type = FoodType.large;
    else type = FoodType.super_;

    final food = Food(pos: Vector2(x, y), type: type);
    _foods.add(food);
    map.add(food);
  }

  void checkFoodInteractions(Vector2 snakePos, double snakeRadius, double dt, Function(int) onEat) {
    // Ilon radiusiga qarab magnit maydonini kengaytiramiz
    double magnetRange = snakeRadius * 4;

    for (int i = _foods.length - 1; i >= 0; i--) {
      final f = _foods[i];
      double dist = f.position.distanceTo(snakePos);

      // 1. Tortish (Magnit)
      if (dist < magnetRange) {
        f.pullTowards(snakePos, dt);
      } else {
        f.isBeingPulled = false;
      }

      // 2. Yeyish (Collision)
      if (dist < snakeRadius + f.type.radius) {
        onEat(f.type.points);
        f.removeFromParent();
        _foods.removeAt(i);
      }
    }
  }
}