import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import '../config/game_constants.dart';

/// Custom joystick komponenti
class GameJoystick {
  late final JoystickComponent component;
  late final CircleComponent _knob;
  late final CircleComponent _background;

  GameJoystick() {
    component = _createJoystick();
  }

  JoystickComponent _createJoystick() {
    _knob = _createKnob();
    _background = _createBackground();

    return JoystickComponent(
      knob: _knob,
      background: _background,
      margin: const EdgeInsets.only(
        left: GameConstants.joystickMarginLeft,
        bottom: GameConstants.joystickMarginBottom,
      ),
      priority: 10000, // ✅ Eng yuqori priority - ekran tepasida
    );
  }

  CircleComponent _createKnob() {
    return CircleComponent(
      radius: GameConstants.joystickKnobRadius,
      paint: Paint()
        ..color = GameConstants.joystickKnobColor
        ..style = PaintingStyle.fill,
    );
  }

  CircleComponent _createBackground() {
    return CircleComponent(
      radius: GameConstants.joystickBackgroundRadius,
      paint: Paint()
        ..color = GameConstants.joystickBackgroundColor
        ..style = PaintingStyle.fill,
    );
  }

  // Joystick ma'lumotlarini olish
  JoystickDirection get direction => component.direction;
  Vector2 get relativeDelta => component.relativeDelta;
  bool get isIdle => component.direction == JoystickDirection.idle;

  /// Opacity o'zgartirish
  void _applyOpacity(double value) {
    final opacity = value.clamp(0.0, 1.0);

    _knob.paint.color =
        GameConstants.joystickKnobColor.withOpacity(opacity);

    _background.paint.color =
        GameConstants.joystickBackgroundColor.withOpacity(opacity);
  }

  void hide() => _applyOpacity(0.0);
  void show() => _applyOpacity(1.0);
  void setOpacity(double value) => _applyOpacity(value);
}