import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/navigator/morph_navigator.dart';
import '../../utils/widgets/my_button.dart';
import '../../utils/const_widgets/my_text.dart';
import '../../utils/ui/colors.dart';
import '../../utils/ui/dimensions.dart';
import '../../utils/services/service_locator.dart';
import '../../utils/services/language/language_service.dart';
import '../../utils/services/audio/audio_manager.dart';
import '../../utils/services/storage/storage_service.dart';
import '../screens/settings/settings_screen.dart';
import 'hungry_serpend_game.dart';
import 'dart:ui' as ui;

class GamePlayScreen extends StatefulWidget {
  const GamePlayScreen({super.key});

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> with SingleTickerProviderStateMixin {
  late final HungrySnakeGame _game;
  late final LanguageService _languageService;
  late final AudioManager _audioManager;
  late final StorageService _storage;

  bool _isPaused = false;
  bool _isGameOver = false;
  final GlobalKey _settingsButtonKey = GlobalKey();

  late AnimationController _gameOverController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _game = HungrySnakeGame();
    _game.onGameOver = _showGameOver;

    _languageService = getIt<LanguageService>();
    _languageService.addListener(_onLanguageChanged);

    _audioManager = getIt<AudioManager>();
    _storage = getIt<StorageService>();

    _gameOverController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _gameOverController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _gameOverController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _languageService.removeListener(_onLanguageChanged);
    _gameOverController.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _onLanguageChanged() => setState(() {});

  String _tr(String key) => _languageService.translate(key);

  void _showGameOver() {
    _audioManager.playGameOverSound();
    setState(() => _isGameOver = true);
    _gameOverController.forward();
  }

  void _onPausePressed() {
    setState(() => _isPaused = true);
    _game.pauseEngine();
  }

  void _onResumePressed() {
    _game.updateSettings();
    _game.resumeEngine();
    setState(() => _isPaused = false);
  }

  void _openSettings() {
    MorphNavigator.open(
      context: context,
      sourceKey: _settingsButtonKey,
      child: const SettingsScreen(),
    );
  }

  void _exitGame() => Navigator.of(context).pop();

  void _playAgain() {
    _gameOverController.reset();
    setState(() {
      _isGameOver = false;
    });
    _game.restart();
  }

  void _revivePlayer() {
    _gameOverController.reset();
    setState(() {
      _isGameOver = false;
    });
    _game.revivePlayer();
  }

  @override
  Widget build(BuildContext context) {
    final d = Dimensions(context);
    final safePadding = MediaQuery.of(context).padding;

    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
          _game.playerSnake.setBoost(true);
        } else if (event is KeyUpEvent && event.logicalKey == LogicalKeyboardKey.space) {
          _game.playerSnake.setBoost(false);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            GameWidget(game: _game),

            if (!_isPaused && !_isGameOver) _buildPauseButton(safePadding),

            if (!_isPaused && !_isGameOver) _buildBoostButton(safePadding),

            if (_isPaused) _buildPauseOverlay(d),

            if (_isGameOver) _buildGameOverOverlay(d),
          ],
        ),
      ),
    );
  }

  Widget _buildPauseButton(EdgeInsets safePadding) {
    return Positioned(
      top: safePadding.top + 8,
      right: 16,
      child: MyButton(
        type: ButtonType.icon,
        width: 40,
        height: 40,
        backgroundColor: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
        icon: CupertinoIcons.pause,
        onPressed: _onPausePressed,
      ),
    );
  }

  Widget _buildBoostButton(EdgeInsets safePadding) {
    final joystickSide = _storage.joystickSide;
    final isBoostOnLeft = joystickSide == 'right';

    return Positioned(
      bottom: safePadding.bottom + 80,
      left: isBoostOnLeft ? 20 : null,
      right: isBoostOnLeft ? null : 20,
      child: GestureDetector(
        onTapDown: (_) => _game.playerSnake.setBoost(true),
        onTapUp: (_) => _game.playerSnake.setBoost(false),
        onTapCancel: () => _game.playerSnake.setBoost(false),
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [
                Color(0xFFFFD700),
                Color(0xFFFF8C00),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.6),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            CupertinoIcons.bolt_fill,
            color: Colors.white,
            size: 35,
          ),
        ),
      ),
    );
  }

  Widget _buildPauseOverlay(Dimensions d) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          width: d.maxContentWidth * 0.5,
          padding: EdgeInsets.all(d.spaceLarge),
          decoration: BoxDecoration(
            color: AppColors.bgMedium.withOpacity(0.95),
            borderRadius: BorderRadius.circular(d.radiusLarge),
            border: Border.all(
              color: AppColors.glassBorder,
              width: 1.5,
            ),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyText(
                _tr('paused'),
                fontSize: d.title,
                bold: true,
                color: AppColors.textPrimary,
                letterSpacing: 2,
              ),
              SizedBox(height: d.spaceMedium),

              MyButton(
                type: ButtonType.primary,
                width: double.infinity,
                height: 48,
                text: _tr('resume'),
                icon: CupertinoIcons.play_fill,
                onPressed: _onResumePressed,
              ),
              SizedBox(height: d.spaceSmall),

              MyButton(
                key: _settingsButtonKey,
                type: ButtonType.glass,
                width: double.infinity,
                height: 48,
                text: _tr('settings').toUpperCase(),
                icon: CupertinoIcons.settings,
                onPressed: _openSettings,
              ),
              SizedBox(height: d.spaceSmall),

              MyButton(
                type: ButtonType.secondary,
                width: double.infinity,
                height: 48,
                text: _tr('exit'),
                textColor: CupertinoColors.systemRed,
                icon: CupertinoIcons.clear,
                backgroundColor: CupertinoColors.systemRed.withOpacity(0.1),
                onPressed: _exitGame,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay(Dimensions d) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        color: Colors.black.withOpacity(0.85),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: d.maxContentWidth * 0.85,
                padding: EdgeInsets.all(d.spaceLarge),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1E1E2E).withOpacity(0.95),
                      const Color(0xFF2D2D44).withOpacity(0.95),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(d.radiusLarge),
                  border: Border.all(color: AppColors.glassBorder, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFFF5252), Color(0xFFFF1744)],
                      ).createShader(bounds),
                      child: MyText(
                        'GAME OVER',
                        fontSize: d.title * 1.5,
                        bold: true,
                        color: Colors.white,
                        letterSpacing: 4,
                      ),
                    ),
                    SizedBox(height: d.spaceMedium),

                    MyText(
                      'Score: ${_game.playerSnake.totalScore}',
                      fontSize: d.subtitle,
                      bold: true,
                      color: const Color(0xFF4ECDC4),
                    ),
                    SizedBox(height: d.spaceLarge),

                    MyButton(
                      type: ButtonType.primary,
                      width: double.infinity,
                      height: 56,
                      text: '👁️ CONTINUE (+1 LIFE)',
                      icon: CupertinoIcons.play_circle_fill,
                      onPressed: _revivePlayer,
                    ),
                    SizedBox(height: d.spaceSmall),

                    MyButton(
                      type: ButtonType.glass,
                      width: double.infinity,
                      height: 50,
                      text: 'PLAY AGAIN',
                      icon: CupertinoIcons.refresh,
                      onPressed: _playAgain,
                    ),
                    SizedBox(height: d.spaceSmall),

                    MyButton(
                      type: ButtonType.secondary,
                      width: double.infinity,
                      height: 50,
                      text: 'MAIN MENU',
                      icon: CupertinoIcons.home,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      onPressed: _exitGame,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}