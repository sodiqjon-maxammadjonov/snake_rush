import 'package:flutter/cupertino.dart';
import '../../utils/const_widgets/my_text.dart';
import '../../utils/widgets/coin_widget.dart';
import '../../utils/widgets/my_button.dart';
import '../../utils/const_widgets/game_background.dart';
import '../../utils/navigator/morph_navigator.dart';
import '../../utils/services/language/language_service.dart';
import '../../utils/ui/colors.dart';
import '../../utils/ui/dimensions.dart';
import '../settings/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey _settingsKey = GlobalKey();
  final _languageService = LanguageService();

  @override
  void initState() {
    super.initState();
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

  void _openSettings() {
    MorphNavigator.open(
      context: context,
      sourceKey: _settingsKey,
      child: const SettingsScreen(),
    );
  }

  String _tr(String key) => _languageService.translate(key);

  @override
  Widget build(BuildContext context) {
    final d = Dimensions(context);

    return CupertinoPageScaffold(
      child: GlassBubblesBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: d.maxContentWidth),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      d.paddingScreen,
                      d.spaceMedium,
                      d.paddingScreen,
                      0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyButton(
                          key: _settingsKey,
                          type: ButtonType.icon,
                          onPressed: _openSettings,
                          child: Text(
                            '⚙️',
                            style: TextStyle(fontSize: d.iconMedium),
                          ),
                        ),
                        const CoinWidget(coins: 7),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: d.paddingScreen),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            '🐍',
                            style: TextStyle(fontSize: d.iconHuge),
                          ),

                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              MyButton(
                                type: ButtonType.primary,
                                text: _tr('play'),
                                icon: CupertinoIcons.play_fill,
                                onPressed: () {},
                              ),

                              SizedBox(height: d.spaceLarge),

                              Row(
                                children: [
                                  _buildSmallButton('🛒', _tr('shop'), d),
                                  SizedBox(width: d.spaceMedium),
                                  _buildSmallButton('🏆', _tr('top'), d),
                                  SizedBox(width: d.spaceMedium),
                                  _buildSmallButton('👤', _tr('me'), d),
                                ],
                              ),
                            ],
                          ),

                          MyButton(
                            type: ButtonType.glass,
                            width: double.infinity,
                            height: d.cardHeight,
                            onPressed: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('🎁', style: TextStyle(fontSize: d.iconMedium)),
                                SizedBox(width: d.spaceMedium),
                                Flexible(
                                  child: MyText(
                                    _tr('daily_reward'),
                                    fontSize: d.bodySmall,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: d.spaceMedium),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallButton(String emoji, String title, Dimensions d) {
    return Expanded(
      child: MyButton(
        type: ButtonType.glass,
        height: d.cardHeightSmall,
        onPressed: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: TextStyle(fontSize: d.iconMedium)),
            SizedBox(height: d.spaceTiny),
            MyText(
              title,
              fontSize: d.caption,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}