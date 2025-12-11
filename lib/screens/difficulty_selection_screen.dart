import 'package:flutter/material.dart';
import '../models/difficulty.dart';
import '../utils/constants.dart';
import '../utils/storage.dart';
import 'game_screen.dart';

// =============================================================================
// DIFFICULTY SELECTION SCREEN - Qiyinchilik tanlash ekrani
// =============================================================================

class DifficultySelectionScreen extends StatelessWidget {
  const DifficultySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = StorageManager.instance;

    return Scaffold(
      backgroundColor: GameConstants.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'QIYINCHILIK TANLANG',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance for back button
                ],
              ),
            ),

            // Difficulty options
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildDifficultyCard(
                    context,
                    Difficulty.easy,
                    storage.getBestScore(Difficulty.easy),
                  ),
                  const SizedBox(height: 16),
                  _buildDifficultyCard(
                    context,
                    Difficulty.medium,
                    storage.getBestScore(Difficulty.medium),
                  ),
                  const SizedBox(height: 16),
                  _buildDifficultyCard(
                    context,
                    Difficulty.hard,
                    storage.getBestScore(Difficulty.hard),
                  ),

                  const SizedBox(height: 32),

                  // Info panel
                  _buildInfoPanel(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyCard(BuildContext context, Difficulty difficulty, int bestScore) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            difficulty.color.withOpacity(0.2),
            difficulty.color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: difficulty.color,
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GameScreen(difficulty: difficulty),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    // Emoji
                    Text(
                      difficulty.emoji,
                      style: const TextStyle(fontSize: 40),
                    ),
                    const SizedBox(width: 16),

                    // Name and description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            difficulty.name.toUpperCase(),
                            style: TextStyle(
                              color: difficulty.color,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            difficulty.description,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Play icon
                    Icon(
                      Icons.play_circle_fill,
                      color: difficulty.color,
                      size: 40,
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(color: Colors.white24),
                const SizedBox(height: 12),

                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn(
                      'Tezlik',
                      difficulty == Difficulty.easy
                          ? 'Sekin'
                          : difficulty == Difficulty.medium
                          ? 'O\'rtacha'
                          : 'Tez',
                      Icons.speed,
                    ),
                    _buildStatColumn(
                      'Ochko',
                      'x${difficulty.scoreMultiplier}',
                      Icons.star,
                    ),
                    _buildStatColumn(
                      'Coin',
                      'x${difficulty.coinMultiplier}',
                      Icons.monetization_on,
                    ),
                    _buildStatColumn(
                      'Best',
                      '$bestScore',
                      Icons.emoji_events,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 10,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GameConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: GameConstants.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: GameConstants.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'MALUMOT',
                style: TextStyle(
                  color: GameConstants.primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('😊 Oson', 'Sekin tezlik, kamroq qiyinchilik'),
          const SizedBox(height: 8),
          _buildInfoRow('😎 O\'rtacha', 'Standart tezlik, normal ochko'),
          const SizedBox(height: 8),
          _buildInfoRow('🔥 Qiyin', 'Tez tezlik, 2x ochko va coin!'),
          const SizedBox(height: 12),
          const Text(
            '💡 Qiyin rejimda ko\'proq coin topiladi!',
            style: TextStyle(
              color: Colors.amber,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• ', style: TextStyle(color: Colors.white70, fontSize: 16)),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$title: ',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}