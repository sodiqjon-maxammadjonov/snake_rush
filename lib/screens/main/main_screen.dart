import 'package:flutter/cupertino.dart';
import 'package:snake_rush/utils/const_widgets/my_text.dart';
import 'package:snake_rush/utils/widgets/coin_widget.dart';
import '../../utils/const_widgets/game_background.dart';
import '../../utils/widgets/morph_navigator.dart';
import '../settings/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey _settingsKey = GlobalKey();

  void _openSettings() {
    MorphNavigator.open(
      context: context,
      sourceKey: _settingsKey,
      builder: (animation, position, size) {
        return SettingsScreen(
          animation: animation,
          startPosition: position,
          startSize: size,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return CupertinoPageScaffold(
      child: GlassBubblesBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.06),
            child: Column(
              children: [
                SizedBox(height: w * 0.04),

                /// TOP BAR
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      key: _settingsKey,
                      padding: EdgeInsets.zero,
                      minSize: 0,
                      onPressed: _openSettings,
                      child: const Text(
                        '⚙️',
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                    const CoinWidget(coins: 7),
                  ],
                ),

                SizedBox(height: h * 0.08),

                Center(
                  child: MyText('🐍', fontSize: 60),
                ),

                const Spacer(),

                /// PLAY BUTTON
                Container(
                  width: w * 0.7,
                  height: w * 0.16,
                  decoration: BoxDecoration(
                    color: CupertinoColors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(w * 0.035),
                  ),
                  child: Center(
                    child: MyText(
                      'Play',
                      fontSize: 22,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),

                SizedBox(height: h * 0.03),

                /// SECONDARY BUTTONS
                Row(
                  children: [
                    _smallButton('🛒', 'SHOP', w),
                    SizedBox(width: w * 0.03),
                    _smallButton('🏆', 'TOP', w),
                    SizedBox(width: w * 0.03),
                    _smallButton('👤', 'ME', w),
                  ],
                ),

                const Spacer(),

                /// BOTTOM PANEL
                Container(
                  width: w * 0.88,
                  height: w * 0.18,
                  decoration: BoxDecoration(
                    color: CupertinoColors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(w * 0.04),
                  ),
                  child: const Center(
                    child: Text('🎁 DAILY REWARD / NEWS'),
                  ),
                ),

                SizedBox(height: h * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _smallButton(String emoji, String title, double w) {
    return Expanded(
      child: Container(
        height: w * 0.14,
        decoration: BoxDecoration(
          color: CupertinoColors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(w * 0.035),
        ),
        child: Center(
          child: Text(
            '$emoji $title',
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }
}
