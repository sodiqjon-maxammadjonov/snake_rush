import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../models/position.dart';
import '../models/food_type.dart';
import '../utils/constants.dart';


class Food extends PositionComponent {
  Position gridPosition;
  FoodType type;

  // Random generator
  final Random _random = Random();

  // Constructor
  Food({
    required this.gridPosition,
    required this.type,
  }) : super(
    size: Vector2.all(GameConstants.cellSize),
    anchor: Anchor.center,
  );

  @override
  void onMount() {
    super.onMount();
    _updateVisualPosition();
  }

  void _updateVisualPosition() {
    position = Vector2(
      gridPosition.x * GameConstants.cellSize + GameConstants.cellSize / 2,
      gridPosition.y * GameConstants.cellSize + GameConstants.cellSize / 2,
    );
  }

  void respawn(List<Position> occupiedPositions) {
    Position newPosition;
    int attempts = 0;
    const maxAttempts = 100;

    do {
      newPosition = Position(
        _random.nextInt(GameConstants.gridWidth),
        _random.nextInt(GameConstants.gridHeight),
      );
      attempts++;

      if (attempts > maxAttempts) {
        newPosition = _findFirstEmptyPosition(occupiedPositions);
        break;
      }
    } while (occupiedPositions.contains(newPosition));

    gridPosition = newPosition;

    type = _selectRandomFoodType();

    _updateVisualPosition();
  }

  Position _findFirstEmptyPosition(List<Position> occupiedPositions) {
    for (int y = 0; y < GameConstants.gridHeight; y++) {
      for (int x = 0; x < GameConstants.gridWidth; x++) {
        final pos = Position(x, y);
        if (!occupiedPositions.contains(pos)) {
          return pos;
        }
      }
    }
    return Position(
      GameConstants.gridWidth ~/ 2,
      GameConstants.gridHeight ~/ 2,
    );
  }

  FoodType _selectRandomFoodType() {
    final chance = _random.nextInt(100);

    if (chance < GameConstants.powerAppleChance) {
      return FoodType.power;
    } else if (chance < GameConstants.powerAppleChance + GameConstants.goldenAppleChance) {
      return FoodType.golden;
    } else {
      return FoodType.normal;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()
      ..color = type.color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      (size / 2).toOffset(),
      size.x / 2 - 1,
      paint,
    );

    if (type == FoodType.power) {
      final glowPaint = Paint()
        ..color = type.color.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(
        (size / 2).toOffset(),
        size.x / 2 + 2,
        glowPaint,
      );
    }

    if (type == FoodType.golden) {
      final borderPaint = Paint()
        ..color = Colors.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawCircle(
        (size / 2).toOffset(),
        size.x / 2 - 1,
        borderPaint,
      );
    }
  }
}