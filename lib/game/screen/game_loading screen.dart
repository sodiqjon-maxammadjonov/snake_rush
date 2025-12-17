import 'package:flutter/cupertino.dart';
import 'package:flame/game.dart';
import 'package:snake_rush/game/hungry_serpend_game.dart';
import 'package:snake_rush/utils/services/audio/audio_manager.dart';
import 'package:snake_rush/utils/services/service_locator.dart';
import '../../utils/const_widgets/game_background.dart';
import '../../utils/ui/colors.dart';

/// Game Loading Screen - O'yin yuklanishi uchun
class GameLoadingScreen extends StatefulWidget {
  const GameLoadingScreen({super.key});

  @override
  State<GameLoadingScreen> createState() => _GameLoadingScreenState();
}

class _GameLoadingScreenState extends State<GameLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  HungrySerpentGame? _game;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.repeat(reverse: true);
    _loadGame();
  }

  Future<void> _loadGame() async {
    // Background musiqani to'xtatish
    final audioManager = getIt<AudioManager>();
    await audioManager.pauseBackgroundMusic();

    // Game obyektini yaratish (lekin onLoad chaqirmaslik!)
    await Future.delayed(const Duration(milliseconds: 500));
    _game = HungrySerpentGame();
    // ❌ BU QATORNI O'CHIRDIK: await _game!.onLoad();

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() => _isLoading = false);
      _navigateToGame();
    }
  }

  void _navigateToGame() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
            builder: (_) => GameWidget(game: _game!),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: GlassBubblesBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Snake emoji
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  '🐍',
                  style: TextStyle(fontSize: 120),
                ),
              ),

              const SizedBox(height: 40),

              // Loading text
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'ENTERING SNAKE WORLD',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: 2,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Loading indicator
              CupertinoActivityIndicator(
                radius: 16,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}