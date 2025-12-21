import 'package:flame/components.dart';
import 'dart:ui';
import 'package:flutter/material.dart';

/// Pauza overlay - o'yin to'xtaganda ko'rsatiladigan UI
class PauseOverlay extends PositionComponent with HasGameRef {
  final VoidCallback onResume;
  final VoidCallback onSettings;
  final VoidCallback onExit;

  late final Paint _backgroundPaint;
  late final Paint _panelPaint;
  late final TextPaint _titlePaint;
  late final TextPaint _buttonPaint;

  final List<MenuButton> _buttons = [];

  PauseOverlay({
    required this.onResume,
    required this.onSettings,
    required this.onExit,
  }) {
    priority = 1000; // Eng yuqorida
  }

  @override
  Future<void> onLoad() async {
    size = gameRef.size;

    _initializePaints();
    _createButtons();
  }

  void _initializePaints() {
    _backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.7);

    _panelPaint = Paint()
      ..color = const Color(0xFF1E1E2E).withOpacity(0.95)
      ..style = PaintingStyle.fill;

    _titlePaint = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 48,
        fontWeight: FontWeight.bold,
        letterSpacing: 4,
      ),
    );

    _buttonPaint = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  void _createButtons() {
    final centerX = width / 2;
    final centerY = height / 2;

    _buttons.addAll([
      MenuButton(
        text: 'RESUME',
        position: Vector2(centerX, centerY - 60),
        onPressed: onResume,
        color: const Color(0xFF4CAF50),
      ),
      MenuButton(
        text: 'SETTINGS',
        position: Vector2(centerX, centerY),
        onPressed: onSettings,
        color: const Color(0xFF2196F3),
      ),
      MenuButton(
        text: 'EXIT',
        position: Vector2(centerX, centerY + 60),
        onPressed: onExit,
        color: const Color(0xFFF44336),
      ),
    ]);
  }

  @override
  void render(Canvas canvas) {
    // Fon qorong'iligi
    canvas.drawRect(size.toRect(), _backgroundPaint);

    // Markaziy panel
    _renderPanel(canvas);

    // Sarlavha
    _renderTitle(canvas);

    // Tugmalar
    _renderButtons(canvas);
  }

  void _renderPanel(Canvas canvas) {
    final panelWidth = width * 0.4;
    final panelHeight = height * 0.5;
    final panelX = (width - panelWidth) / 2;
    final panelY = (height - panelHeight) / 2;

    final panelRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(panelX, panelY, panelWidth, panelHeight),
      const Radius.circular(20),
    );

    canvas.drawRRect(panelRect, _panelPaint);

    // Border
    canvas.drawRRect(
      panelRect,
      Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _renderTitle(Canvas canvas) {
    _titlePaint.render(
      canvas,
      'PAUSED',
      Vector2(width / 2 - 100, height / 2 - 150),
    );
  }

  void _renderButtons(Canvas canvas) {
    for (final button in _buttons) {
      button.render(canvas, _buttonPaint);
    }
  }

  // Touch handling (kelajakda qo'shiladi)
  void handleTap(Vector2 position) {
    for (final button in _buttons) {
      if (button.contains(position)) {
        button.onPressed();
        break;
      }
    }
  }
}

// ==================== MENU BUTTON ====================

class MenuButton {
  final String text;
  final Vector2 position;
  final VoidCallback onPressed;
  final Color color;

  final double width = 200;
  final double height = 50;

  MenuButton({
    required this.text,
    required this.position,
    required this.onPressed,
    required this.color,
  });

  void render(Canvas canvas, TextPaint textPaint) {
    final rect = Rect.fromCenter(
      center: position.toOffset(),
      width: width,
      height: height,
    );

    // Button background
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      Paint()..color = color,
    );

    // Button border
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Text
    textPaint.render(
      canvas,
      text,
      Vector2(
        position.x - (text.length * 6),
        position.y - 10,
      ),
    );
  }

  bool contains(Vector2 point) {
    final rect = Rect.fromCenter(
      center: position.toOffset(),
      width: width,
      height: height,
    );
    return rect.contains(point.toOffset());
  }
}