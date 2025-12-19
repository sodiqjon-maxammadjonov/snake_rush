import 'package:flutter/cupertino.dart';
import 'package:snake_rush/screens/other/skin/skins_screen.dart';
import 'package:snake_rush/screens/shop/coin_shop_screen.dart';
import 'package:snake_rush/utils/const_widgets/my_text.dart';
import 'package:snake_rush/utils/widgets/coin_widget.dart';
import 'package:snake_rush/utils/widgets/my_button.dart';
import '../../game/screen/game_loading screen.dart';
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
  final GlobalKey _coinShopKey = GlobalKey();
  final GlobalKey _skinsKey = GlobalKey();
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

  void _onLanguageChanged() => setState(() {});

  void _openSettings() {
    MorphNavigator.open(
      context: context,
      sourceKey: _settingsKey,
      child: const SettingsScreen(),
    );
  }

  void _openCoinShop() {
    MorphNavigator.open(
      context: context,
      sourceKey: _coinShopKey,
      child: const CoinShopScreen(),
    );
  }

  void _openSkinsScreen() {
    MorphNavigator.open(
      context: context,
      sourceKey: _skinsKey,
      child: const SkinsScreen(),
    );
  }

  void _play() {
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (_) => const GamePlayScreen()),
    );
  }

  String _tr(String key) => _languageService.translate(key);

  @override
  Widget build(BuildContext context) {
    final d = Dimensions(context);

    return CupertinoPageScaffold(
      child: GlassBubblesBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: d.paddingScreen,
              vertical: d.spaceMedium,
            ),
            child: Column(
              children: [
                // ✅ TOP BAR - Settings va Coins
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyButton(
                      key: _settingsKey,
                      type: ButtonType.icon,
                      width: d.backButtonSize,
                      height: d.backButtonSize,
                      onPressed: _openSettings,
                      child: Text('⚙️', style: TextStyle(fontSize: d.iconMedium)),
                    ),
                    CoinWidget(
                      onAddPressed: _openCoinShop,
                      key: _coinShopKey,
                    ),
                  ],
                ),

                const Spacer(),

                // ✅ CENTER - Play Button
                MyButton(
                  type: ButtonType.primary,
                  width: d.buttonWidth * 1.8,
                  height: d.buttonHeight * 1.3,
                  text: _tr('play'),
                  icon: CupertinoIcons.play_fill,
                  onPressed: _play,
                ),

                SizedBox(height: d.spaceLarge),

                // ✅ MENU BUTTONS - Shop, Top, Me
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildMenuCard('🛒', _tr('shop'), d,onTap: _openSkinsScreen,key: _skinsKey),
                    SizedBox(width: d.spaceMedium),
                    _buildMenuCard('🏆', _tr('top'), d),
                    SizedBox(width: d.spaceMedium),
                    _buildMenuCard('👤', _tr('me'), d),
                  ],
                ),

                const Spacer(),

                // ✅ BOTTOM - Daily Reward
                MyButton(
                  type: ButtonType.glass,
                  width: d.buttonWidth * 1.8,
                  height: d.cardHeightSmall,
                  onPressed: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🎁', style: TextStyle(fontSize: d.iconMedium)),
                      SizedBox(width: d.spaceMedium),
                      MyText(
                        _tr('daily_reward'),
                        fontSize: d.body,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildMenuCard(
      String emoji,
      String title,
      Dimensions d, {
        VoidCallback? onTap,
        Key? key,
      }) {
    return Expanded(
      child: MyButton(
        key: key,
        type: ButtonType.glass,
        height: d.cardHeightSmall,
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: TextStyle(fontSize: d.iconMedium)),
            SizedBox(width: d.spaceTiny),
            MyText(
              title,
              fontSize: d.caption,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

}