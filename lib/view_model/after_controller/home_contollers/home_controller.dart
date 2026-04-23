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

  var searchQuery = "".obs;

  final RxInt selectedTabIndex = 0.obs;
  final RxString selectedCategory = "".obs;

  final List<String> tabs = [
    "Home",
    "Cricket",
    "Football",
    "Tennis",
    "Sports",
    "Basketball",
    "Hockey",
    "Badminton",
  ];

  @override
  void onInit() {
    super.onInit();
    isLogin.value = HiveService.isLogin();
    fetchMatches();
    fetchChannels();
    
    // Setup search listeners
    searchQuery.listen((query) {
      filterData(query);
    });
  }

  void filterData(String query) {
    if (query.isEmpty) {
      filteredMatches.value = allMatches;
      filteredLiveMatches.value = liveMatches;
      filteredChannels.value = allChannels;
    } else {
      final q = query.toLowerCase();
      
      filteredMatches.value = allMatches.where((m) {
        return (m.title?.toLowerCase().contains(q) ?? false) ||
               (m.teamA?.toLowerCase().contains(q) ?? false) ||
               (m.teamB?.toLowerCase().contains(q) ?? false) ||
               (m.sport?.toLowerCase().contains(q) ?? false);
      }).toList();

      filteredLiveMatches.value = liveMatches.where((m) {
        return (m.title?.toLowerCase().contains(q) ?? false) ||
               (m.teamA?.toLowerCase().contains(q) ?? false) ||
               (m.teamB?.toLowerCase().contains(q) ?? false) ||
               (m.sport?.toLowerCase().contains(q) ?? false);
      }).toList();

      filteredChannels.value = allChannels.where((c) {
        return (c.name?.toLowerCase().contains(q) ?? false);
      }).toList();
    }
  }

  Future<void> fetchChannels() async {
    isChannelLoading.value = true;
    try {
      final res = await _channelRepository.getLiveChannels();
      if (res['success'] == true) {
        final data = ChannelModel.fromJson(res);
        allChannels.value = data.channels ?? [];
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
        scheduledMatches.value = data.matches ?? [];
      }
    } catch (e) {
      print("Error fetching scheduled matches: $e");
    } finally {
      isScheduleLoading.value = false;
    }
  }

  void changeTab(int index) {
    selectedTabIndex.value = index;
    selectedCategory.value = ""; // Reset sub-category when switching top tabs
    fetchMatches(sport: tabs[index]);
  }

  void selectSubCategory(String sport) {
    if (selectedCategory.value == sport) {
      selectedCategory.value = ""; // Toggle off
      fetchMatches(sport: "Home");
    } else {
      selectedCategory.value = sport;
      fetchMatches(sport: sport);
    }
  }

  Future<void> fetchMatches({String? sport}) async {
    isLoading.value = true;
    try {
      // Determine what to fetch
      String? sportToFetch = sport;
      if (selectedTabIndex.value == 0 && selectedCategory.value.isNotEmpty) {
        sportToFetch = selectedCategory.value;
      }

      // Fetch Live Matches
      final liveRes = await _matchRepository.getLiveMatches();
      if (liveRes['success'] == true) {
        final data = MatchModel.fromJson(liveRes);
        liveMatches.value = data.matches ?? [];
      }

      // Fetch All Matches with sport filter
      final allRes = await _matchRepository.getAllMatches(sport: sportToFetch);
      if (allRes['success'] == true) {
        final data = MatchModel.fromJson(allRes);
        allMatches.value = data.matches ?? [];
      }
      
      filterData(searchQuery.value); // Re-apply filter
    } catch (e) {
      print("Error fetching matches: $e");
    } finally {
      isLoading.value = false;
    }
  }

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
