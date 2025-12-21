import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'snake.dart';

class ScoreDisplay extends PositionComponent with HasGameRef {
  final Snake player;
  late final TextPaint _scorePaint;
  late final TextPaint _lengthPaint;

  // Leaderboard uchun ikki xil uslub
  late final TextPaint _leaderboardOthersPaint;
  late final TextPaint _leaderboardMePaint;
  late final TextPaint _leaderboardTitlePaint;

  late final Paint _bgPaint;

  ScoreDisplay({required this.player}) {
    priority = 100;
  }

  @override
  Future<void> onLoad() async {
    // 1. Shaxsiy statistika (Chap tomonda)
    _scorePaint = TextPaint(
      style: const TextStyle(
        color: Color(0xFF4ECDC4),
        fontSize: 24,
        fontWeight: FontWeight.bold,
        shadows: [Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 3)],
      ),
    );

    _lengthPaint = TextPaint(
      style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
    );

    // 2. Leaderboard Title
    _leaderboardTitlePaint = TextPaint(
      style: const TextStyle(color: Colors.orangeAccent, fontSize: 14, fontWeight: FontWeight.bold),
    );

    // 3. Boshqa o'yinchilar uchun uslub
    _leaderboardOthersPaint = TextPaint(
      style: const TextStyle(color: Colors.white70, fontSize: 12),
    );

    // 4. "O'zim" uchun yashil neon uslub
    _leaderboardMePaint = TextPaint(
      style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold),
    );

    _bgPaint = Paint()..color = Colors.black.withOpacity(0.4)..style = PaintingStyle.fill;
  }

  @override
  void render(Canvas canvas) {
    _renderPlayerStats(canvas);
    _renderLeaderboard(canvas);
  }

  void _renderPlayerStats(Canvas canvas) {
    final scoreStr = _formatScore(player.totalScore);
    final lengthStr = "Length: ${player.currentLength}";

    // Statistika foni
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(20, 160, 160, 65), const Radius.circular(12)), _bgPaint);

    _scorePaint.render(canvas, scoreStr, Vector2(35, 170));
    _lengthPaint.render(canvas, lengthStr, Vector2(35, 200));
  }

  void _renderLeaderboard(Canvas canvas) {
    double viewWidth = gameRef.size.x;
    double boardWidth = 180;
    double startX = viewWidth - boardWidth - 20;

    // Leaderboard foni
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(startX, 20, boardWidth, 190), const Radius.circular(12)), _bgPaint);

    _leaderboardTitlePaint.render(canvas, "TOP 10 SERPENTS", Vector2(startX + 15, 30));

    // O'yinchilar ro'yxati (Kelajakda buni dynamic botlar ro'yxati bilan almashtirasiz)
    List<Map<String, dynamic>> topPlayers = [
      {"name": "Rex", "score": 25000, "isMe": false},
      {"name": "Shadow", "score": 15400, "isMe": false},
      {"name": "Viper", "score": 9800, "isMe": false},
      {"name": "You", "score": player.totalScore, "isMe": true}, // SIZ
      {"name": "Naga", "score": 7500, "isMe": false},
    ];

    // Score bo'yicha saralash (Optionally)
    topPlayers.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

    for (int i = 0; i < topPlayers.length; i++) {
      final p = topPlayers[i];
      final yPos = 55.0 + (i * 20.0);

      // ISHNI TO'G'IRLADIK: Style final bo'lgani uchun, painter ob'ektini o'zini tanlab olamiz
      final currentPainter = p['isMe'] ? _leaderboardMePaint : _leaderboardOthersPaint;

      currentPainter.render(canvas, "${i + 1}. ${p['name']}", Vector2(startX + 15, yPos));
      currentPainter.render(canvas, _formatScore(p['score']), Vector2(startX + boardWidth - 55, yPos));
    }
  }

  String _formatScore(int score) {
    if (score < 1000) return score.toString();
    if (score < 10000) return '${(score / 1000).toStringAsFixed(1)}K';
    return '${(score / 1000).toInt()}K';
  }
}