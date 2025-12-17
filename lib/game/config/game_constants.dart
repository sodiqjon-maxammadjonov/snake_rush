import 'package:flutter/painting.dart';

/// O'yinning barcha konstantalari
class GameConstants {
  GameConstants._();

  // Map sozlamalari
  static const double mapWidth = 5000.0;
  static const double mapHeight = 5000.0;
  static const double mapBorderWidth = 20.0;
  static const double mapGridSize = 100.0;

  // Snake sozlamalari
  static const double snakeInitialRadius = 15.0;
  static const double snakeInitialSpeed = 150.0;
  static const double snakeMaxSpeed = 300.0;
  static const double snakeSpeedIncrement = 10.0;

  // ✅ YANGI: Bounce sozlamalari
  static const double snakeBounceElasticity = 0.6; // 60% qaytish
  static const double snakeBounceSpeedReduction = 0.85; // 15% tezlik kamayishi

  // Camera sozlamalari
  static const double cameraInitialZoom = 1.0;
  static const double cameraMinZoom = 0.5;
  static const double cameraMaxZoom = 2.0;
  static const double cameraFollowSpeed = 500.0; // ✅ YANGI: Smooth follow

  // MiniMap sozlamalari
  static const double miniMapSize = 120.0;
  static const double miniMapPadding = 20.0;
  static const double miniMapBorderWidth = 2.0;
  static const double miniMapInnerPadding = 10.0;
  static const double miniMapSnakeDotRadius = 4.0; // ✅ Biroz kattalashtirildi

  // Joystick sozlamalari
  static const double joystickKnobRadius = 30.0;
  static const double joystickBackgroundRadius = 60.0;
  static const double joystickMarginLeft = 40.0;
  static const double joystickMarginBottom = 40.0;

  // Ranglar - Default Skin
  static const Color mapBorderColor = Color(0xFFFF0040);
  static const Color mapBackgroundColor = Color(0xFF0A0A0F);
  static const Color mapGridColor = Color(0x20FFFFFF);

  static const Color snakeHeadColor = Color(0xFF34D399);
  static const Color snakeBodyColor = Color(0xFF10B981);
  static const Color snakeEyeColor = Color(0xFFFFFFFF);

  static const Color miniMapBackgroundColor = Color(0x80000000);
  static const Color miniMapBorderColor = Color(0xFFFFFFFF);
  static const Color miniMapSnakeColor = Color(0xFF34D399);

  static const Color joystickKnobColor = Color(0xFF34D399);
  static const Color joystickBackgroundColor = Color(0x40FFFFFF);

  // Blur va effektlar
  static const double mapBorderBlurRadius = 10.0;
  static const double snakeEyeOffsetDistance = 8.0;
  static const double snakeEyeAngleOffset = 0.3;
  static const double snakeEyeRadius = 3.0;

  // ✅ KELAJAK UCHUN: Skin nomlari
  static const List<String> availableSkins = [
    'default',
    'fire',      // Kelajakda qo'shish
    'ice',       // Kelajakda qo'shish
    'poison',    // Kelajakda qo'shish
    'electric',  // Kelajakda qo'shish
    'rainbow',   // Kelajakda qo'shish
  ];
}