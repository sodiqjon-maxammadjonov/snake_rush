import 'dart:ui';

class GameConstants {
  // Map o'lchamlari
  static const double mapWidth = 5000.0;
  static const double mapHeight = 5000.0;
  static const double gridSize = 50.0; // Kataklar hajmi

  // Snake sozlamalari
  static const double snakeSpeed = 200.0; // Sekundiga piksel
  static const double snakeRadius = 15.0; // Ilon boshining kattaligi
  static const double startX = 2500.0; // Markaz
  static const double startY = 2500.0; // Markaz

  // Camera
  static const double cameraZoom = 1.0;

  // Mini Map
  static const double miniMapSize = 120.0;
  static const double miniMapMargin = 20.0;

  // Ranglar (Skinlar uchun keyinchalik class ishlatamiz)
  static const Color mapBackground = Color(0xFF0A0A0F);
  static const Color mapGrid = Color(0x1AFFFFFF); // Juda shaffof
  static const Color mapBorder = Color(0xFFFF0040);
  static const Color snakeColor = Color(0xFF34D399);
}