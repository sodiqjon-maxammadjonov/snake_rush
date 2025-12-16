import 'package:flutter/cupertino.dart';
import '../const_widgets/my_text.dart';
import '../services/audio/audio_manager.dart';
import '../services/storage/storage_service.dart';
import '../ui/colors.dart';
import '../ui/dimensions.dart';

class CoinWidget extends StatefulWidget {
  final int? coins;
  final int maxCoins;
  final VoidCallback? onAddPressed;
  final bool showAddButton;

  const CoinWidget({
    super.key,
    this.coins,
    this.maxCoins = 7777777,
    this.onAddPressed,
    this.showAddButton = true,
  });

  @override
  State<CoinWidget> createState() => _CoinWidgetState();
}

class _CoinWidgetState extends State<CoinWidget> {
  final _storage = StorageService();
  int _currentCoins = 0;

  @override
  void initState() {
    super.initState();
    _loadCoins();
  }

  Future<void> _loadCoins() async {
    if (widget.coins != null) {
      setState(() => _currentCoins = widget.coins!);
    } else {
      final coins = _storage.getInt('user_coins', 0);
      setState(() => _currentCoins = coins);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = Dimensions(context);
    final coinText = _currentCoins.clamp(0, widget.maxCoins).toString();

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
          if (widget.showAddButton) ...[
            SizedBox(width: d.spaceMedium),
            GestureDetector(
              onTap: () {
                AudioManager().playButtonClick();
                widget.onAddPressed?.call();
              },
              child: Container(
                width: d.iconMedium,
                height: d.iconMedium,
                decoration: BoxDecoration(
                  color: CupertinoColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(d.radiusSmall),
                  border: Border.all(
                    color: CupertinoColors.white.withValues(alpha: 0.4),
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
        ],
      ),
    );
  }
}