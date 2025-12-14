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
    setState(() {});
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
    final screenHeight = MediaQuery.of(context).size.height;
    final safeTop = MediaQuery.of(context).padding.top;
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final availableHeight = screenHeight - safeTop - safeBottom;

    return CupertinoPageScaffold(
      child: GlassBubblesBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                    maxWidth: d.maxContentWidth,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: d.paddingScreen,
                        vertical: d.spaceMedium,
                      ),
                      child: Column(
                        children: [
                          Row(
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

                          SizedBox(height: availableHeight * 0.1),

                          Text(
                            '🐍',
                            style: TextStyle(fontSize: d.iconHuge),
                          ),

                          const Spacer(),

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

                          const Spacer(),

                          MyButton(
                            type: ButtonType.glass,
                            width: double.infinity,
                            height: d.cardHeight,
                            onPressed: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
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

                          SizedBox(height: d.spaceMedium),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
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
            Flexible(
              child: MyText(
                title,
                fontSize: d.caption,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}