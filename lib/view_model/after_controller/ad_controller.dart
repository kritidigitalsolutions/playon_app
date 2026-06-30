import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:play_on_app/model/response_model/ad_placement_model.dart';
import 'package:play_on_app/repo/ad_repository.dart';
import 'package:play_on_app/view_model/after_controller/plan_controller.dart';

import 'home_contollers/podcast_play_controller.dart';
import 'match_controller/match_controller.dart';

class AdController extends GetxController {
  final AdRepository _repository = AdRepository();
  var adPlacements = <AdPlacement>[].obs;
  var isLoading = false.obs;
  var isMobileAdsInitialized = false.obs;

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  final int maxFailedLoadAttempts = 3;
  bool _isAdLoading = false;
  
  // Track if an ad is currently being displayed
  Completer<void>? _currentAdCompleter;
  bool _isAdShowingNow = false;
  bool get isAdShowing => _currentAdCompleter != null || _isAdShowingNow;

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
    if (_isAdLoading) return;
    _isAdLoading = true;
    
    InterstitialAd.load(
        adUnitId: 'ca-app-pub-9899829518030319/6847605214',
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            debugPrint('📢 [AD] InterstitialAd loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _isAdLoading = false;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('📢 [AD] InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            _isAdLoading = false;
            if (_numInterstitialLoadAttempts <= maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  void _pauseAllPlayback() {
    try {
      if (Get.isRegistered<VideoControllerX>()) {
        final v = Get.find<VideoControllerX>();
        v.videoController?.pause();
        v.youtubeController?.pause();
        v.isPlaying.value = false;
      }
      if (Get.isRegistered<PodcastPlayController>()) {
        final v = Get.find<PodcastPlayController>();
        v.videoController?.pause();
        v.youtubeController?.pause();
        v.isPlaying.value = false;
      }
    } catch (e) {
      debugPrint("Error pausing playback: $e");
    }
  }

  Future<void> showInterstitialAd() async {
    // 1. Check if user is ad-free
    if (Get.isRegistered<PlanController>() && Get.find<PlanController>().isAdFree.value) {
      debugPrint("📢 [AD] Skipping ad: User is Ad-Free");
      return;
    }

    // 2. If an ad is already showing or starting, wait for it to finish
    if (isAdShowing) {
      debugPrint("📢 [AD] Ad already showing, waiting for it to finish...");
      if (_currentAdCompleter != null) {
        try {
          await _currentAdCompleter!.future;
        } catch (e) {
          debugPrint("📢 [AD] Error waiting for ad: $e");
        }
      }
      await Future.delayed(const Duration(milliseconds: 800));
      return;
    }

    // 3. If no ad but one is loading, wait a short moment
    if (_interstitialAd == null && _isAdLoading) {
      debugPrint("📢 [AD] Ad is loading, waiting briefly...");
      int attempts = 0;
      while (_interstitialAd == null && attempts < 30 && _isAdLoading) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }
    }

    // 4. Re-check if an ad was started by another call while we were waiting
    if (isAdShowing) {
      debugPrint("📢 [AD] Ad started showing while we were waiting for load. Waiting for it to finish...");
      if (_currentAdCompleter != null) {
        try {
          await _currentAdCompleter!.future;
        } catch (e) {
          debugPrint("📢 [AD] Error waiting for ad: $e");
        }
      }
      await Future.delayed(const Duration(milliseconds: 800));
      return;
    }

    // 5. Show ad if available
    if (_interstitialAd == null) {
      debugPrint('📢 [AD] Warning: no interstitial ready after waiting.');
      _createInterstitialAd();
      return;
    }

    _currentAdCompleter = Completer<void>();
    _isAdShowingNow = true;
    _pauseAllPlayback();

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        debugPrint('📢 [AD] ad onAdShowedFullScreenContent.');
        _isAdShowingNow = true;
        _pauseAllPlayback(); 
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        debugPrint('📢 [AD] $ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
        
        _isAdShowingNow = false;
        
        // Ensure playback stays paused until ad is fully gone
        _pauseAllPlayback();
        
        // Delay completion to ensure UI transition is clean and video doesn't start too early
        Future.delayed(const Duration(milliseconds: 1000), () {
          final comp = _currentAdCompleter;
          _currentAdCompleter = null;
          if (comp != null && !comp.isCompleted) comp.complete();
        });
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        debugPrint('📢 [AD] $ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
        
        _isAdShowingNow = false;
        final comp = _currentAdCompleter;
        _currentAdCompleter = null;
        if (comp != null && !comp.isCompleted) comp.complete();
      },
    );

    await _interstitialAd!.show();
    _interstitialAd = null;

    return _currentAdCompleter!.future;
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
