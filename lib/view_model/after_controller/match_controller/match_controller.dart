import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:collection/collection.dart';
import 'package:get_storage/get_storage.dart';
import 'package:play_on_app/model/response_model/highlight_model.dart' as highlight_model;
import 'package:play_on_app/model/response_model/comment_model.dart' as comment_model;
import 'package:play_on_app/model/response_model/star_player_model.dart' as star_model;
import 'package:play_on_app/repo/match_repository.dart';
import 'package:video_player/video_player.dart';
import 'package:play_on_app/model/response_model/match_model.dart' as model;
import 'package:play_on_app/view_model/after_controller/ad_controller.dart';
import 'package:play_on_app/view_model/after_controller/plan_controller.dart';
import 'package:play_on_app/data/network/notification_service.dart';
import 'package:play_on_app/view_model/after_controller/home_contollers/home_controller.dart';
import 'package:play_on_app/model/response_model/score_model.dart' as score_model;
import 'package:play_on_app/model/response_model/match_extra_details_model.dart';
import 'package:play_on_app/utils/custom_snakebar.dart';

import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MatchDetailsController extends GetxController {
  final match = Rxn<model.Match>();
  final starPlayer = Rxn<star_model.StarPlayer>();
  var isLive = false.obs;
  var remainingTime = "".obs;
  var isReminderOn = false.obs;
  var isLock = true.obs;
  final deletingCommentId = ''.obs;

  var highlights = <highlight_model.HighlightItem>[].obs;
  var isHighlightsLoading = false.obs;

  var comments = <comment_model.Comment>[].obs;
  var isCommentsLoading = false.obs;
  final commentController = TextEditingController();

  // New Scoreboard and details observables
  final scoreboardData = Rxn<score_model.ScoreData>();
  final matchPlayers = Rxn<MatchPlayersData>();
  final matchStats = Rxn<MatchStatsData>();
  final topPerformers = Rxn<TopPerformersData>();
  final matchEvents = Rxn<MatchEventsData>();
  
  var isScoreLoading = false.obs;

  final MatchRepository _repository = MatchRepository();
  final planController = Get.put(PlanController());

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();

    // Re-check access whenever plan status or data changes
    ever(planController.hasAccess, (_) => checkAccess());
    ever(planController.mySubscription, (_) => checkAccess());
    ever(match, (_) => checkAccess());
    ever(starPlayer, (_) => checkAccess());

    if (Get.arguments is model.Match) {
      match.value = Get.arguments;
      _initializeMatchStatus();
      _checkReminderStatus();
      fetchHighlights();
      fetchComments();
      // Even if we have a match object, fetch full details to ensure we have all info (logos, series, etc.)
      fetchMatchDetailsById(match.value!.sId!);
    } else if (Get.arguments is star_model.StarPlayer) {
      starPlayer.value = Get.arguments;
      fetchComments();
    } else if (Get.arguments is String) {
      // Handle deep link ID
      fetchMatchDetailsById(Get.arguments);
    }

    checkAccess();
  }

  Future<void> fetchAllMatchDetails() async {
    if (match.value?.sId == null) return;
    
    fetchScoreboard();
    fetchMatchPlayers();
    fetchMatchStats();
    fetchTopPerformers();
    fetchMatchEvents();
  }

  Future<void> fetchScoreboard() async {
    try {
      isScoreLoading.value = true;
      final res = await _repository.getScoreboard(match.value!.sId!);
      if (res['success'] == true) {
        scoreboardData.value = score_model.ScoreData.fromJson(res['data']);
      }
    } catch (e) {
      print("Error fetching scoreboard: $e");
    } finally {
      isScoreLoading.value = false;
    }
  }

  Future<void> fetchMatchPlayers() async {
    try {
      final res = await _repository.getMatchPlayers(match.value!.sId!);
      if (res['success'] == true) {
        matchPlayers.value = MatchPlayersData.fromJson(res['data']);
      }
    } catch (e) {
      print("Error fetching match players: $e");
    }
  }

  Future<void> fetchMatchStats() async {
    try {
      final res = await _repository.getMatchStats(match.value!.sId!);
      if (res['success'] == true) {
        matchStats.value = MatchStatsData.fromJson(res['data']);
      }
    } catch (e) {
      print("Error fetching match stats: $e");
    }
  }

  Future<void> fetchTopPerformers() async {
    try {
      final res = await _repository.getMatchTopPerformers(match.value!.sId!);
      if (res['success'] == true) {
        topPerformers.value = TopPerformersData.fromJson(res['data']);
      }
    } catch (e) {
      print("Error fetching top performers: $e");
    }
  }

  Future<void> fetchMatchEvents() async {
    try {
      final res = await _repository.getMatchEvents(match.value!.sId!);
      if (res['success'] == true) {
        matchEvents.value = MatchEventsData.fromJson(res['data']);
      }
    } catch (e) {
      print("Error fetching match events: $e");
    }
  }

  Future<void> fetchMatchDetailsById(String id) async {
    try {
      final res = await _repository.getMatchDetails(id);
      if (res['success'] == true) {
        if (res['match'] != null) {
          match.value = model.Match.fromJson(res['match']);
        } else if (res['data'] != null) {
          match.value = model.Match.fromJson(res['data']);
        }

        // Sync with video controller to ensure UI consistency across all components
        if (Get.isRegistered<VideoControllerX>()) {
          final videoCtr = Get.find<VideoControllerX>();
          if (match.value != null) {
            // Preserve isSeriesPremium if it was already set
            final oldMatch = videoCtr.match.value;
            if (oldMatch?.sId == match.value?.sId) {
              match.value?.isSeriesPremium = oldMatch?.isSeriesPremium;
            }
            videoCtr.match.value = match.value;
          }
        }

        _initializeMatchStatus();
        _checkReminderStatus();
        fetchHighlights();
        fetchComments();
        fetchAllMatchDetails();
        checkAccess();
      }
    } catch (e) {
      print("Error fetching match by ID: $e");
    }
  }

  Future<void> fetchHighlights() async {
    if (match.value?.sId == null) return;
    isHighlightsLoading.value = true;
    try {
      final res = await _repository.getHighlights(matchId: match.value!.sId!);
      if (res['success'] == true) {
        final data = highlight_model.HighlightModel.fromJson(res);
        highlights.assignAll(data.highlights ?? []);
      }
    } catch (e) {
      print("Error fetching highlights: $e");
    } finally {
      isHighlightsLoading.value = false;
    }
  }

  Future<void> fetchComments() async {
    final itemId = match.value?.sId ?? starPlayer.value?.sId;
    if (itemId == null) return;
    isCommentsLoading.value = true;
    try {
      final res = await _repository.getMatchComments(itemId);
      if (res['success'] == true) {
        final data = comment_model.CommentModel.fromJson(res);
        comments.assignAll(data.comments ?? []);
      }
    } catch (e) {
      print("Error fetching comments: $e");
    } finally {
      isCommentsLoading.value = false;
    }
  }

  Future<void> addComment() async {
    final itemId = match.value?.sId ?? starPlayer.value?.sId;
    if (itemId == null || commentController.text.trim().isEmpty) return;

    final commentText = commentController.text.trim();
    commentController.clear();

    try {
      final res = await _repository.addComment(itemId, commentText);
      if (res['success'] == true) {
        fetchComments();
      } else {
        showCustomSnackbar(title: "Error", message: res['message'] ?? "Failed to add comment", type: SnackType.error);
      }
    } catch (e) {
      showCustomSnackbar(title: "Error", message: "Failed to add comment", type: SnackType.error);
    }
  }
  Future<void> deleteComment(String commentId) async {
    try {
      deletingCommentId.value = commentId;

      final res = await _repository.deleteComment(commentId);

      if (res['success'] == true) {
        comments.removeWhere((e) => e.sId == commentId);
      } else {
        showCustomSnackbar(
          title: "Error",
          message: res['message'] ?? "Failed to delete comment",
          type: SnackType.error,
        );
      }
    } catch (e) {
      showCustomSnackbar(
        title: "Error",
        message: "Failed to delete comment",
        type: SnackType.error,
      );
    } finally {
      deletingCommentId.value = '';
    }
  }

  void _checkReminderStatus() {
    if (match.value == null) return;
    final reminders = GetStorage().read<List>('reminders') ?? [];
    isReminderOn.value = reminders.contains(match.value!.sId);
  }

  bool isReminded(String matchId) {
    final reminders = GetStorage().read<List>('reminders') ?? [];
    return reminders.contains(matchId);
  }

  void checkAccess() {
    if (match.value != null) {
      bool seriesPremium = match.value?.isSeriesPremium ?? false;

      // If isSeriesPremium is not set, look it up from HomeController's series list
      if (!seriesPremium && match.value?.seriesId != null) {
        if (Get.isRegistered<HomeController>()) {
          final homeCtr = Get.find<HomeController>();
          final series = homeCtr.seriesList.firstWhereOrNull((s) => s.sId == match.value?.seriesId);
          if (series != null) {
            seriesPremium = series.isPremium ?? false;
            // Update the match object's premium status for future checks
            match.value?.isSeriesPremium = seriesPremium;
          }
        }
      }

      // Lock only if (isPremium is true OR isSeriesPremium is true) AND (user has no active plan)
      // Otherwise (if not premium OR if user has a plan), it stays unlocked.
      isLock.value = (match.value?.isPremium == true || seriesPremium) &&
                     !planController.canWatchMatch(match.value);
    } else if (starPlayer.value != null) {
      // For star player highlights
      isLock.value = (starPlayer.value?.isPremium == true) &&
                     !planController.canWatchHighlight(starPlayer.value);
    }
  }

  void _initializeMatchStatus() {
    if (match.value == null) return;

    if (match.value!.status?.toLowerCase() == 'live') {
      isLive.value = true;
      remainingTime.value = "Live Now";
    } else if (match.value!.matchDate != null) {
      final startTime = DateTime.parse(match.value!.matchDate!);
      _startCountdown(startTime);
    }
  }

  void _startCountdown(DateTime startTime) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final diff = startTime.difference(DateTime.now());

      if (diff.inSeconds <= 0) {
        isLive.value = true;
        remainingTime.value = "Live Now";
        timer.cancel();
      } else {
        if (diff.inDays > 0) {
          remainingTime.value = "Starting in ${diff.inDays}d ${diff.inHours % 24}h";
        } else if (diff.inHours > 0) {
          remainingTime.value = "Starting in ${diff.inHours}h ${diff.inMinutes % 60}m";
        } else {
          remainingTime.value = "Starting in ${diff.inMinutes}m ${diff.inSeconds % 60}s";
        }
      }
    });
  }

  void toggleReminder() async {
    if (match.value == null) return;

    final storage = GetStorage();
    List reminders = storage.read<List>('reminders') ?? [];

    if (isReminderOn.value) {
      // Remove reminder
      reminders.remove(match.value!.sId);
      await storage.write('reminders', reminders);
      isReminderOn.value = false;
      
      // Cancel notification
      NotificationService.cancelNotification(match.value!.sId.hashCode);
      
      showCustomSnackbar(title: "Reminder Removed", message: "You will not be notified for this match.", type: SnackType.info);
    } else {
      // Set reminder
      if (match.value!.matchDate == null) {
        showCustomSnackbar(title: "Error", message: "Match date not available", type: SnackType.error);
        return;
      }

      final startTime = DateTime.parse(match.value!.matchDate!);
      if (startTime.isBefore(DateTime.now())) {
        showCustomSnackbar(title: "Error", message: "Match has already started", type: SnackType.error);
        return;
      }

      // Notification time (e.g., 5 minutes before)
      final notificationTime = startTime.subtract(const Duration(minutes: 5));
      
      if (notificationTime.isBefore(DateTime.now())) {
        // If less than 5 mins remains, notify at start time or immediately
        NotificationService.scheduleNotification(
          id: match.value!.sId.hashCode,
          title: "Match Starting Soon!",
          body: "${match.value!.teamA} vs ${match.value!.teamB} is about to start.",
          scheduledDate: startTime,
        );
      } else {
        NotificationService.scheduleNotification(
          id: match.value!.sId.hashCode,
          title: "Match Reminder",
          body: "${match.value!.teamA} vs ${match.value!.teamB} starts in 5 minutes.",
          scheduledDate: notificationTime,
        );
      }

      reminders.add(match.value!.sId);
      await storage.write('reminders', reminders);
      isReminderOn.value = true;
      
      showCustomSnackbar(title: "Reminder Set", message: "We will notify you before the match starts.", type: SnackType.success);
    }
  }

  void toggleLock() {
    isLock.value = !isLock.value;
  }

  // Unlock the match (called when video is ready or user buys plan)
  void unlockMatch() {
    isLock.value = false;
  }

  @override
  void onClose() {
    _timer?.cancel();
    commentController.dispose();
    super.onClose();
  }
}

class VideoControllerX extends GetxController {
  final _matchRepo = MatchRepository();
  VideoPlayerController? videoController;
  YoutubePlayerController? youtubeController;

  final match = Rxn<model.Match>();
  final starPlayer = Rxn<star_model.StarPlayer>();
  final currentHighlight = Rxn<highlight_model.HighlightItem>();
  var isInitialized = false.obs;
  var isYoutube = false.obs;
  var isPlaying = false.obs;
  var showControls = true.obs;
  var matchData = Rxn<model.WatchMatchResponse>();
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
    // Stop playback if access is revoked
    _setupLockListener();
  }

  Future<void> _loadInitialData() async {
    bool isHighlightMode = Get.parameters['mode'] == 'highlight';

    if (Get.arguments is model.Match) {
      match.value = Get.arguments;
      starPlayer.value = null;
      final status = match.value?.status?.toLowerCase();
      bool isFinished = status == 'finished' || status == 'completed' || isHighlightMode;
      fetchMatchDetails(match.value!.sId!, isHighlight: isFinished);
    } else if (Get.arguments is star_model.StarPlayer) {
      starPlayer.value = Get.arguments;
      match.value = null;
      isLoading.value = false;
      if (starPlayer.value?.videoUrl != null) {
        await initializeVideo(starPlayer.value!.videoUrl!, isHighlight: true);
      }
    } else if (Get.arguments is String) {
      fetchMatchDetails(Get.arguments, isHighlight: isHighlightMode);
    }
  }

  /// ✅ Method to manually refresh data if controller is reused
  Future<void> refreshWithArguments(dynamic arguments) async {
    // Reset state
    isInitialized.value = false;
    isLoading.value = true;
    matchData.value = null;
    currentHighlight.value = null;
    _disposeControllers();
    
    // Process new arguments
    bool isHighlightMode = Get.parameters['mode'] == 'highlight';

    if (arguments is model.Match) {
      match.value = arguments;
      starPlayer.value = null;
      final status = match.value?.status?.toLowerCase();
      bool isFinished = status == 'finished' || status == 'completed' || isHighlightMode;
      fetchMatchDetails(match.value!.sId!, isHighlight: isFinished);
    } else if (arguments is star_model.StarPlayer) {
      starPlayer.value = arguments;
      match.value = null;
      isLoading.value = false;
      if (starPlayer.value?.videoUrl != null) {
        await initializeVideo(starPlayer.value!.videoUrl!, isHighlight: true);
      }
    } else if (arguments is String) {
      fetchMatchDetails(arguments, isHighlight: isHighlightMode);
    }
  }

  void _disposeControllers() {
    videoController?.dispose();
    youtubeController?.dispose();
    videoController = null;
    youtubeController = null;
  }

  void _setupLockListener() {
    Future.delayed(Duration.zero, () {
      if (Get.isRegistered<MatchDetailsController>()) {
        final matchDetails = Get.find<MatchDetailsController>();
        
        // Listen to isLock changes
        ever(matchDetails.isLock, (bool locked) {
          // If locked, only pause if we are NOT in highlight mode
          // Highlights are generally free even if the match is locked
          bool isHighlightMode = Get.parameters['mode'] == 'highlight' || currentHighlight.value != null;
          
          if (locked && !isHighlightMode) {
            if (videoController != null && videoController!.value.isPlaying) {
              videoController?.pause();
              isPlaying.value = false;
              showControls.value = true;
            }
          } else if (!locked) {
            // If it was locked and we now have access, try to initialize video if not already done
            _retryInitializationIfNecessary();
            
            if (videoController != null && !videoController!.value.isPlaying && isInitialized.value) {
              // If already initialized but paused due to lock, resume
              videoController?.play();
              isPlaying.value = true;
            }
          }
        });

        // REMOVED: ever(isLoading, ...) which was causing infinite loops on 403 errors
        // Instead, we trust the manual calls and isLock listener to trigger initialization.
      }
    });
  }

  Future<void> _retryInitializationIfNecessary() async {
    if (isInitialized.value || isLoading.value) return;
    
    final matchDetails = Get.find<MatchDetailsController>();
    if (matchDetails.isLock.value) return;

    final isHighlightMode = Get.parameters['mode'] == 'highlight';
    if (match.value != null) {
      final status = match.value?.status?.toLowerCase();
      bool isFinished = status == 'finished' || status == 'completed' || isHighlightMode;
      await fetchMatchDetails(match.value!.sId!, isHighlight: isFinished);
    } else if (starPlayer.value != null && starPlayer.value!.videoUrl != null) {
      await initializeVideo(starPlayer.value!.videoUrl!, isHighlight: true);
    }
  }

  Future<void> fetchMatchDetails(String matchId, {bool isHighlight = false}) async {
    // If we already have a video initialized for this match/highlight, don't restart unless explicitly requested
    if (isInitialized.value && match.value?.sId == matchId) {
      debugPrint("Video already initialized for $matchId");
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    try {
      // 1. If we already have a videoUrl (e.g. from highlights screen or previous fetch), try playing it immediately
      // This makes the UI feel much faster.
      if (match.value?.sId == matchId) {
        final videoUrl = match.value?.videoUrl;
        final streamUrl = match.value?.stream?.streamUrl;

        if (videoUrl != null && videoUrl.isNotEmpty) {
           await initializeVideo(videoUrl, isHighlight: isHighlight);
        } else if (streamUrl != null && streamUrl.isNotEmpty) {
           await initializeVideo(
             streamUrl, 
             streamType: match.value?.stream?.streamType,
             isHighlight: isHighlight,
           );
        }
      }

      // 2. Fetch official watchMatch API for latest status, recordings, and stream links
      try {
        final response = await _matchRepo.watchMatch(matchId);
        matchData.value = model.WatchMatchResponse.fromJson(response);

        if (matchData.value?.match != null) {
          final newMatch = matchData.value!.match!;
          
          // Preserve videoUrl and seriesId from original match object if they were provided 
          // (especially for highlights clicked from Home that pass these as arguments)
          if (newMatch.videoUrl == null || newMatch.videoUrl!.isEmpty) {
            newMatch.videoUrl = match.value?.videoUrl;
          }
          if (newMatch.seriesId == null || newMatch.seriesId!.isEmpty) {
            newMatch.seriesId = match.value?.seriesId;
          }

          newMatch.isSeriesPremium = match.value?.isSeriesPremium;
          match.value = newMatch;
          
          // Update isHighlight based on actual fetched status
          final status = newMatch.status?.toLowerCase();
          if (status == 'finished' || status == 'completed') {
            isHighlight = true;
          }
        }
      } catch (apiError) {
        debugPrint("watchMatch API Error: $apiError");
        // If it's a 403, mark it as locked in the UI
        if (apiError.toString().contains("403") || apiError.toString().contains("UnauthorizedException")) {
          if (Get.isRegistered<MatchDetailsController>()) {
            final mDetails = Get.find<MatchDetailsController>();
            
            // Re-check access with lookup
            mDetails.checkAccess();
            
            // Only force lock if the match/series is actually premium
            // If it's supposedly free but getting 403, we keep mDetails.isLock as is (which should be false)
            // and let Step 1 or Step 6 try to play with existing URLs.
            if (match.value?.isPremium == true || match.value?.isSeriesPremium == true) {
              mDetails.isLock.value = true;
            }
          }
        }
      }

      // Fetch live score in background
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().fetchLiveScore(matchId);
      }

      // 3. Re-check if we can play a main video recording or stream after fetching latest data
      if (!isInitialized.value) {
        final videoUrl = match.value?.videoUrl;
        final streamUrl = match.value?.stream?.streamUrl ?? matchData.value?.stream?.streamUrl;

        if (videoUrl != null && videoUrl.isNotEmpty) {
          await initializeVideo(videoUrl, isHighlight: isHighlight);
        } else if (streamUrl != null && streamUrl.isNotEmpty) {
          await initializeVideo(
            streamUrl,
            streamType: match.value?.stream?.streamType ?? matchData.value?.stream?.streamType,
            isHighlight: isHighlight,
          );
        }
      }
      
      // 4. If it's a live match and still not initialized, try dedicated live streams endpoint
      if (!isInitialized.value && !isHighlight && match.value?.status?.toLowerCase() == 'live') {
        try {
          final streamsRes = await _matchRepo.getLiveStreams();
          if (streamsRes['success'] == true && streamsRes['streams'] != null) {
            final List streams = streamsRes['streams'];
            final stream = streams.firstWhereOrNull((s) {
              final mData = s['matchId'];
              if (mData is Map) return mData['_id'] == matchId;
              return mData == matchId;
            });

            if (stream != null && stream['streamUrl'] != null) {
              await initializeVideo(
                stream['streamUrl'],
                streamType: stream['streamType'],
              );
            }
          }
        } catch (e) {
          debugPrint("Error fetching live streams: $e");
        }
      }

      // 5. If still not initialized and it's a finished match, try highlights API
      if (!isInitialized.value && isHighlight) {
        try {
          final res = await _matchRepo.getHighlights(matchId: matchId);
          if (res['success'] == true && res['highlights'] != null) {
            final List highlightsList = res['highlights'];
            if (highlightsList.isNotEmpty) {
              final firstHighlight = highlightsList.first;
              final hItem = highlight_model.HighlightItem.fromJson(firstHighlight);
              currentHighlight.value = hItem;
              if (hItem.videoUrl != null) {
                await initializeVideo(hItem.videoUrl!, isHighlight: true);
              }
            }
          }
        } catch (e) {
          debugPrint("Error fetching highlights for player: $e");
        }
      }

      // 6. Last resort: check if matchData has any streamUrl left
      if (!isInitialized.value && matchData.value?.stream?.streamUrl != null) {
        await initializeVideo(
          matchData.value!.stream!.streamUrl!,
          streamType: matchData.value!.stream!.streamType,
        );
      }
    } catch (e) {
      print("Error in fetchMatchDetails: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> initializeVideo(String url, {bool isHighlight = false, String? streamType}) async {
    // Don't initialize if it's currently locked
    // EXCEPT for highlights which are usually free
    if (!isHighlight && Get.isRegistered<MatchDetailsController>() && Get.find<MatchDetailsController>().isLock.value) {
      debugPrint("Video: Cannot initialize main stream, content is locked.");
      return;
    }

    debugPrint("Initializing Video: $url (Type: $streamType)");

    // Show Interstitial Ad before playing video
    if (Get.isRegistered<AdController>()) {
      await Get.find<AdController>().showInterstitialAd();
    }

    // Signal UI that we are re-initializing
    isInitialized.value = false;
    
    // If it's a star player or highlight, make sure we show loading state
    if (starPlayer.value != null || isHighlight) {
      isLoading.value = false; // We are processing the URL, let isInitialized handle the loader
    }

    // Capture old controllers to dispose them safely after UI rebuilds
    final oldVideo = videoController;
    final oldYoutube = youtubeController;

    videoController = null;
    youtubeController = null;
    isYoutube.value = false;

    // Small delay to let UI rebuild without old controllers before disposing them
    Future.delayed(const Duration(milliseconds: 100), () {
      oldVideo?.dispose();
      oldYoutube?.dispose();
    });

    // Detect YouTube
    bool isYoutubeUrl = url.contains('youtube.com') || url.contains('youtu.be') || streamType?.toLowerCase() == 'youtube' || streamType?.toLowerCase() == 'yt';

    if (isYoutubeUrl) {
      isYoutube.value = true;
      String? videoId = YoutubePlayer.convertUrlToId(url);
      
      // Better ID extraction for various YouTube URL formats (embed links etc)
      if (videoId == null) {
        final regExp = RegExp(
          r'^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#&?]*).*',
          caseSensitive: false,
          multiLine: false,
        );
        final match = regExp.firstMatch(url);
        if (match != null && match.group(7)!.length == 11) {
          videoId = match.group(7);
        }
      }
      
      // Handle cases where the URL might be just the ID
      if (videoId == null && url.length == 11) {
        videoId = url;
      }

      if (videoId != null) {
        youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: YoutubePlayerFlags(
            autoPlay: true,
            mute: false,
            isLive: match.value?.status?.toLowerCase() == 'live',
          ),
        );
        isInitialized.value = true;
        isPlaying.value = true;
        isLoading.value = false;
      } else {
        debugPrint("Failed to extract YouTube ID from: $url");
        isLoading.value = false;
        showCustomSnackbar(title: "Error", message: "Invalid YouTube URL", type: SnackType.error);
      }
    } else {
      isYoutube.value = false;
      videoController = VideoPlayerController.networkUrl(Uri.parse(url))
        ..initialize().then((_) {
          isInitialized.value = true;
          videoController?.play();
          isPlaying.value = true;
        }).catchError((error) {
          debugPrint("Video Player Error: $error");
          isInitialized.value = false;
          isLoading.value = false;
          showCustomSnackbar(title: "Playback Error", message: "Failed to play stream", type: SnackType.error);
        });
    }

    // Auto hide controls after 3 sec
    _setupAutoHideControls();
  }

  void _setupAutoHideControls() {
    Future.delayed(const Duration(seconds: 3), () {
      if (isPlaying.value) {
        showControls.value = false;
      }
    });
  }

  void togglePlay() {
    if (isYoutube.value) {
      if (youtubeController == null) return;
      if (youtubeController!.value.isPlaying) {
        youtubeController!.pause();
        isPlaying.value = false;
      } else {
        youtubeController!.play();
        isPlaying.value = true;
      }
    } else {
      if (videoController == null) return;
      if (videoController!.value.isPlaying) {
        videoController!.pause();
        isPlaying.value = false;
      } else {
        videoController!.play();
        isPlaying.value = true;
      }
    }
    showControls.value = true;
  }

  void toggleControls() {
    showControls.value = !showControls.value;
  }

  @override
  void onClose() {
    // Signal UI to stop using controllers
    isInitialized.value = false;
    
    final oldVideo = videoController;
    final oldYoutube = youtubeController;
    
    videoController = null;
    youtubeController = null;
    
    // Dispose after a small delay to avoid "controller used after dispose" errors during cleanup
    Future.delayed(const Duration(milliseconds: 100), () {
      oldVideo?.dispose();
      oldYoutube?.dispose();
    });
    super.onClose();
  }
}
