import 'dart:ui';

class GameConstants {
  static const double mapWidth = 6000.0;
  static const double mapHeight = 6000.0;
  static const double gridSize = 60.0;

  // Snake physics
  static const double baseSnakeSpeed = 200.0;
  static const double minSnakeRadius = 15.0;
  static const double maxSnakeRadius = 65.0;
  static const double startX = 3000.0;
  static const double startY = 3000.0;

  // Camera settings
  static const double baseCameraZoom = 0.9;

  // UI settings
  static const double miniMapSize = 130.0;
  static const double miniMapMargin = 20.0;

  // Food settings
  static const int maxFoodCount = 350;
  static const double baseEatDistance = 1.1; // radiusga nisbatan

  // Colors
  static const Color mapBackground = Color(0xFF0D0D14);
  static const Color mapGrid = Color(0x15FFFFFF);
  static const Color mapBorder = Color(0xFFFF0040);
  static const Color snakeColor = Color(0xFF34D399);
}