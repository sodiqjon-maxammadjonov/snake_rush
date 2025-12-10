import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game/snake_game.dart';
import '../models/direction.dart';
import '../utils/constants.dart';

// =============================================================================
// GAME SCREEN - O'yin ekrani
// =============================================================================

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late SnakeGame game;
  int currentScore = 0;
  int currentCoins = 0;
  bool showGameOver = false;

  @override
  void initState() {
    super.initState();
    game = SnakeGame();

    // Callbacks
    game.onScoreUpdate = (score, coins) {
      setState(() {
        currentScore = score;
        currentCoins = coins;
      });
    };

    game.onGameOver = (score, coins, isNewBest) {
      setState(() {
        showGameOver = true;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameConstants.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar - Score va Coins
            _buildTopBar(),

            // O'yin maydoni
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Stack(
                    children: [
                      // Flame game
                      GameWidget(game: game),

                      // Swipe detector
                      GestureDetector(
                        onVerticalDragUpdate: (details) {
                          if (details.delta.dy > 5) {
                            game.changeDirection(Direction.down);
                          } else if (details.delta.dy < -5) {
                            game.changeDirection(Direction.up);
                          }
                        },
                        onHorizontalDragUpdate: (details) {
                          if (details.delta.dx > 5) {
                            game.changeDirection(Direction.right);
                          } else if (details.delta.dx < -5) {
                            game.changeDirection(Direction.left);
                          }
                        },
                      ),

                      // Game Over overlay
                      if (showGameOver) _buildGameOverOverlay(),
                    ],
                  ),
                ),
              ),
            ),

            // Control buttons (optional)
            _buildControlButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),

          // Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: GameConstants.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: GameConstants.primaryColor,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Text(
                  '$currentScore',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Coins
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: GameConstants.accentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: GameConstants.accentColor,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                const Text('🪙', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  '$currentCoins',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Up button
          _buildDirectionButton(Icons.arrow_upward, Direction.up),
          const SizedBox(height: 8),

          // Left, Down, Right buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDirectionButton(Icons.arrow_back, Direction.left),
              const SizedBox(width: 8),
              _buildDirectionButton(Icons.arrow_downward, Direction.down),
              const SizedBox(width: 8),
              _buildDirectionButton(Icons.arrow_forward, Direction.right),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionButton(IconData icon, Direction direction) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: GameConstants.primaryColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: GameConstants.primaryColor,
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => game.changeDirection(direction),
          borderRadius: BorderRadius.circular(15),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: GameConstants.backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: GameConstants.primaryColor,
              width: 3,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Game Over text
              const Text(
                'GAME OVER!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Score
              _buildStatRow('Score', currentScore, Icons.star, Colors.amber),
              const SizedBox(height: 12),

              // Coins
              _buildStatRow('Coins', currentCoins, Icons.monetization_on, GameConstants.accentColor),
              const SizedBox(height: 32),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Play Again
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showGameOver = false;
                        currentScore = 0;
                        currentCoins = 0;
                      });
                      game.restart();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GameConstants.secondaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'PLAY AGAIN',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Menu
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GameConstants.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'MENU',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, int value, IconData icon, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 18,
          ),
        ),
        Text(
          '$value',
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}