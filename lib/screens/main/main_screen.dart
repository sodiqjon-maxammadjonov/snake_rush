import 'package:flutter/cupertino.dart';
import 'package:snake_rush/screens/shop/shop_screen.dart';
import 'package:snake_rush/utils/const_widgets/my_text.dart';
import 'package:snake_rush/utils/widgets/coin_widget.dart';
import 'package:snake_rush/utils/widgets/my_button.dart';
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
  final GlobalKey _shopKey = GlobalKey();
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

  void _openShop(){
    MorphNavigator.open(
        context: context,
        sourceKey: _shopKey,
        child: const ShopScreen()
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
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: d.paddingScreen),
                child: Column(
                  children: [
                    SizedBox(height: d.spaceLarge),

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
                        const CoinWidget(onAddPressed: null),
                      ],
                    ),

                    SizedBox(height: d.spaceHuge),

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
                        _buildSmallButton('🛒', _tr('shop'), d, onPressed: _openShop, key: _shopKey),
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
                          MyText(
                            _tr('daily_reward'),
                            fontSize: d.bodySmall,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: d.spaceLarge),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallButton(
      String emoji,
      String title,
      Dimensions d, {
        VoidCallback? onPressed,
        Key? key,
      }) {
    return Expanded(
      child: MyButton(
        key: key,
        type: ButtonType.glass,
        height: d.cardHeightSmall,
        onPressed: onPressed ?? () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: TextStyle(fontSize: d.iconMedium)),
            SizedBox(height: d.spaceTiny),
            MyText(
              title,
              fontSize: d.caption,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}