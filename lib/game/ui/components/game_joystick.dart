import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// O'yin joystick komponenti
class GameJoystick extends JoystickComponent {
  GameJoystick({required EdgeInsets margin})
      : super(
    knob: CircleComponent(
      radius: 25,
      paint: Paint()..color = Colors.white.withOpacity(0.8),
    ),
    background: CircleComponent(
      radius: 50,
      paint: Paint()..color = Colors.black.withOpacity(0.5),
    ),
    margin: margin,
    priority: 10,
  );

  /// Joystick yo'nalishini olish
  Vector2 get inputDirection => relativeDelta;

  /// Joystick faolmi?
  bool get isActive => direction != JoystickDirection.idle;
}