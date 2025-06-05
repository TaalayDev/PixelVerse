import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class InterstitialAdController extends StateNotifier<bool> {
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  bool _isAdLoading = false;
  final Ref _ref;

  InterstitialAdController(this._ref) : super(false) {
    loadAd();
  }

  void loadAd() {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      return;
    }

    if (_isAdLoading) return;

    _isAdLoading = true;

    InterstitialAd.load(
      adUnitId: _getAdUnitId(),
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
          _isAdLoading = false;
          state = true;
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial ad failed to load: ${error.message}');
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
    final adId = Platform.isAndroid ? dotenv.env['ANDROID_INTERSTITIAL_ID'] : dotenv.env['IOS_INTERSTITIAL_ID'];
    if (kDebugMode || adId == null || adId.isEmpty) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/1033173712'; // Android test ad unit
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/4411468910'; // iOS test ad unit
      }
    }

    return adId!;
  }

  Future<void> showAdIfLoaded(VoidCallback onAdDismissed) async {
    if (_isAdLoaded && _interstitialAd != null) {
      // SoundController().pauseBackgroundMusic();
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isAdLoaded = false;
          state = false;
          loadAd(); // Load the next ad
          onAdDismissed();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('Failed to show interstitial ad: ${error.message}');
          ad.dispose();
          _isAdLoaded = false;
          state = false;
          loadAd(); // Load the next ad
          onAdDismissed();
        },
        onAdShowedFullScreenContent: (ad) {
          debugPrint('Interstitial ad showed full screen content');
        },
        onAdImpression: (ad) {
          debugPrint('Interstitial ad impression recorded');
        },
      );
      await _interstitialAd!.show();
    } else {
      // If ad is not loaded, just continue with the callback
      onAdDismissed();
      // Try to load a new ad for next time
      loadAd();
    }
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }
}

final interstitialAdProvider = StateNotifierProvider<InterstitialAdController, bool>((ref) {
  return InterstitialAdController(ref);
});
