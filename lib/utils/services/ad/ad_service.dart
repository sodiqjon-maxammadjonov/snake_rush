import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  RewardedAd? _rewardedAd;
  bool _isLoadingAd = false;

  static const String _androidRewardedAdId = 'ca-app-pub-3940256099942544/5224354917';
  // static const String _androidRewardedAdId = 'ca-app-pub-2110406871216164/2968244345';
  static const String _iosRewardedAdId = 'ca-app-pub-3940256099942544/1712485313';
  // static const String _iosRewardedAdId = 'ca-app-pub-2110406871216164/9342081009';

  bool get isAdReady => _rewardedAd != null;
  bool get isLoading => _isLoadingAd;

  String get _rewardedAdUnitId {
    if (Platform.isAndroid) {
      return _androidRewardedAdId;
    } else if (Platform.isIOS) {
      return _iosRewardedAdId;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  Future<void> init() async {
    await MobileAds.instance.initialize();
    loadRewardedAd();
  }

  void loadRewardedAd() {
    if (_isLoadingAd) return;

    _isLoadingAd = true;

    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _isLoadingAd = false;
          _setupAdCallbacks(ad);
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isLoadingAd = false;
          _rewardedAd = null;
        },
      ),
    );
  }

  void _setupAdCallbacks(RewardedAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) {
        // Ad to'liq ekranga chiqdi
      },
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd(); // Keyingi ad ni yuklaymiz
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd(); // Qayta yuklaymiz
      },
    );
  }

  Future<bool> showRewardedAd({
    required Function(int coins) onRewarded,
    Function? onAdFailedToShow,
  }) async {
    if (_rewardedAd == null) {
      onAdFailedToShow?.call();
      return false;
    }

    await _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
        onRewarded(50); // 50 coins beryapmiz
      },
    );

    return true;
  }

  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}