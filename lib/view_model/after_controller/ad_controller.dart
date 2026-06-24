import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:play_on_app/model/response_model/ad_placement_model.dart';
import 'package:play_on_app/repo/ad_repository.dart';

class AdController extends GetxController {
  final AdRepository _repository = AdRepository();
  var adPlacements = <AdPlacement>[].obs;
  var isLoading = false.obs;
  var isMobileAdsInitialized = false.obs;

  @override
  void onInit() {
    debugPrint("📢 [CTRL] AdController onInit START");
    super.onInit();
    fetchAdPlacements();
    debugPrint("📢 [CTRL] AdController onInit END");
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
