import 'package:flutter/cupertino.dart';
import 'package:snake_rush/screens/shop/coin_shop_screen.dart';
import '../const_widgets/my_text.dart';
import '../navigator/morph_navigator.dart';
import '../services/audio/audio_manager.dart';
import '../services/service_locator.dart';
import '../services/storage/storage_service.dart';
import '../ui/colors.dart';
import '../ui/dimensions.dart';

class CoinWidget extends StatefulWidget {
  // ✅ sourceKey endi tashqaridan so'ralmaydi
  const CoinWidget({super.key});

  @override
  State<CoinWidget> createState() => _CoinWidgetState();
}

class _CoinWidgetState extends State<CoinWidget> {
  late final StorageService _storage;
  late final AudioManager _audioManager;

  // ✅ Har bir widget o'zi uchun GlobalKey yaratadi
  final GlobalKey _myInternalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _storage = getIt<StorageService>();
    _audioManager = getIt<AudioManager>();
    // Loop (timer) endi shart emas! ValueNotifier hamma ishni qiladi.
  }

  void _handleAddPressed() {
    _audioManager.playButtonClick();

    // ✅ O'zidagi _myInternalKey'dan foydalanib Morph navigatsiyani ochadi
    MorphNavigator.open(
      context: context,
      sourceKey: _myInternalKey,
      child: const CoinShopScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = Dimensions(context);

    // ✅ ValueListenableBuilder har qanday coin o'zgarishini "jonli" ko'rsatadi
    return ValueListenableBuilder<int>(
      valueListenable: _storage.coinsNotifier,
      builder: (context, currentCoins, child) {
        return Container(
          key: _myInternalKey, // 🚀 MORPH NAVIGATOR UCHUN KEY SHU YERDA!
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
              Text('💰', style: TextStyle(fontSize: d.iconSmall)),
              SizedBox(width: d.spaceSmall),
              MyText(
                currentCoins.toString(), // 0 dan ko'rsatiladi
                fontSize: d.bodySmall,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
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
          ),
        );
      },
    );
  }
}