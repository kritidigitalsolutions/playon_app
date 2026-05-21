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
      // Lock only if (isPremium is true OR isSeriesPremium is true) AND (user has no active plan)
      // Otherwise (if not premium OR if user has a plan), it stays unlocked.
      isLock.value = (match.value?.isPremium == true || match.value?.isSeriesPremium == true) &&
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

  void _loadInitialData() {
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
        initializeVideo(starPlayer.value!.videoUrl!, isHighlight: true);
      }
    } else if (Get.arguments is String) {
      fetchMatchDetails(Get.arguments, isHighlight: isHighlightMode);
    }
  }

  /// ✅ Method to manually refresh data if controller is reused
  void refreshWithArguments(dynamic arguments) {
    // Reset state
    isInitialized.value = false;
    isLoading.value = true;
    matchData.value = null;
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
        initializeVideo(starPlayer.value!.videoUrl!, isHighlight: true);
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
        ever(matchDetails.isLock, (bool locked) {
          if (locked) {
            if (videoController != null && videoController!.value.isPlaying) {
              videoController?.pause();
              isPlaying.value = false;
              showControls.value = true;
            }
          } else {
            // If it was locked and we now have access, try to initialize video if not already done
            if (!isInitialized.value && !isLoading.value) {
              final isHighlightMode = Get.parameters['mode'] == 'highlight';
              if (match.value != null) {
                fetchMatchDetails(match.value!.sId!, isHighlight: isHighlightMode);
              } else if (starPlayer.value != null && starPlayer.value!.videoUrl != null) {
                initializeVideo(starPlayer.value!.videoUrl!, isHighlight: true);
              }
            } else if (videoController != null && !videoController!.value.isPlaying) {
              // If already initialized but paused due to lock, resume
              videoController?.play();
              isPlaying.value = true;
            }
          }
        });
      }
    });
  }

  Future<void> fetchMatchDetails(String matchId, {bool isHighlight = false}) async {
    isLoading.value = true;
    try {
      // 0. Check if the match already has a live stream object from the dashboard fetch
      if (match.value?.stream?.streamUrl != null && 
          (match.value?.stream?.status?.toLowerCase() == 'live' || match.value?.status?.toLowerCase() == 'live') && 
          !isHighlight) {
        print("Using already present stream from match object: ${match.value?.stream?.streamUrl}");
        initializeVideo(
          match.value!.stream!.streamUrl!,
          streamType: match.value!.stream!.streamType,
        );
      }
      
      // 1. If we already have a videoUrl (passed from highlights screen), use it!
      else if (match.value?.videoUrl != null && isHighlight) {
        initializeVideo(match.value!.videoUrl!, isHighlight: true);
      }
      // 2. If it's a finished match, try to play the first highlight automatically from the new highlights API
      else if (isHighlight) {
        final res = await _matchRepo.getHighlights(matchId: matchId);
        if (res['success'] == true && res['highlights'] != null) {
          final List highlightsList = res['highlights'];
          if (highlightsList.isNotEmpty) {
            final firstHighlight = highlightsList.first;
            if (firstHighlight['videoUrl'] != null) {
              initializeVideo(firstHighlight['videoUrl'], isHighlight: true);
            }
          }
        }
      }

      // 3. If it's a live match and we don't have a stream yet, fetch from the live streams API
      if (!isInitialized.value && match.value?.status?.toLowerCase() == 'live') {
        final streamsRes = await _matchRepo.getLiveStreams();
        if (streamsRes['success'] == true && streamsRes['streams'] != null) {
          final List streams = streamsRes['streams'];
          final stream = streams.firstWhereOrNull((s) {
            final mData = s['matchId'];
            if (mData is Map) return mData['_id'] == matchId;
            return mData == matchId;
          });

          if (stream != null && stream['streamUrl'] != null) {
            print("Playing live stream from dedicated endpoint: ${stream['streamUrl']}");
            initializeVideo(
              stream['streamUrl'],
              streamType: stream['streamType'],
            );
          }
        }
      }

      // 4. Fetch official watchMatch API for full match object (teams, logos, status etc)
      final response = await _matchRepo.watchMatch(matchId);
      matchData.value = model.WatchMatchResponse.fromJson(response);

      // Fetch live score in background
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().fetchLiveScore(matchId);
      }
      
      if (matchData.value?.match != null) {
        final newMatch = matchData.value!.match!;
        newMatch.isSeriesPremium = match.value?.isSeriesPremium;
        match.value = newMatch;
      }
      
      // If we haven't initialized video yet (e.g. not a highlight/live stream found above), 
      // or if we just want to ensure the primary stream is used if available.
      if (!isInitialized.value && matchData.value?.stream?.streamUrl != null) {
        initializeVideo(
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

  void initializeVideo(String url, {bool isHighlight = false, String? streamType}) {
    // Don't initialize if it's currently locked
    if (Get.isRegistered<MatchDetailsController>() && Get.find<MatchDetailsController>().isLock.value) {
      debugPrint("Video: Cannot initialize, content is locked.");
      return;
    }

    debugPrint("Initializing Video: $url (Type: $streamType)");

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
