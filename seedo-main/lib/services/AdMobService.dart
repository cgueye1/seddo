// ignore_for_file: unused_field

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  BannerAd? _bannerAd;
  VoidCallback? _currentRewardCallback;

  Future<void> initialize() async {
    try {
      final initFuture = MobileAds.instance.initialize();
      // Add timeout to prevent hanging
      await initFuture.timeout(const Duration(seconds: 10));
      debugPrint('AdService initialized successfully');
      await _loadAds();
    } on TimeoutException {
      debugPrint('Ad initialization timed out');
    } on Exception catch (e) {
      debugPrint('Ad initialization failed: $e');
      // Consider retrying after delay
      await Future.delayed(const Duration(seconds: 5));
      await initialize(); // Retry once
    }
  }

  Future<void> _loadAds() async {
    await _loadInterstitialAd();
     await _loadRewardedAd();
  }

  Future<void> _loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: _getInterstitialAdUnitId()!,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialAd
              ?.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _loadInterstitialAd();
            },
          );
          debugPrint('$ad loaded.');
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

   Future<void> _loadRewardedAd() async {
    await RewardedAd.load(
      adUnitId: _getRewardBasedVideoAdUnitId()!,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _loadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _loadRewardedAd();
            },
          );
          debugPrint('$ad loaded.');
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('RewardedAd failed to load: $error');
        },
      ),
    );
  }

  Widget getBannerAd({AdSize? size}) {
    if (_bannerAd != null) {
      return SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    return Container();
  }

  Future<void> loadBannerAd(AdSize size) async {
    await _bannerAd?.dispose();
    _bannerAd = BannerAd(
      adUnitId: _getBannerAdUnitId()!,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (ad) => debugPrint('BannerAd loaded.'),
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    );
    await _bannerAd?.load();
  }

  Future<bool> showInterstitialAd() async {
    if (_interstitialAd != null) {
      print("oklm");
      _interstitialAd?.show();
      return true;
    }
    debugPrint('InterstitialAd not ready');
    return false;
  }

   Future<bool> showRewardedAd({required VoidCallback onRewarded}) async {
    if (_rewardedAd != null) {
      _currentRewardCallback = onRewarded;
      _rewardedAd?.show(
        onUserEarnedReward: (ad, reward) {
          _currentRewardCallback?.call();
          _currentRewardCallback = null;
        },
      );
      return true;
    }
    debugPrint('RewardedAd not ready');
    return false;
  }




    // IDs des pubs
  String? _getBannerAdUnitId() {
    if (Platform.isIOS) return 'ca-app-pub-7248255245937838/1687789051';
    if (Platform.isAndroid) return 'ca-app-pub-7248255245937838/4890716632';
    return null;
  }

  String? _getInterstitialAdUnitId() {
    if (Platform.isIOS) return 'ca-app-pub-7248255245937838/1249779129';
    if (Platform.isAndroid) return 'ca-app-pub-7248255245937838/6892014276';
    return null;
  }
  String? _getRewardBasedVideoAdUnitId() {
    if (Platform.isIOS) return 'ca-app-pub-7248255245937838/1021949347';
    if (Platform.isAndroid) return 'ca-app-pub-7248255245937838/7180163580';
    return null;
  }



  void dispose() {
    _interstitialAd?.dispose();
     _rewardedAd?.dispose();

    _currentRewardCallback = null;
  }

  bannerDispos() {
    _bannerAd?.dispose();
  }
}
