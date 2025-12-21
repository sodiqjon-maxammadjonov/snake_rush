import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../entities/snake/snake.dart';
import '../../entities/bot/bot_snake.dart';

/// Statistika va Leaderboard ko'rsatish
class ScoreDisplay extends PositionComponent with HasGameRef {
  final Snake player;

  late final TextPaint _scorePaint;
  late final TextPaint _lengthPaint;
  late final TextPaint _leaderboardTitlePaint;
  late final TextPaint _leaderboardOthersPaint;
  late final TextPaint _leaderboardMePaint;
  late final Paint _bgPaint;

  ScoreDisplay({required this.player}) {
    priority = 100;
  }

  @override
  Future<void> onLoad() async {
    _initializeTextStyles();
    _bgPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..style = PaintingStyle.fill;
  }

  void _initializeTextStyles() {
    _scorePaint = TextPaint(
      style: const TextStyle(
        color: Color(0xFF4ECDC4),
        fontSize: 24,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            color: Colors.black,
            offset: Offset(2, 2),
            blurRadius: 3,
          ),
        ],
      ),
    );

    _lengthPaint = TextPaint(
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );

    _leaderboardTitlePaint = TextPaint(
      style: const TextStyle(
        color: Colors.orangeAccent,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );

    _leaderboardOthersPaint = TextPaint(
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 12,
      ),
    );

    _leaderboardMePaint = TextPaint(
      style: const TextStyle(
        color: Colors.greenAccent,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    _renderPlayerStats(canvas);
    _renderLeaderboard(canvas);
  }

  /// O'yinchi statistikasini ko'rsatish
  void _renderPlayerStats(Canvas canvas) {
    final scoreStr = _formatScore(player.totalScore);
    final lengthStr = "Length: ${player.currentLength}";

    // Fon
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(20, 160, 160, 65),
        const Radius.circular(12),
      ),
      _bgPaint,
    );

    // Matnlar
    _scorePaint.render(canvas, scoreStr, Vector2(35, 170));
    _lengthPaint.render(canvas, lengthStr, Vector2(35, 200));
  }

  /// Leaderboard ko'rsatish
  void _renderLeaderboard(Canvas canvas) {
    final viewWidth = gameRef.size.x;
    const boardWidth = 180.0;
    final startX = viewWidth - boardWidth - 20;

    // Fon
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(startX, 20, boardWidth, 190),
        const Radius.circular(12),
      ),
      _bgPaint,
    );

    // Sarlavha
    _leaderboardTitlePaint.render(
      canvas,
      "TOP 10 SERPENTS",
      Vector2(startX + 15, 30),
    );

    // O'yinchilar ro'yxati
    _renderPlayerList(canvas, startX, boardWidth);
  }

  /// O'yinchilar ro'yxatini chizish
  void _renderPlayerList(Canvas canvas, double startX, double boardWidth) {
    // REAL-TIME leaderboard (botlar va o'yinchi)
    final topPlayers = <Map<String, dynamic>>[];

    // O'yinchi
    topPlayers.add({
      "name": "You",
      "score": player.totalScore,
      "isMe": true,
    });

    // Botlar (gameRef'dan olish)
    try {
      final game = gameRef as dynamic;
      if (game.bots != null) {
        for (final bot in game.bots) {
          if (bot is BotSnake) {
            topPlayers.add({
              "name": bot.name,
              "score": bot.totalScore,
              "isMe": false,
            });
          }
        }
      }
    } catch (e) {
      // Fallback: static mock data
      topPlayers.addAll([
        {"name": "Viper123", "score": 5000, "isMe": false},
        {"name": "Shadow89", "score": 3500, "isMe": false},
        {"name": "Rex456", "score": 2800, "isMe": false},
      ]);
    }

    // Score bo'yicha saralash
    topPlayers.sort((a, b) =>
        (b['score'] as int).compareTo(a['score'] as int)
    );

    // Faqat top 10
    final displayList = topPlayers.take(10).toList();

    // Har bir o'yinchini chizish
    for (int i = 0; i < displayList.length; i++) {
      final player = displayList[i];
      final yPos = 55.0 + (i * 20.0);
      final isMe = player['isMe'] as bool;
      final painter = isMe ? _leaderboardMePaint : _leaderboardOthersPaint;

      // Ism
      painter.render(
        canvas,
        "${i + 1}. ${player['name']}",
        Vector2(startX + 15, yPos),
      );

      // Score
      painter.render(
        canvas,
        _formatScore(player['score'] as int),
        Vector2(startX + boardWidth - 55, yPos),
      );
    }
  }

  /// Score formatini yaratish (1000 → 1K)
  String _formatScore(int score) {
    if (score < 1000) return score.toString();
    if (score < 10000) return '${(score / 1000).toStringAsFixed(1)}K';
    return '${(score / 1000).toInt()}K';
  }
}