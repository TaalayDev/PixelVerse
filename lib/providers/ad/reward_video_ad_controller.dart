import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../subscription_provider.dart';

class RewardVideoAdController extends StateNotifier<bool> {
  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;
  bool _isAdLoading = false;
  final Ref _ref;

  RewardVideoAdController(this._ref) : super(false) {
    loadAd();
  }

  void loadAd() {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      return;
    }

    if (_isAdLoading) return;

    _isAdLoading = true;

    RewardedAd.load(
      adUnitId: _getAdUnitId(),
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isAdLoaded = true;
          _isAdLoading = false;
          state = true;
          debugPrint('Reward video ad loaded successfully');
        },
        onAdFailedToLoad: (error) {
          debugPrint('Reward video ad failed to load: ${error.message}');
          _isAdLoaded = false;
          _isAdLoading = false;
          state = false;

          // Retry loading after a delay if it fails
          Future.delayed(const Duration(seconds: 30), () {
            loadAd();
          });
        },
      ),
    );
  }

  String _getAdUnitId() {
    final adId = Platform.isAndroid ? dotenv.env['ANDROID_REWARDED_ID'] : dotenv.env['IOS_REWARDED_ID'];

    if (kDebugMode || adId == null || adId.isEmpty) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/5224354917'; // Android test rewarded ad unit
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/1712485313'; // iOS test rewarded ad unit
      }
    }

    return adId!;
  }

  Future<bool> showAdIfLoaded() async {
    if (_isAdLoaded && _rewardedAd != null) {
      final completer = Completer<bool>();
      bool rewardEarned = false;

      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isAdLoaded = false;
          state = false;
          loadAd(); // Load the next ad
          debugPrint('Reward video ad dismissed');
          completer.complete(rewardEarned);
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('Failed to show reward video ad: ${error.message}');
          ad.dispose();
          _isAdLoaded = false;
          state = false;
          loadAd(); // Load the next ad
          completer.complete(false);
        },
        onAdShowedFullScreenContent: (ad) {
          debugPrint('Reward video ad showed full screen content');
        },
        onAdImpression: (ad) {
          debugPrint('Reward video ad impression recorded');
        },
      );

      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          debugPrint('User earned reward: ${reward.amount} ${reward.type}');
          rewardEarned = true;

          _ref.read(subscriptionStateProvider.notifier).grantTemporaryProAccess();
        },
      );

      return completer.future;
    } else {
      // If ad is not loaded, try to load one
      loadAd();
      return false;
    }
  }

  bool get isAdReady => _isAdLoaded && _rewardedAd != null;

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }
}

final rewardVideoAdProvider = StateNotifierProvider<RewardVideoAdController, bool>((ref) {
  return RewardVideoAdController(ref);
});
