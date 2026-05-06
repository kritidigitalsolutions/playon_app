import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/routes/app_routes.dart';
import 'package:play_on_app/utils/app_text_style.dart';

import 'package:play_on_app/model/response_model/channel_model.dart';
import 'package:play_on_app/repo/channel_repository.dart';
import 'package:play_on_app/repo/auth_repository.dart';
import 'package:play_on_app/model/response_model/match_model.dart';
import 'package:play_on_app/repo/match_repository.dart';
import 'package:play_on_app/utils/hive_service/hive_service.dart';
import 'package:play_on_app/model/response_model/banner_model.dart';
import 'package:play_on_app/model/response_model/channel_category_model.dart';
import 'package:play_on_app/model/response_model/series_model.dart';
import 'package:play_on_app/model/response_model/player_model.dart';
import 'package:play_on_app/model/response_model/star_player_model.dart';
import 'package:play_on_app/model/response_model/podcast_model.dart';
import 'package:play_on_app/model/response_model/social_media_model.dart';
import 'package:play_on_app/model/response_model/referral_offer_model.dart';
import 'package:play_on_app/model/response_model/score_model.dart';
import 'package:play_on_app/repo/legal_repository.dart';

import '../../../repo/auth_repository.dart';

class HomeController extends GetxController {
  final MatchRepository _matchRepository = MatchRepository();
  final ChannelRepository _channelRepository = ChannelRepository();
  final LegalRepository _legalRepository = LegalRepository();
  
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

  var seriesList = <Series>[].obs;
  var isSeriesLoading = false.obs;

  var starPlayers = <StarPlayer>[].obs;
  var isPlayersLoading = false.obs;

  var podcastList = <Podcast>[].obs;
  var isPodcastLoading = false.obs;

  var channelCategories = <ChannelCategory>[].obs;
  var isCategoryLoading = false.obs;

  var socialMediaList = <SocialMedia>[].obs;
  var isSocialLoading = false.obs;

  var searchQuery = "".obs;

  var liveScores = <String, ScoreData>{}.obs;

  Timer? _scoreTimer;

  final RxInt selectedTabIndex = 0.obs;
  final RxString selectedCategory = "".obs;

  var sportsList = <String>["Home"].obs;

  var isLogin = false.obs;
  var userName = "".obs;
  var referralCode = "".obs;
  final referralOffer = Rxn<ReferralOffer>();
  var isReferralLoading = false.obs;
  var isOfferLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Only consider as logged in if they have a token AND have completed profile
    isLogin.value = HiveService.isLogin() && HiveService.isProfileComplete();

    if (isLogin.value) {
      userName.value = HiveService.getUser()?.name ?? "";
    }
    fetchSports();
    fetchChannelCategories();
    fetchMatches();
    fetchChannels();
    fetchBanners();
    fetchSeries();
    fetchStarPlayers();
    fetchPodcasts();
    fetchSocialMedia();
    fetchReferralCode();
    fetchReferralOffer();
    _startScoreTimer();

    // Setup search listeners
    searchQuery.listen((query) {
      filterData(query);
    });
  }

  final AuthRepository _authRepository = AuthRepository();

  Future<void> fetchReferralCode() async {
    if (!isLogin.value) return;
    try {
      isReferralLoading.value = true;
      final response = await _authRepository.getReferralCode();
      if (response['success'] == true) {
        referralCode.value = response['referralCode'] ?? "";
      }
    } catch (e) {
      debugPrint("Error fetching referral code: $e");
    } finally {
      isReferralLoading.value = false;
    }
  }

  Future<void> fetchReferralOffer() async {
    if (!isLogin.value) return;
    try {
      isOfferLoading.value = true;
      final response = await _authRepository.getReferralOffer();
      if (response['success'] == true) {
        final data = ReferralOfferModel.fromJson(response);
        if (data.offers != null && data.offers!.isNotEmpty) {
          referralOffer.value = data.offers!.first;
        }
      }
    } catch (e) {
      debugPrint("Error fetching referral offer: $e");
    } finally {
      isOfferLoading.value = false;
    }
  }

  Future<void> fetchBanners() async {
    isBannerLoading.value = true;
    try {
      final res = await _matchRepository.getBannerAds();
      print("Banner Response: $res");
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

  Future<void> fetchSeries() async {
    isSeriesLoading.value = true;
    try {
      final res = await _matchRepository.getSeries();
      if (res['success'] == true) {
        final data = SeriesModel.fromJson(res);
        var fetchedSeries = data.series ?? [];
        
        // Filter by isHomeScreen: true
        fetchedSeries = fetchedSeries.where((s) => s.isHomeScreen == true).toList();

        // Fetch full match details for each series
        for (var series in fetchedSeries) {
          if (series.matches != null && series.matches!.isNotEmpty) {
            try {
              final matchFutures = series.matches!
                  .where((m) => m.sId != null)
                  .map((m) => _matchRepository.getMatchDetails(m.sId!))
                  .toList();
              
              final matchResults = await Future.wait(matchFutures);
              List<Match> fullMatches = [];
              for (var matchRes in matchResults) {
                if (matchRes != null && matchRes['success'] == true && matchRes['match'] != null) {
                  final m = Match.fromJson(matchRes['match']);
                  m.isSeriesPremium = series.isPremium; // Propagate series premium status to match
                  fullMatches.add(m);
                }
              }
              series.fullMatches = fullMatches;
            } catch (e) {
              print("Error fetching matches for series ${series.title}: $e");
            }
          }
        }

        seriesList.assignAll(fetchedSeries);
      }
    } catch (e) {
      print("Error fetching series: $e");
    } finally {
      isSeriesLoading.value = false;
    }
  }

  Future<void> fetchStarPlayers() async {
    isPlayersLoading.value = true;
    try {
      final res = await _matchRepository.getStarPlayers();
      if (res['success'] == true) {
        final data = StarPlayerModel.fromJson(res);
        starPlayers.assignAll(data.highlights ?? []);
      }
    } catch (e) {
      print("Error fetching star players: $e");
    } finally {
      isPlayersLoading.value = false;
    }
  }

  Future<void> fetchPodcasts() async {
    isPodcastLoading.value = true;
    try {
      final res = await _matchRepository.getPodcasts();
      if (res['success'] == true) {
        final data = PodcastModel.fromJson(res);
        podcastList.assignAll(data.podcasts ?? []);
      }
    } catch (e) {
      print("Error fetching podcasts: $e");
    } finally {
      isPodcastLoading.value = false;
    }
  }

  Future<void> fetchSocialMedia() async {
    isSocialLoading.value = true;
    try {
      final res = await _legalRepository.getSocialMedia();
      if (res['success'] == true) {
        final data = SocialMediaResponse.fromJson(res);
        socialMediaList.assignAll(data.social ?? []);
      }
    } catch (e) {
      print("Error fetching social media: $e");
    } finally {
      isSocialLoading.value = false;
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

  Future<void> fetchChannelCategories() async {
    isCategoryLoading.value = true;
    try {
      final res = await _channelRepository.getChannelCategories();
      if (res['success'] == true) {
        final data = ChannelCategoryModel.fromJson(res);
        channelCategories.assignAll(data.categories ?? []);
      }
    } catch (e) {
      print("Error fetching channel categories: $e");
    } finally {
      isCategoryLoading.value = false;
    }
  }

  void filterData(String query) {
    String selectedSport = "";
    if (selectedTabIndex.value != 0 && selectedTabIndex.value < sportsList.length) {
      selectedSport = sportsList[selectedTabIndex.value].toLowerCase();
    }

    if (query.isEmpty && selectedSport.isEmpty) {
      filteredMatches.assignAll(allMatches);
      filteredLiveMatches.assignAll(liveMatches);
      filteredChannels.assignAll(allChannels);
    } else {
      final q = query.toLowerCase();

      filteredMatches.assignAll(allMatches.where((m) {
        bool matchesQuery = q.isEmpty ||
            (m.title?.toLowerCase().contains(q) ?? false) ||
            (m.teamA?.toLowerCase().contains(q) ?? false) ||
            (m.teamB?.toLowerCase().contains(q) ?? false) ||
            (m.sport?.toLowerCase().contains(q) ?? false);
        bool matchesSport = selectedSport.isEmpty || (m.sport?.toLowerCase() == selectedSport);
        return matchesQuery && matchesSport;
      }).toList());

      filteredLiveMatches.assignAll(liveMatches.where((m) {
        bool matchesQuery = q.isEmpty ||
            (m.title?.toLowerCase().contains(q) ?? false) ||
            (m.teamA?.toLowerCase().contains(q) ?? false) ||
            (m.teamB?.toLowerCase().contains(q) ?? false) ||
            (m.sport?.toLowerCase().contains(q) ?? false);
        bool matchesSport = selectedSport.isEmpty || (m.sport?.toLowerCase() == selectedSport);
        return matchesQuery && matchesSport;
      }).toList());

      filteredChannels.assignAll(allChannels.where((c) {
        bool matchesQuery = q.isEmpty || (c.name?.toLowerCase().contains(q) ?? false);
        bool matchesSport = selectedSport.isEmpty || (c.category?.toLowerCase() == selectedSport);
        return matchesQuery && matchesSport;
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
    
    // Trigger data filtering based on the selected sport
    filterData(searchQuery.value);
  }

  void selectSubCategory(String sport) {
    if (selectedCategory.value == sport) {
      selectedCategory.value = ""; // Toggle off
    } else {
      selectedCategory.value = sport;
    }
    // No need to fetch, we filter the already loaded allMatches
  }

  String getSeriesName(String? seriesId) {
    if (seriesId == null) return "";
    final series = seriesList.firstWhereOrNull((s) => s.sId == seriesId);
    return series?.title ?? "";
  }

  String getSeriesLogo(String? seriesId) {
    if (seriesId == null) return "";
    final series = seriesList.firstWhereOrNull((s) => s.sId == seriesId);
    return series?.tournamentLogo ?? series?.banner ?? "";
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
      fetchBanners();
      // Fetch Live Matches
      final liveRes = await _matchRepository.getLiveMatches();
      if (liveRes['success'] == true) {
        final data = MatchModel.fromJson(liveRes);
        liveMatches.assignAll(data.matches ?? []);
        
        // Fetch real-time scores for live matches
        for (var match in liveMatches) {
          if (match.sId != null) {
            fetchLiveScore(match.sId!);
          }
        }
      }

      // Always fetch all matches for the dashboard
      final allRes = await _matchRepository.getAllMatches();
      if (allRes['success'] == true) {
        final data = MatchModel.fromJson(allRes);
        var fetchedMatches = data.matches ?? [];

        allMatches.assignAll(fetchedMatches);
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

  Future<void> fetchLiveScore(String matchId) async {
    try {
      final res = await _matchRepository.getLiveScore(matchId);
      if (res['success'] == true) {
        final scoreModel = ScoreModel.fromJson(res);
        if (scoreModel.data != null) {
          liveScores[matchId] = scoreModel.data!;
        }
      }
    } catch (e) {
      debugPrint("Error fetching live score for $matchId: $e");
    }
  }

  // var isLogin = false.obs;

  void toggleLogin() {
    isLogin.value = !isLogin.value;
    if (isLogin.value) {
      userName.value = HiveService.getUser()?.name ?? "";
    } else {
      userName.value = "";
    }
  }

  void handleProtectedAction(VoidCallback onSuccess, {bool checkAccess = false, bool hasPermission = true}) {
    if (isLogin.value) {
      if (checkAccess && !hasPermission) {
        Get.toNamed(AppRoutes.accessPlan);
        return;
      }
      onSuccess();
    } else {
      _showLoginBottomSheet();
    }
  }

  void _startScoreTimer() {
    _scoreTimer?.cancel();
    _scoreTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (liveMatches.isNotEmpty) {
        for (var match in liveMatches) {
          if (match.sId != null) {
            fetchLiveScore(match.sId!);
          }
        }
      }
    });
  }

  @override
  void onClose() {
    _scoreTimer?.cancel();
    super.onClose();
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
