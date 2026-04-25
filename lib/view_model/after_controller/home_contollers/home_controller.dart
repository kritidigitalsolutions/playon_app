import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/routes/app_routes.dart';
import 'package:play_on_app/utils/app_text_style.dart';

import 'package:play_on_app/model/response_model/channel_model.dart';
import 'package:play_on_app/repo/channel_repository.dart';
import 'package:play_on_app/model/response_model/match_model.dart';
import 'package:play_on_app/repo/match_repository.dart';
import 'package:play_on_app/utils/hive_service/hive_service.dart';
import 'package:play_on_app/model/response_model/banner_model.dart';

class HomeController extends GetxController {
  final MatchRepository _matchRepository = MatchRepository();
  final ChannelRepository _channelRepository = ChannelRepository();
  
  final RxInt currentIndex = 0.obs;
  void changeIndex(int index) {
    currentIndex.value = index;
  }

  var isLoading = false.obs;
  var liveMatches = <Match>[].obs;
  var allMatches = <Match>[].obs;
  var filteredMatches = <Match>[].obs;
  var filteredLiveMatches = <Match>[].obs;
  var scheduledMatches = <Match>[].obs;
  var isScheduleLoading = false.obs;

  var isChannelLoading = false.obs;
  var allChannels = <Channel>[].obs;
  var filteredChannels = <Channel>[].obs;

  var bannerList = <Banners>[].obs;
  var isBannerLoading = false.obs;

  var searchQuery = "".obs;

  final RxInt selectedTabIndex = 0.obs;
  final RxString selectedCategory = "".obs;

  var sportsList = <String>["Home"].obs;

  @override
  void onInit() {
    super.onInit();
    isLogin.value = HiveService.isLogin();
    fetchSports();
    fetchMatches();
    fetchChannels();
    fetchBanners();
    
    // Setup search listeners
    searchQuery.listen((query) {
      filterData(query);
    });
  }

  Future<void> fetchBanners() async {
    isBannerLoading.value = true;
    try {
      final res = await _matchRepository.getBannerAds();
      if (res['success'] == true) {
        final data = BannerModel.fromJson(res);
        bannerList.assignAll(data.banners ?? []);
      }
    } catch (e) {
      print("Error fetching banners: $e");
    } finally {
      isBannerLoading.value = false;
    }
  }

  Future<void> fetchSports() async {
    try {
      final res = await _matchRepository.getSports();
      if (res['success'] == true && res['sports'] != null) {
        List<String> s = ["Home"];
        for (var item in res['sports']) {
          if (item['name'] != null) {
            s.add(item['name']);
          }
        }
        sportsList.assignAll(s);
      }
    } catch (e) {
      print("Error fetching sports: $e");
    }
  }

  void filterData(String query) {
    if (query.isEmpty) {
      filteredMatches.assignAll(allMatches);
      filteredLiveMatches.assignAll(liveMatches);
      filteredChannels.assignAll(allChannels);
    } else {
      final q = query.toLowerCase();
      
      filteredMatches.assignAll(allMatches.where((m) {
        return (m.title?.toLowerCase().contains(q) ?? false) ||
               (m.teamA?.toLowerCase().contains(q) ?? false) ||
               (m.teamB?.toLowerCase().contains(q) ?? false) ||
               (m.sport?.toLowerCase().contains(q) ?? false);
      }).toList());

      filteredLiveMatches.assignAll(liveMatches.where((m) {
        return (m.title?.toLowerCase().contains(q) ?? false) ||
               (m.teamA?.toLowerCase().contains(q) ?? false) ||
               (m.teamB?.toLowerCase().contains(q) ?? false) ||
               (m.sport?.toLowerCase().contains(q) ?? false);
      }).toList());

      filteredChannels.assignAll(allChannels.where((c) {
        return (c.name?.toLowerCase().contains(q) ?? false);
      }).toList());
    }
  }

  Future<void> fetchChannels() async {
    isChannelLoading.value = true;
    try {
      final res = await _channelRepository.getLiveChannels();
      if (res['success'] == true) {
        final data = ChannelModel.fromJson(res);
        allChannels.assignAll(data.channels ?? []);
        filterData(searchQuery.value); // Re-apply filter
      }
    } catch (e) {
      print("Error fetching channels: $e");
    } finally {
      isChannelLoading.value = false;
    }
  }

  Future<void> fetchScheduledMatches({String? sport, String? date}) async {
    isScheduleLoading.value = true;
    try {
      final res = await _matchRepository.getAllMatches(sport: sport, date: date);
      if (res['success'] == true) {
        final data = MatchModel.fromJson(res);
        scheduledMatches.assignAll(data.matches ?? []);
      }
    } catch (e) {
      print("Error fetching scheduled matches: $e");
    } finally {
      isScheduleLoading.value = false;
    }
  }

  void changeTab(int index) {
    selectedTabIndex.value = index;
    selectedCategory.value = ""; // Reset middle chip when switching top tabs
    // We fetch everything to keep the dashboard context available
    fetchMatches();
  }

  void selectSubCategory(String sport) {
    if (selectedCategory.value == sport) {
      selectedCategory.value = ""; // Toggle off
    } else {
      selectedCategory.value = sport;
    }
    // No need to fetch, we filter the already loaded allMatches
  }

  Future<void> fetchMatches({String? sport}) async {
    // If we already have data, don't show full screen loading, 
    // just use the linear indicator.
    if (allMatches.isEmpty) {
      isLoading.value = true;
    }
    
    // Separate observable for the linear progress bar
    isSilentLoading.value = true;
    
    try {
      // Fetch Live Matches
      final liveRes = await _matchRepository.getLiveMatches();
      if (liveRes['success'] == true) {
        final data = MatchModel.fromJson(liveRes);
        liveMatches.assignAll(data.matches ?? []);
      }

      // Always fetch all matches for the dashboard
      final allRes = await _matchRepository.getAllMatches();
      if (allRes['success'] == true) {
        final data = MatchModel.fromJson(allRes);
        allMatches.assignAll(data.matches ?? []);
      }
      
      filterData(searchQuery.value);
    } catch (e) {
      print("Error fetching matches: $e");
    } finally {
      isLoading.value = false;
      isSilentLoading.value = false;
    }
  }

  var isSilentLoading = false.obs;

  var isLogin = false.obs;

  void toggleLogin() {
    isLogin.value = !isLogin.value;
  }

  void handleProtectedAction(VoidCallback onSuccess) {
    if (isLogin.value) {
      onSuccess();
    } else {
      _showLoginBottomSheet();
    }
  }

  void _showLoginBottomSheet() {
    Get.bottomSheet(
      Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.7),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "You're not logged in",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Please login to continue",
              style: TextStyle(color: AppColors.white70, fontSize: 15),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.toNamed(AppRoutes.login);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Login",
                  style: text16(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Get.back(),
              child: Text("Cancel", style: text15()),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.7),
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }
}
