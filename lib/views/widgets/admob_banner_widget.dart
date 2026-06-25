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
    
    String? adUnitId = placement?.adUnitId;
    
    // Fallback logic: Use the provided production banner ID if specific position ID is missing in DB
    if (adUnitId == null || adUnitId.isEmpty) {
      adUnitId = 'ca-app-pub-9899829518030319/6313252740';
      debugPrint('AdMob: Using default production ID for ${widget.position}');
    } else {
      debugPrint('AdMob: Loading Ad from DB for ${widget.position}');
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
