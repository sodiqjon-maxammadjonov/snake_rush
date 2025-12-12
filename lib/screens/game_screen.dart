import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game/snake_game.dart';
import '../models/direction.dart';
import '../models/difficulty.dart';
import '../utils/constants.dart';
import '../utils/storage.dart';

// =============================================================================
// GAME SCREEN - O'yin ekrani
// =============================================================================

class GameScreen extends StatefulWidget {
  final Difficulty difficulty;

  const GameScreen({
    super.key,
    this.difficulty = Difficulty.medium,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late SnakeGame game;
  int currentScore = 0;
  int currentCoins = 0;
  int totalCoins = 0; // Umumiy coinlar
  bool showGameOver = false;
  final StorageManager _storage = StorageManager.instance;

  @override
  void initState() {
    super.initState();
    totalCoins = _storage.getCoins(); // Umumiy coinlarni yuklash
    game = SnakeGame(difficulty: widget.difficulty);

    // Callbacks
    game.onScoreUpdate = (score, coins) {
      setState(() {
        currentScore = score;
        currentCoins = coins;
      });
    };

    game.onGameOver = (score, coins, isNewBest) {
      // Agar revive ishlatilmagan bo'lsa, revive dialog ko'rsat
      if (!game.hasRevived) {
        _showReviveDialog();
      } else {
        // Agar allaqachon revive ishlatilgan bo'lsa, oddiy game over
        setState(() {
          showGameOver = true;
        });
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameConstants.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar - Score va difficulty
            _buildTopBar(),

            // Coins header - Yuqorida
            _buildCoinsHeader(),

            const SizedBox(height: 8),

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
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),

          const Spacer(),

          // Difficulty indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget.difficulty.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: widget.difficulty.color,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Text(widget.difficulty.emoji, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  widget.difficulty.name,
                  style: TextStyle(
                    color: widget.difficulty.color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: GameConstants.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: GameConstants.primaryColor,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 6),
                Text(
                  '$currentScore',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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

  // Coins yuqorida - alohida widget (faqat ko'rsatish uchun)
  Widget _buildCoinsHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GameConstants.accentColor.withOpacity(0.3),
            GameConstants.accentColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: GameConstants.accentColor,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Umumiy coinlar
          Row(
            children: [
              const Text('🪙', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Umumiy',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    '$totalCoins',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // O'yindan olingan coinlar
          Row(
            children: [
              const Text('+', style: TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(width: 4),
              Text(
                '$currentCoins',
                style: TextStyle(
                  color: GameConstants.accentColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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

  // Revive Dialog - Game Over vaqtida
  void _showReviveDialog() {
    final canUseFreRevive = !_storage.hasUsedFreeReviveToday();
    final hasEnoughCoins = totalCoins >= GameConstants.reviveCost;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: GameConstants.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: GameConstants.primaryColor, width: 2),
        ),
        title: const Text(
          '💀 GAME OVER!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Score: $currentScore',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'DAVOM ETISH?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Bepul revive (agar mavjud bo'lsa)
            if (canUseFreRevive) ...[
              ElevatedButton(
                onPressed: () async {
                  await _storage.useFreeRevive();
                  await _storage.incrementTotalRevives();
                  game.revive();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'BEPUL DAVOM ETISH',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Coin bilan revive
            ElevatedButton(
              onPressed: hasEnoughCoins
                  ? () async {
                await _storage.spendCoins(GameConstants.reviveCost);
                await _storage.incrementTotalRevives();
                setState(() {
                  totalCoins = _storage.getCoins();
                });
                game.revive();
                Navigator.pop(context);
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: GameConstants.accentColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    '${GameConstants.reviveCost} COIN',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            if (!hasEnoughCoins)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Coinlar yetarli emas! (${totalCoins}/${GameConstants.reviveCost})',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // Reklama ko'rib revive (demo - real ads yo'q)
            OutlinedButton(
              onPressed: () async {
                // Demo: Reklama ko'rildi deb hisoblaymiz
                await _storage.incrementTotalRevives();
                game.revive();
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('📺 Reklama ko\'rildi! Davom eting!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.blue, width: 2),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_circle_outline, color: Colors.blue, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'REKLAMA KO\'RIB DAVOM ETISH',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Yo'q, game over
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  showGameOver = true;
                });
              },
              child: const Text(
                'YO\'Q, TUGAT',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}