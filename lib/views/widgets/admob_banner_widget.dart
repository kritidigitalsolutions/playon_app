import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:play_on_app/view_model/after_controller/ad_controller.dart';
import 'package:play_on_app/view_model/after_controller/plan_controller.dart';

class AdMobBannerWidget extends StatefulWidget {
  final String position;
  const AdMobBannerWidget({super.key, required this.position});

  @override
  State<AdMobBannerWidget> createState() => _AdMobBannerWidgetState();
}

class _AdMobBannerWidgetState extends State<AdMobBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  final AdController adController = Get.find<AdController>();
  final PlanController planController = Get.find<PlanController>();
  Worker? _adWorker;

  @override
  void initState() {
    super.initState();
    // Listen for mobile ads initialization
    _adWorker = ever(adController.isMobileAdsInitialized, (isInitialized) {
      if (isInitialized && !_isLoaded && _bannerAd == null) {
        _loadAd();
      }
    });

    // Also listen for ad placements if they come after initialization
    ever(adController.adPlacements, (_) {
      if (adController.isMobileAdsInitialized.value && !_isLoaded && _bannerAd == null) {
        _loadAd();
      }
    });
    
    // Initial attempt only if already initialized
    if (adController.isMobileAdsInitialized.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadAd();
      });
    }
  }

  void _loadAd() {
    // If not initialized yet, worker will catch it later
    if (!adController.isMobileAdsInitialized.value) {
      return;
    }

    // If user has ad-free plan, don't even try to load
    if (planController.isAdFree.value) {
      return;
    }

    final placement = adController.getAdPlacementByPosition(widget.position);
    
    // If we have placements but none for this position yet, wait for the worker
    if (adController.adPlacements.isNotEmpty && placement == null) {
      debugPrint('AdMob: No placement found for ${widget.position} in database.');
      // return; // Optional: don't show test ad if position missing in DB
    }

    String? adUnitId = placement?.adUnitId;
    
    // Always use the production ID as fallback if dynamic placement is missing
    if (adUnitId == null || adUnitId.isEmpty) {
      // Use Test IDs on Simulator/Fallback to prevent native crashes
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        adUnitId = 'ca-app-pub-3940256099942544/2934735716';
      } else {
        adUnitId = 'ca-app-pub-3940256099942544/6300978111';
      }
      debugPrint('AdMob: Using Test ID for ${widget.position}...');
    } else {
      debugPrint('AdMob: Loading Ad for ${widget.position}');
    }

    _bannerAd?.dispose();
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          ad.dispose();
          _bannerAd = null;
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _adWorker?.dispose();
    _bannerAd?.dispose();
    _bannerAd = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (planController.isAdFree.value) {
        return const SizedBox.shrink();
      }
      if (_isLoaded && _bannerAd != null) {
        return Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(vertical: 10),
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        );
      }
      return const SizedBox.shrink();
    });
  }
}
