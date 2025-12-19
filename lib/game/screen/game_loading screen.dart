import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:snake_rush/screens/settings/settings_screen.dart';
import 'package:snake_rush/utils/navigator/morph_navigator.dart';
import 'package:snake_rush/utils/widgets/my_button.dart';
import '../../utils/const_widgets/my_text.dart';
import '../../utils/ui/colors.dart';
import '../../utils/ui/dimensions.dart';
import '../../utils/services/service_locator.dart';
import '../../utils/services/language/language_service.dart';
import '../hungry_serpend_game.dart';

class GamePlayScreen extends StatefulWidget {
  const GamePlayScreen({super.key});

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  final HungrySnakeGame _game = HungrySnakeGame();
  late final LanguageService _languageService;
  bool _isPaused = false;
  final GlobalKey _settingsButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _languageService = getIt<LanguageService>();
    _languageService.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    _languageService.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() => setState(() {});

  String _tr(String key) => _languageService.translate(key);

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

  @override
  Widget build(BuildContext context) {
    final d = Dimensions(context);
    final safePadding = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GameWidget(game: _game),

          if (!_isPaused)
            Positioned(
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
            ),

          if (_isPaused)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Container(
                  width: d.maxContentWidth * 0.5,
                  padding: EdgeInsets.all(d.spaceLarge),
                  decoration: BoxDecoration(
                    color: AppColors.bgMedium.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(d.radiusLarge),
                    border: Border.all(color: AppColors.glassBorder, width: 1.5),
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
            ),
        ],
      ),
    );
  }
}