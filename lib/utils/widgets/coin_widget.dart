import 'package:flutter/cupertino.dart';
import '../const_widgets/my_text.dart';
import '../services/audio/audio_manager.dart';
import '../services/service_locator.dart';
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
  late final StorageService _storage;
  late final AudioManager _audioManager;
  int _currentCoins = 0;

  @override
  void initState() {
    super.initState();
    _storage = getIt<StorageService>();
    _audioManager = getIt<AudioManager>();
    _loadCoins();
  }

  void _loadCoins() {
    final coins = widget.coins ?? _storage.getInt('user_coins', 0);
    if (mounted) {
      setState(() => _currentCoins = coins);
    }
  }

  @override
  void didUpdateWidget(CoinWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.coins != oldWidget.coins) {
      _loadCoins();
    }
  }

  void _handleAddPressed() {
    _audioManager.playButtonClick();
    widget.onAddPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final d = Dimensions(context);
    final displayCoins = _currentCoins.clamp(0, widget.maxCoins);

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
          Text('🪙', style: TextStyle(fontSize: d.iconSmall)),
          SizedBox(width: d.spaceSmall),
          MyText(
            displayCoins.toString(),
            fontSize: d.bodySmall,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          if (widget.showAddButton) ...[
            SizedBox(width: d.spaceMedium),
            GestureDetector(
              onTap: _handleAddPressed,
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
        ],
      ),
    );
  }
}