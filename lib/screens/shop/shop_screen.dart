import 'package:flutter/cupertino.dart';
import '../../models/coin/coin_package.dart';
import '../../utils/const_widgets/my_text.dart';
import '../../utils/widgets/my_button.dart';
import '../../utils/services/language/language_service.dart';
import '../../utils/services/storage/storage_service.dart';
import '../../utils/services/ad/ad_service.dart';
import '../../utils/ui/colors.dart';
import '../../utils/ui/dimensions.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final _languageService = LanguageService();
  final _storage = StorageService();
  final _adService = AdService();

  int _currentCoins = 0;
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    _languageService.addListener(_onLanguageChanged);
    _loadCoins();
  }

  @override
  void dispose() {
    _languageService.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadCoins() async {
    final coins = _storage.getInt('user_coins', 0);
    setState(() => _currentCoins = coins);
  }

  Future<void> _addCoins(int amount) async {
    final newTotal = _currentCoins + amount;
    await _storage.setInt('user_coins', newTotal);
    setState(() => _currentCoins = newTotal);
  }

  Future<void> _watchAdForCoins() async {
    final success = await _adService.showRewardedAd(
      onRewarded: (coins) async {
        await _addCoins(coins);
        if (mounted) {
          _showSuccessAdDialog(coins);
        }
      },
      onAdFailedToShow: () {
        if (mounted) {
          _showAdNotReadyDialog();
        }
      },
    );

    if (!success && mounted) {
      _showAdNotReadyDialog();
    }
  }

  Future<void> _purchaseCoinPackage(CoinPackage package) async {
    if (_isPurchasing) return;

    setState(() => _isPurchasing = true);

    try {
      await Future.delayed(const Duration(seconds: 1));
      await _addCoins(package.coins);

      if (mounted) {
        _showSuccessDialog(package);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog();
      }
    } finally {
      if (mounted) {
        setState(() => _isPurchasing = false);
      }
    }
  }

  void _showSuccessDialog(CoinPackage package) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const MyText('🎉', fontSize: 32),
        content: MyText(
          '${_tr('purchase_success')}\n${package.coins} ${_tr('coins')}!',
          fontSize: 16,
          textAlign: TextAlign.center,
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const MyText('OK', fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _showSuccessAdDialog(int coins) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const MyText('🎁', fontSize: 32),
        content: MyText(
          '${_tr('ad_reward_success')}\n+$coins ${_tr('coins')}!',
          fontSize: 16,
          textAlign: TextAlign.center,
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const MyText('OK', fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _showAdNotReadyDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const MyText('❌', fontSize: 32),
        content: MyText(
          _tr('ad_not_ready'),
          fontSize: 16,
          textAlign: TextAlign.center,
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const MyText('OK', fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const MyText('❌', fontSize: 32),
        content: MyText(
          _tr('purchase_failed'),
          fontSize: 16,
          textAlign: TextAlign.center,
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const MyText('OK', fontSize: 16),
          ),
        ],
      ),
    );
  }

  String _tr(String key) => _languageService.translate(key);

  @override
  Widget build(BuildContext context) {
    final d = Dimensions(context);
    final navBarHeight =
        CupertinoNavigationBar().preferredSize.height +
            MediaQuery.of(context).padding.top;

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.transparent,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.transparent,
        border: null,
        leading: MyButton(
          type: ButtonType.icon,
          icon: CupertinoIcons.back,
          onPressed: () => Navigator.of(context).pop(),
        ),
        middle: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🪙', style: TextStyle(fontSize: d.iconMedium)),
            SizedBox(width: d.spaceSmall),
            MyText(
              _tr('shop'),
              fontSize: d.title,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(
                horizontal: d.paddingScreen,
                vertical: d.spaceLarge,
              ),
              physics: const BouncingScrollPhysics(),
              itemCount: CoinPackage.packages.length + 2,
              separatorBuilder: (_, _) => SizedBox(height: d.spaceMedium),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return SizedBox(height: navBarHeight);
                } else if (index == 1) {
                  return _buildAdRewardCard(d);
                } else {
                  final package = CoinPackage.packages[index - 2];
                  return _buildCoinPackage(d, package);
                }
              },
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildAdRewardCard(Dimensions d) {
    final isAdReady = _adService.isAdReady;
    final isLoading = _adService.isLoading;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF00B4DB),
            Color(0xFF0083B0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(d.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00B4DB).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(d.paddingCard),
      child: Row(
        children: [
          Container(
            width: d.iconHuge,
            height: d.iconHuge,
            decoration: BoxDecoration(
              color: CupertinoColors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('📺', style: TextStyle(fontSize: d.iconMedium)),
            ),
          ),
          SizedBox(width: d.spaceMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                MyText(
                  _tr('watch_ad'),
                  fontSize: d.subtitle,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.white,
                ),
                SizedBox(height: d.spaceTiny),
                MyText(
                  _tr('get_50_coins'),
                  fontSize: d.body,
                  color: CupertinoColors.white.withOpacity(0.9),
                ),
              ],
            ),
          ),
          SizedBox(width: d.spaceSmall),
          MyButton(
            type: ButtonType.secondary,
            width: d.buttonWidth * 0.35,
            height: d.buttonHeightSmall,
            onPressed: (!isAdReady || isLoading) ? null : _watchAdForCoins,
            child: isLoading
                ? const CupertinoActivityIndicator(
              color: CupertinoColors.white,
            )
                : MyText(
              _tr('watch'),
              fontSize: d.body,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinPackage(Dimensions d, CoinPackage package) {
    final isPopular = package.isPopular;
    final isBestValue = package.isBestValue;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: isPopular || isBestValue
                ? LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.2),
                AppColors.secondary.withOpacity(0.2),
              ],
            )
                : null,
            color: isPopular || isBestValue ? null : AppColors.glassLight,
            borderRadius: BorderRadius.circular(d.radiusLarge),
            border: Border.all(
              color: isPopular || isBestValue
                  ? AppColors.primary
                  : AppColors.glassBorder,
              width: isPopular || isBestValue ? d.borderThick : d.borderMedium,
            ),
          ),
          padding: EdgeInsets.all(d.paddingCard),
          child: Row(
            children: [
              Container(
                width: d.iconHuge,
                height: d.iconHuge,
                decoration: BoxDecoration(
                  gradient: AppColors.coinGradient,
                  shape: BoxShape.circle,
                  boxShadow: AppColors.coinShadow,
                ),
                child: Center(
                  child: Text('🪙', style: TextStyle(fontSize: d.iconMedium)),
                ),
              ),
              SizedBox(width: d.spaceMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MyText(
                      '${package.coins} ${_tr('coins')}',
                      fontSize: d.subtitle,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    if (package.bonus > 0) ...[
                      SizedBox(height: d.spaceTiny),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: d.spaceSmall,
                          vertical: d.spaceTiny,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                          ),
                          borderRadius: BorderRadius.circular(d.radiusSmall),
                        ),
                        child: MyText(
                          '+${package.bonus}% ${_tr('bonus')}',
                          fontSize: d.caption,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: d.spaceSmall),
              MyButton(
                type: ButtonType.primary,
                width: d.buttonWidth * 0.4,
                height: d.buttonHeightSmall,
                onPressed: _isPurchasing
                    ? null
                    : () => _purchaseCoinPackage(package),
                child: _isPurchasing
                    ? const CupertinoActivityIndicator(
                  color: CupertinoColors.white,
                )
                    : MyText(
                  package.price,
                  fontSize: d.body,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        if (isPopular)
          Positioned(
            top: -8,
            right: 20,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: d.spaceMedium,
                vertical: d.spaceTiny,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
                ),
                borderRadius: BorderRadius.circular(d.radiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B6B).withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 12)),
                  SizedBox(width: d.spaceTiny),
                  MyText(
                    _tr('popular'),
                    fontSize: d.caption,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.white,
                  ),
                ],
              ),
            ),
          ),
        if (isBestValue)
          Positioned(
            top: -8,
            right: 20,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: d.spaceMedium,
                vertical: d.spaceTiny,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                borderRadius: BorderRadius.circular(d.radiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('💎', style: TextStyle(fontSize: 12)),
                  SizedBox(width: d.spaceTiny),
                  MyText(
                    _tr('best_value'),
                    fontSize: d.caption,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.white,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}