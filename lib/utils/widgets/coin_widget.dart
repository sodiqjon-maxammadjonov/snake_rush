import 'package:flutter/cupertino.dart';
import '../const_widgets/my_text.dart';
import '../services/audio/audio_manager.dart';
import '../ui/colors.dart';
import '../ui/dimensions.dart';

class CoinWidget extends StatelessWidget {
  final int coins;
  final int maxCoins;
  final VoidCallback? onAddPressed;

  const CoinWidget({
    super.key,
    this.coins = 0,
    this.maxCoins = 7777777,
    this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final d = Dimensions(context);
    final coinText = coins.clamp(0, maxCoins).toString();

    return Container(
      height: d.backButtonSize,
      padding: EdgeInsets.symmetric(
        horizontal: d.spaceMedium,
        vertical: d.spaceSmall,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.coinGradient,
        borderRadius: BorderRadius.circular(d.radiusMedium),
        border: Border.all(
          color: AppColors.glassBorder,
          width: d.borderMedium,
        ),
        boxShadow: AppColors.coinShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '🪙',
            style: TextStyle(fontSize: d.iconSmall),
          ),
          SizedBox(width: d.spaceSmall),
          MyText(
            coinText,
            fontSize: d.bodySmall,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          SizedBox(width: d.spaceMedium),
          GestureDetector(
            onTap: () {
              AudioManager().playButtonClick();
              onAddPressed?.call();
            },
            child: Container(
              width: d.iconMedium,
              height: d.iconMedium,
              decoration: BoxDecoration(
                color: CupertinoColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(d.radiusSmall),
                border: Border.all(
                  color: CupertinoColors.white.withOpacity(0.4),
                  width: d.borderMedium,
                ),
              ),
              child: Icon(
                CupertinoIcons.add,
                color: AppColors.textPrimary,
                size: d.iconSmall,
              ),
            ),
          ),
        ],
      ),
    );
  }
}