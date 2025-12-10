import 'dart:async';
import 'package:flame/camera.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'snake.dart';
import 'food.dart';
import '../models/position.dart';
import '../models/direction.dart';
import '../models/food_type.dart';
import '../utils/constants.dart';

// =============================================================================
// SNAKE GAME - Asosiy o'yin engine (Game Loop)
// =============================================================================

class SnakeGame extends FlameGame {
  // Components
  late Snake snake;
  late Food food;

  // Game state
  int score = 0;
  int coinsEarned = 0;
  bool isGameOver = false;
  bool isPaused = false;

  // Power-up state
  bool isPowerUpActive = false;
  double powerUpTimer = 0;

  // Speed control
  double currentSpeed = GameConstants.initialSpeed;
  double timeSinceLastMove = 0;

  // Callbacks
  Function(int score, int coins, bool isNewBest)? onGameOver;
  Function(int score, int coins)? onScoreUpdate;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Maydon o'lchamini sozlash
    camera.viewport = FixedResolutionViewport(
      resolution: Vector2(
        GameConstants.gridWidth * GameConstants.cellSize,
        GameConstants.gridHeight * GameConstants.cellSize,
      ),
    );

    // Komponentlarni yaratish
    _initializeGame();
  }

  void _initializeGame() {
    // Ilon va ovqatni yaratish
    snake = Snake();

    // Ovqatni tasodifiy joyda yaratish
    food = Food(
      gridPosition: Position(15, 10),
      type: FoodType.normal,
    );
    food.respawn(snake.body);

    add(food);

    // Boshlang'ich qiymatlar
    score = 0;
    coinsEarned = 0;
    isGameOver = false;
    isPaused = false;
    isPowerUpActive = false;
    currentSpeed = GameConstants.initialSpeed;
    timeSinceLastMove = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Agar o'yin tugagan yoki pause bo'lsa, yangilanmaymiz
    if (isGameOver || isPaused) return;

    // Power-up timer
    if (isPowerUpActive) {
      powerUpTimer -= dt;
      if (powerUpTimer <= 0) {
        isPowerUpActive = false;
      }
    }

    // Move timer
    timeSinceLastMove += dt;

    if (timeSinceLastMove >= currentSpeed) {
      timeSinceLastMove = 0;
      _updateGame();
    }
  }

  void _updateGame() {
    // Ilonni harakatlantirish
    snake.move();

    // Collision tekshirish
    if (snake.checkWallCollision() || snake.checkSelfCollision()) {
      _gameOver();
      return;
    }

    // Ovqat bilan to'qnashuvni tekshirish
    if (snake.body.first == food.gridPosition) {
      _eatFood();
    }
  }

  void _eatFood() {
    // Ovqat yeyildi!
    final foodType = food.type;

    // Ochko qo'shish (power-up bo'lsa 2x)
    int earnedScore = foodType.score;
    if (isPowerUpActive) {
      earnedScore *= 2;
    }
    score += earnedScore;

    // Ilonni o'stirish
    snake.eat(foodType.growth);

    // Power-up aktivlash
    if (foodType.isPowerUp) {
      isPowerUpActive = true;
      powerUpTimer = GameConstants.powerUpDuration;
    }

    // Stage yangilash
    snake.updateStage(score);

    // Tezlikni oshirish
    if (currentSpeed > GameConstants.minSpeed) {
      currentSpeed -= GameConstants.speedIncrease;
    }

    // Coinlarni hisoblash
    _updateCoins();

    // Yangi ovqat yaratish
    food.respawn(snake.body);

    // Score callback
    onScoreUpdate?.call(score, coinsEarned);
  }

  void _updateCoins() {
    // Har 10 ochkoga 1 coin
    coinsEarned = score ~/ 10;

    // Milestone bonuslari
    GameConstants.milestoneBonus.forEach((milestone, bonus) {
      if (score >= milestone) {
        coinsEarned += bonus;
      }
    });
  }

  void _gameOver() {
    isGameOver = true;

    // Best score tekshirish (bu keyinroq storage'dan olinadi)
    // Hozircha false deb qo'yamiz
    onGameOver?.call(score, coinsEarned, false);
  }

  // Yo'nalishni o'zgartirish
  void changeDirection(Direction direction) {
    if (!isGameOver && !isPaused) {
      snake.changeDirection(direction);
    }
  }

  // Pause/Resume
  void togglePause() {
    isPaused = !isPaused;
  }

  // Qaytadan boshlash
  void restart() {
    snake.reset();
    _initializeGame();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Background
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        GameConstants.gridWidth * GameConstants.cellSize,
        GameConstants.gridHeight * GameConstants.cellSize,
      ),
      Paint()..color = GameConstants.backgroundColor,
    );

    // Grid lines (optional - nazariy chiziqlar)
    final gridPaint = Paint()
      ..color = GameConstants.gridColor
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i <= GameConstants.gridWidth; i++) {
      canvas.drawLine(
        Offset(i * GameConstants.cellSize, 0),
        Offset(i * GameConstants.cellSize, GameConstants.gridHeight * GameConstants.cellSize),
        gridPaint,
      );
    }

    for (int i = 0; i <= GameConstants.gridHeight; i++) {
      canvas.drawLine(
        Offset(0, i * GameConstants.cellSize),
        Offset(GameConstants.gridWidth * GameConstants.cellSize, i * GameConstants.cellSize),
        gridPaint,
      );
    }

    snake.render(canvas);

    if (isPowerUpActive) {
      final powerUpPaint = Paint()
        ..color = GameConstants.powerAppleColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromLTWH(
          0,
          0,
          GameConstants.gridWidth * GameConstants.cellSize,
          GameConstants.gridHeight * GameConstants.cellSize,
        ),
        powerUpPaint,
      );
    }
  }
}