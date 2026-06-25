import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/view_model/after_controller/ad_controller.dart';

class AdNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    
    // Only show ad if we are pushing a new screen (not a dialog or bottom sheet)
    // and it's not the splash screen
    if (route is GetPageRoute && route.settings.name != '/splashScreen') {
      debugPrint("📢 [NAV] Pushing to ${route.settings.name}. Showing Ad first.");
      
      if (Get.isRegistered<AdController>()) {
        Get.find<AdController>().showInterstitialAd();
      }
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    
    // Show ad when returning back as well
    if (previousRoute != null && previousRoute is GetPageRoute) {
      debugPrint("📢 [NAV] Popped back to ${previousRoute.settings.name}. Showing Ad.");
      
      if (Get.isRegistered<AdController>()) {
        Get.find<AdController>().showInterstitialAd();
      }
    }
  }
}
