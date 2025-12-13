import 'package:flutter/cupertino.dart';
import 'package:snake_rush/utils/values/game_constants.dart';

class CoinWidget extends StatelessWidget {
  final int coins;
  final int maxCoins;

  const CoinWidget({
    super.key,
    this.coins = 0,
    this.maxCoins = 7777777,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    final coinText = coins.clamp(0, maxCoins).toString();

    return IntrinsicWidth(
      child: Container(
        height: w * 0.1,
        padding: EdgeInsets.symmetric(horizontal: w * 0.02),
        decoration: BoxDecoration(
          gradient: GameConstants.coinGradient.withOpacity(0.7),
          borderRadius: BorderRadius.circular(w * 0.03),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemYellow.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  '🪙',
                  style: TextStyle(fontSize: w * 0.05),
                ),
                SizedBox(width: w * 0.015),
                Text(
                  coinText,
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontSize: w * 0.038,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),

            SizedBox(width: w * 0.02),

            CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 0,
              onPressed: () {
                // Coin sotib olish
              },
              child: Container(
                width: w * 0.06,
                height: w * 0.06,
                decoration: BoxDecoration(
                  color: CupertinoColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(w * 0.018),
                  border: Border.all(
                    color: CupertinoColors.white.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  CupertinoIcons.add,
                  color: CupertinoColors.white,
                  size: w * 0.04,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
