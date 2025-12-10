import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../models/position.dart';
import '../models/direction.dart';
import '../utils/constants.dart';

// =============================================================================
// SNAKE CLASS - Ilon komponenti
// =============================================================================

class Snake extends Component {
  // Ilon tanasi - har bir segment pozitsiyasi
  List<Position> body = [];

  // Hozirgi harakat yo'nalishi
  Direction currentDirection = Direction.right;

  // Keyingi yo'nalish (input buffer uchun)
  Direction nextDirection = Direction.right;

  // O'sish buffer - qancha segment qo'shish kerak
  int growthBuffer = 0;

  // Hozirgi stage (1-4)
  int currentStage = 1;

  // Constructor
  Snake() {
    // Boshlang'ich pozitsiya (markazda, 3 segment)
    final centerX = GameConstants.gridWidth ~/ 2;
    final centerY = GameConstants.gridHeight ~/ 2;

    body = [
      Position(centerX, centerY),     // Bosh
      Position(centerX - 1, centerY), // Tana 1
      Position(centerX - 2, centerY), // Tana 2
    ];
  }

  // Yo'nalishni o'zgartirish
  void changeDirection(Direction newDirection) {
    // Teskari yo'nalishga burilish mumkin emas
    // (o'ziga urilmasligi uchun)
    if (newDirection != currentDirection.opposite) {
      nextDirection = newDirection;
    }
  }

  void move() {
    currentDirection = nextDirection;

    final newHead = body.first.moveInDirection(currentDirection);

    body.insert(0, newHead);

    if (growthBuffer > 0) {
      growthBuffer--;
    } else {
      body.removeLast();
    }
  }

  void eat(int growthAmount) {
    growthBuffer += growthAmount;
  }

  void updateStage(int score) {
    if (score >= GameConstants.stage4Score) {
      currentStage = 4;
    } else if (score >= GameConstants.stage3Score) {
      currentStage = 3;
    } else if (score >= GameConstants.stage2Score) {
      currentStage = 2;
    } else {
      currentStage = 1;
    }
  }

  bool checkWallCollision() {
    final head = body.first;
    return head.x < 0 ||
        head.x >= GameConstants.gridWidth ||
        head.y < 0 ||
        head.y >= GameConstants.gridHeight;
  }

  bool checkSelfCollision() {
    final head = body.first;
    for (int i = 1; i < body.length; i++) {
      if (body[i] == head) {
        return true;
      }
    }
    return false;
  }

  Color get currentColor {
    switch (currentStage) {
      case 1:
        return GameConstants.snakeStage1Color;
      case 2:
        return GameConstants.snakeStage2Color;
      case 3:
        return GameConstants.snakeStage3Color;
      case 4:
        return GameConstants.snakeStage4Color;
      default:
        return GameConstants.snakeStage1Color;
    }
  }

  @override
  void render(Canvas canvas) {
    final cellSize = GameConstants.cellSize;

    for (int i = 0; i < body.length; i++) {
      final segment = body[i];
      final isHead = i == 0;

      final x = segment.x * cellSize;
      final y = segment.y * cellSize;

      Color segmentColor = currentColor;
      if (!isHead) {
        segmentColor = segmentColor.withValues(alpha: 0.8 - (i * 0.01));
      }

      final paint = Paint()
        ..color = segmentColor
        ..style = PaintingStyle.fill;

      if (isHead) {
        canvas.drawCircle(
          Offset(x + cellSize / 2, y + cellSize / 2),
          cellSize / 2 - 1,
          paint,
        );

        final eyePaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

        Offset leftEye, rightEye;
        switch (currentDirection) {
          case Direction.right:
            leftEye = Offset(x + cellSize * 0.6, y + cellSize * 0.3);
            rightEye = Offset(x + cellSize * 0.6, y + cellSize * 0.7);
            break;
          case Direction.left:
            leftEye = Offset(x + cellSize * 0.4, y + cellSize * 0.3);
            rightEye = Offset(x + cellSize * 0.4, y + cellSize * 0.7);
            break;
          case Direction.up:
            leftEye = Offset(x + cellSize * 0.3, y + cellSize * 0.4);
            rightEye = Offset(x + cellSize * 0.7, y + cellSize * 0.4);
            break;
          case Direction.down:
            leftEye = Offset(x + cellSize * 0.3, y + cellSize * 0.6);
            rightEye = Offset(x + cellSize * 0.7, y + cellSize * 0.6);
            break;
        }

        canvas.drawCircle(leftEye, 1.5, eyePaint);
        canvas.drawCircle(rightEye, 1.5, eyePaint);

      } else {
        // Tana - kvadrat (yumaloq burchakli)
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x + 1, y + 1, cellSize - 2, cellSize - 2),
          const Radius.circular(3),
        );
        canvas.drawRRect(rect, paint);
      }
    }
  }

  void reset() {
    final centerX = GameConstants.gridWidth ~/ 2;
    final centerY = GameConstants.gridHeight ~/ 2;

    body = [
      Position(centerX, centerY),
      Position(centerX - 1, centerY),
      Position(centerX - 2, centerY),
    ];

    currentDirection = Direction.right;
    nextDirection = Direction.right;
    growthBuffer = 0;
    currentStage = 1;
  }
}