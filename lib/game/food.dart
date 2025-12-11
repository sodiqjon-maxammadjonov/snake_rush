import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../models/position.dart';
import '../models/food_type.dart';
import '../utils/constants.dart';

// =============================================================================
// FOOD CLASS - Ovqat komponenti
// =============================================================================

class Food extends PositionComponent {
  Position gridPosition;  // Grid'dagi pozitsiya (X, Y)
  FoodType type;          // Ovqat turi (normal, golden, power)

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

  // Grid pozitsiyasini ekran pozitsiyasiga o'zgartiradi
  void _updateVisualPosition() {
    position = Vector2(
      gridPosition.x * GameConstants.cellSize + GameConstants.cellSize / 2,
      gridPosition.y * GameConstants.cellSize + GameConstants.cellSize / 2,
    );
  }

  // Ovqatni yangi joyga ko'chiradi
  void respawn(List<Position> occupiedPositions) {
    Position newPosition;
    int attempts = 0;
    const maxAttempts = 100;

    // Tasodifiy bo'sh joy topamiz
    do {
      newPosition = Position(
        _random.nextInt(GameConstants.gridWidth),
        _random.nextInt(GameConstants.gridHeight),
      );
      attempts++;

      // Agar 100 marta urinib topilmasa, birinchi bo'sh joyni olamiz
      if (attempts > maxAttempts) {
        newPosition = _findFirstEmptyPosition(occupiedPositions);
        break;
      }
    } while (occupiedPositions.contains(newPosition));

    gridPosition = newPosition;

    // Yangi ovqat turini tanlash
    type = _selectRandomFoodType();

    _updateVisualPosition();
  }

  // Birinchi bo'sh pozitsiyani topadi
  Position _findFirstEmptyPosition(List<Position> occupiedPositions) {
    for (int y = 0; y < GameConstants.gridHeight; y++) {
      for (int x = 0; x < GameConstants.gridWidth; x++) {
        final pos = Position(x, y);
        if (!occupiedPositions.contains(pos)) {
          return pos;
        }
      }
    }
    // Agar hech narsa topilmasa, o'rtaga qo'yamiz
    return Position(
      GameConstants.gridWidth ~/ 2,
      GameConstants.gridHeight ~/ 2,
    );
  }

  // Tasodifiy ovqat turini tanlaydi (ehtimollik bo'yicha)
  FoodType _selectRandomFoodType() {
    final chance = _random.nextInt(100);

    if (chance < GameConstants.powerAppleChance) {
      // 5% - Power apple
      return FoodType.power;
    } else if (chance < GameConstants.powerAppleChance + GameConstants.goldenAppleChance) {
      // 25% - Golden apple
      return FoodType.golden;
    } else {
      // 70% - Normal apple
      return FoodType.normal;
    }
  }

  @override
  void render(Canvas canvas) {
    // Ovqatni chizamiz
    final paint = Paint()
      ..color = type.color
      ..style = PaintingStyle.fill;

    final center = Offset(size.x / 2, size.y / 2);
    final radius = size.x / 2 - 1;

    // Asosiy doira
    canvas.drawCircle(center, radius, paint);

    // Power apple uchun maxsus effekt (yaltiraydi)
    if (type == FoodType.power) {
      final glowPaint = Paint()
        ..color = type.color.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(center, radius + 2, glowPaint);
    }

    // Golden apple uchun maxsus effekt (hoshiya)
    if (type == FoodType.golden) {
      final borderPaint = Paint()
        ..color = Colors.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawCircle(center, radius, borderPaint);
    }
  }
}