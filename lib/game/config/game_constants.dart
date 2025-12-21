import 'dart:ui';

class GameConstants {
  static const double mapWidth = 6000.0;
  static const double mapHeight = 6000.0;
  static const double gridSize = 60.0;

  static const double baseSnakeSpeed = 220.0;
  static const double minSnakeRadius = 12.0;
  static const double maxSnakeRadius = 55.0;
  static const double startX = 3000.0;
  static const double startY = 3000.0;

  static const double baseCameraZoom = 1.0;
  static const double minCameraZoom = 0.5;
  static const double maxCameraZoom = 1.2;
  static const double cameraZoomSpeed = 3.0;

  static const double miniMapSize = 130.0;
  static const double miniMapMargin = 20.0;

  static const int maxFoodCount = 500;
  static const double baseEatDistance = 1.1;

  static const Color mapBackground = Color(0xFF0D0D14);
  static const Color mapGrid = Color(0x15FFFFFF);
  static const Color mapBorder = Color(0xFFFF0040);
  static const Color snakeColor = Color(0xFF34D399);

  static const int maxPathPoints = 1000;
  static const int maxSegments = 500;
  static const double pathPointSpacing = 3.0;

  static const double turnSpeed = 8.0;
  static const double weightPenaltyFactor = 0.2;
  static const double speedBoostFactor = 1.0;
}