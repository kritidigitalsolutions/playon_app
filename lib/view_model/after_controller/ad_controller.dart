import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:play_on_app/model/response_model/ad_placement_model.dart';
import 'package:play_on_app/repo/ad_repository.dart';
import 'package:play_on_app/view_model/after_controller/plan_controller.dart';

class AdController extends GetxController {
  final AdRepository _repository = AdRepository();
  var adPlacements = <AdPlacement>[].obs;
  var isLoading = false.obs;
  var isMobileAdsInitialized = false.obs;

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  final int maxFailedLoadAttempts = 3;

  @override
  void onInit() {
    debugPrint("📢 [CTRL] AdController onInit START");
    super.onInit();
    fetchAdPlacements();
    
    // Load ad only after Mobile Ads SDK is initialized
    ever(isMobileAdsInitialized, (initialized) {
      if (initialized && _interstitialAd == null) {
        _createInterstitialAd();
      }
    });
    
    // Also try immediately in case it was already initialized
    if (isMobileAdsInitialized.value) {
      _createInterstitialAd();
    }

    debugPrint("📢 [CTRL] AdController onInit END");
  }

  @override
  void onClose() {
    _interstitialAd?.dispose();
    super.onClose();
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: 'ca-app-pub-9899829518030319/6847605214',
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            debugPrint('📢 [AD] InterstitialAd loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('📢 [AD] InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts <= maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  Future<void> showInterstitialAd() async {
    // 1. Check if user is ad-free
    if (Get.isRegistered<PlanController>() && Get.find<PlanController>().isAdFree.value) {
      debugPrint("📢 [AD] Skipping ad: User is Ad-Free");
      return;
    }

    // 2. Show ad if available
    if (_interstitialAd == null) {
      debugPrint('📢 [AD] Warning: attempt to show interstitial before loaded.');
      // Force a reload so it's ready for the next attempt
      _createInterstitialAd();
      return Future.value();
    }

    final Completer<void> completer = Completer<void>();

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        debugPrint('📢 [AD] ad onAdShowedFullScreenContent.');
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        debugPrint('📢 [AD] $ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
        if (!completer.isCompleted) completer.complete();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        debugPrint('📢 [AD] $ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
        if (!completer.isCompleted) completer.complete();
      },
    );

    _interstitialAd!.show();
    // Set to null so it can't be shown twice before next one loads
    _interstitialAd = null;

    return completer.future;
  }

  Future<void> fetchAdPlacements() async {
    isLoading.value = true;
    try {
      final response = await _repository.getAdPlacements();
      final data = AdPlacementModel.fromJson(response);
      if (data.success == true && data.placements != null) {
        adPlacements.assignAll(data.placements!.where((p) => p.isActive == true).toList());
      }
    } catch (e) {
      print("Error fetching ad placements: $e");
    } finally {
      isLoading.value = false;
    }
  }

  AdPlacement? getAdPlacementByPosition(String position) {
    try {
      return adPlacements.firstWhere((p) => p.position == position);
    } catch (e) {
      return null;
    }
  }
}
