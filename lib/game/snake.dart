import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../models/position.dart';
import '../models/direction.dart';
import '../models/skin.dart';
import '../utils/constants.dart';
import '../utils/storage.dart';

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

  // Ilonni harakatlantirish
  void move() {
    // Yo'nalishni yangilash
    currentDirection = nextDirection;

    // Yangi bosh pozitsiyasi
    final newHead = body.first.moveInDirection(currentDirection);

    // Yangi boshni qo'shamiz
    body.insert(0, newHead);

    // Agar o'sish buffer bo'lsa, dumni qirqmaymiz
    if (growthBuffer > 0) {
      growthBuffer--;
    } else {
      // Dumni qirqamiz (ilon o'smaydi)
      body.removeLast();
    }
  }

  // Ovqat yeyish - ilon o'sadi
  void eat(int growthAmount) {
    growthBuffer += growthAmount;
  }

  // Stage'ni yangilash (ochko bo'yicha)
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

  // Devorga urilishni tekshirish
  bool checkWallCollision() {
    final head = body.first;
    return head.x < 0 ||
        head.x >= GameConstants.gridWidth ||
        head.y < 0 ||
        head.y >= GameConstants.gridHeight;
  }

  // O'ziga urilishni tekshirish
  bool checkSelfCollision() {
    final head = body.first;
    // Boshdan keyingi segmentlarni tekshiramiz
    for (int i = 1; i < body.length; i++) {
      if (body[i] == head) {
        return true;
      }
    }
    return false;
  }

  // Hozirgi rangni qaytaradi (stage va skin bo'yicha)
  Color get currentColor {
    // Avval tanlangan skinni olish
    final selectedSkinId = StorageManager.instance.getSelectedSkin();
    final skin = SnakeSkins.getById(selectedSkinId);

    if (skin != null) {
      return skin.color;
    }

    // Agar skin topilmasa, stage bo'yicha
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

  // Secondary color (gradient uchun)
  Color? get secondaryColor {
    final selectedSkinId = StorageManager.instance.getSelectedSkin();
    final skin = SnakeSkins.getById(selectedSkinId);
    return skin?.secondaryColor;
  }

  // Ilonni chizish
  @override
  void render(Canvas canvas) {
    final cellSize = GameConstants.cellSize;
    final hasGradient = secondaryColor != null;

    for (int i = 0; i < body.length; i++) {
      final segment = body[i];
      final isHead = i == 0;

      // Pozitsiyani hisoblash
      final x = segment.x * cellSize;
      final y = segment.y * cellSize;

      // Segment rangini hisoblash
      Color segmentColor = currentColor;
      if (!isHead) {
        // Tana biroz och rangda
        segmentColor = segmentColor.withOpacity(0.8 - (i * 0.01));
      }

      // Gradient uchun paint
      Paint paint;
      if (hasGradient && isHead) {
        paint = Paint()
          ..shader = LinearGradient(
            colors: [currentColor, secondaryColor!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromLTWH(x, y, cellSize, cellSize))
          ..style = PaintingStyle.fill;
      } else {
        paint = Paint()
          ..color = segmentColor
          ..style = PaintingStyle.fill;
      }

      // Bosh - doira
      if (isHead) {
        canvas.drawCircle(
          Offset(x + cellSize / 2, y + cellSize / 2),
          cellSize / 2 - 1,
          paint,
        );

        // Ko'zlar
        final eyePaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

        // Ko'z pozitsiyalari yo'nalishga qarab
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

  // Reset - o'yinni qaytadan boshlash uchun
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