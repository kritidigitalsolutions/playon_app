import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/view_model/after_controller/ad_controller.dart';

import 'package:play_on_app/routes/app_routes.dart';

class AdNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    // Auto-ads on navigation disabled to only show on video content pages
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    // Auto-ads on navigation disabled to only show on video content pages
  }
}
