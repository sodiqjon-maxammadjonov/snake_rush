import 'package:flutter/cupertino.dart';
import '../../utils/const_widgets/my_text.dart';
import '../../utils/widgets/my_button.dart';
import '../../utils/navigator/morph_navigator.dart';
import '../../utils/services/audio/audio_manager.dart';
import '../../utils/services/language/language_service.dart';
import '../../utils/ui/colors.dart';
import '../../utils/ui/dimensions.dart';
import '../leaderboard/leaderboard_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GlobalKey _leaderboardKey = GlobalKey();
  final GlobalKey _languageKey = GlobalKey();
  final _audioManager = AudioManager();
  final _languageService = LanguageService();

  late double _gameVolume;
  late double _musicVolume;

  @override
  void initState() {
    super.initState();
    _gameVolume = _audioManager.gameVolume;
    _musicVolume = _audioManager.musicVolume;
    _languageService.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    _languageService.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  void _openLeaderboard() {
    MorphNavigator.open(
      context: context,
      sourceKey: _leaderboardKey,
      child: const LeaderBoardScreen(),
    );
  }

  void _openLanguageSelector() {
    MorphNavigator.open(
      context: context,
      sourceKey: _languageKey,
      child: const LanguageSelectorScreen(),
    );
  }

  String _tr(String key) => _languageService.translate(key);

  @override
  Widget build(BuildContext context) {
    final d = Dimensions(context);
    final navBarHeight =
        CupertinoNavigationBar().preferredSize.height +
            MediaQuery.of(context).padding.top;
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.transparent,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.transparent,
        border: null,
        leading: MyButton(
          type: ButtonType.icon,
          icon: CupertinoIcons.back,
          onPressed: () => Navigator.of(context).pop(),
        ),
        middle: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🪙', style: TextStyle(fontSize: d.iconMedium)),
            SizedBox(width: d.spaceSmall),
            MyText(
              _tr('settings'),
              fontSize: d.title,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: d.maxContentWidth),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: d.paddingScreen),
                physics: const BouncingScrollPhysics(),
                children: [

                  SizedBox(height: navBarHeight),
                  SizedBox(height: d.spaceLarge),

                  _buildVolumeControl(
                    d: d,
                    icon: '🎮',
                    title: _tr('game_sound'),
                    volume: _gameVolume,
                    onChanged: (value) {
                      setState(() => _gameVolume = value);
                      _audioManager.setGameVolume(value);
                    },
                  ),

                  SizedBox(height: d.space),

                  _buildVolumeControl(
                    d: d,
                    icon: '🎵',
                    title: _tr('music'),
                    volume: _musicVolume,
                    onChanged: (value) {
                      setState(() => _musicVolume = value);
                      _audioManager.setMusicVolume(value);
                    },
                  ),

                  SizedBox(height: d.spaceXLarge),

                  _buildGameOption(
                    d: d,
                    key: _leaderboardKey,
                    icon: '🏆',
                    title: _tr('leaderboard'),
                    onTap: _openLeaderboard,
                  ),

                  SizedBox(height: d.spaceMedium),

                  _buildGameOption(
                    d: d,
                    icon: '❓',
                    title: _tr('how_to_play'),
                    onTap: () {},
                  ),

                  SizedBox(height: d.spaceMedium),

                  _buildGameOption(
                    d: d,
                    icon: '📱',
                    title: _tr('share_game'),
                    onTap: () {},
                  ),

                  SizedBox(height: d.spaceMedium),

                  _buildGameOption(
                    d: d,
                    key: _languageKey,
                    icon: _languageService.flag,
                    title: _tr('language'),
                    subtitle: _languageService.name,
                    onTap: _openLanguageSelector,
                  ),

                  SizedBox(height: d.spaceXLarge),

                  Center(
                    child: MyText(
                      'Snake Rush v1.0',
                      fontSize: d.caption,
                      color: AppColors.textMuted,
                    ),
                  ),

                  SizedBox(height: d.spaceLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeControl({
    required Dimensions d,
    required String icon,
    required String title,
    required double volume,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassLight,
        borderRadius: BorderRadius.circular(d.radius),
        border: Border.all(
          color: AppColors.glassBorder,
          width: d.borderMedium,
        ),
      ),
      padding: EdgeInsets.all(d.paddingCard),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(icon, style: TextStyle(fontSize: d.iconMedium)),
              SizedBox(width: d.spaceMedium),
              Expanded(
                child: MyText(
                  title,
                  fontSize: d.body,
                  color: AppColors.textPrimary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              MyText(
                '${(volume * 100).toInt()}%',
                fontSize: d.body,
                color: CupertinoColors.activeBlue,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          SizedBox(height: d.spaceMedium),
          Row(
            children: [
              Text(
                volume == 0 ? '🔇' : '🔉',
                style: TextStyle(fontSize: d.iconSmall),
              ),
              Expanded(
                child: CupertinoSlider(
                  value: volume,
                  min: 0.0,
                  max: 1.0,
                  activeColor: CupertinoColors.activeBlue,
                  onChanged: onChanged,
                ),
              ),
              Text('🔊', style: TextStyle(fontSize: d.iconSmall)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameOption({
    required Dimensions d,
    required String icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Key? key,
  }) {
    return MyButton(
      key: key,
      type: ButtonType.secondary,
      width: double.infinity,
      onPressed: onTap,
      child: Row(
        children: [
          Text(icon, style: TextStyle(fontSize: d.iconMedium)),
          SizedBox(width: d.spaceMedium),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                MyText(
                  title,
                  fontSize: d.body,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  SizedBox(height: d.spaceTiny),
                  MyText(
                    '  : $subtitle',
                    fontSize: d.caption,
                    color: AppColors.textSecondary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: d.spaceSmall),
          Icon(
            CupertinoIcons.chevron_right,
            size: d.iconSmall,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class LanguageSelectorScreen extends StatelessWidget {
  const LanguageSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final d = Dimensions(context);
    final languageService = LanguageService();

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: d.maxContentWidth),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(d.space),
                child: Row(
                  children: [
                    MyButton(
                      type: ButtonType.icon,
                      icon: CupertinoIcons.back,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🌐', style: TextStyle(fontSize: d.iconMedium)),
                          SizedBox(width: d.spaceSmall),
                          Flexible(
                            child: MyText(
                              languageService.translate('language'),
                              fontSize: d.title,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: d.backButtonSize),
                  ],
                ),
              ),

              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: d.paddingScreen,
                    vertical: d.spaceMedium,
                  ),
                  itemCount: languageService.availableLanguages.length,
                  separatorBuilder: (_, __) => SizedBox(height: d.spaceMedium),
                  itemBuilder: (context, index) {
                    final language = languageService.availableLanguages[index];
                    final isSelected = language.code == languageService.currentLanguage;

                    return MyButton(
                      type: ButtonType.glass,
                      width: double.infinity,
                      onPressed: () {
                        languageService.setLanguage(language.code);
                        Navigator.of(context).pop();
                      },
                      child: Row(
                        children: [
                          Text(
                            language.flag,
                            style: TextStyle(fontSize: d.iconMedium),
                          ),
                          SizedBox(width: d.spaceMedium),
                          Expanded(
                            child: MyText(
                              language.name,
                              fontSize: d.body,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: AppColors.textPrimary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isSelected) ...[
                            SizedBox(width: d.spaceSmall),
                            Icon(
                              CupertinoIcons.check_mark_circled_solid,
                              color: CupertinoColors.activeBlue,
                              size: d.iconMedium,
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}