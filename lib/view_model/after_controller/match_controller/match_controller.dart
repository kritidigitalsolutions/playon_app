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

import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MatchDetailsController extends GetxController {
  final match = Rxn<model.Match>();
  final starPlayer = Rxn<star_model.StarPlayer>();
  var isLive = false.obs;
  var remainingTime = "".obs;
  var isReminderOn = false.obs;
  var isLock = true.obs;

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
        Get.snackbar("Error", res['message'] ?? "Failed to add comment");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to add comment");
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
      
      Get.snackbar("Reminder Removed", "You will not be notified for this match.");
    } else {
      // Set reminder
      if (match.value!.matchDate == null) {
        Get.snackbar("Error", "Match date not available");
        return;
      }

      final startTime = DateTime.parse(match.value!.matchDate!);
      if (startTime.isBefore(DateTime.now())) {
        Get.snackbar("Error", "Match has already started");
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
      
      Get.snackbar("Reminder Set", "We will notify you before the match starts.");
    }
  }

  void toggleLock() {
    isLock.value = !isLock.value;
  }

  // Unlock the match (called when video is ready or user buys plan)
  void unlockMatch() {
    isLock.value = false;
    // You can also show a success message
    Get.snackbar(
      "Success",
      "Match unlocked successfully!",
      backgroundColor: Colors.green.withValues(alpha: 0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
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
    
    bool isHighlightMode = Get.parameters['mode'] == 'highlight';

    if (Get.arguments is model.Match) {
      match.value = Get.arguments;
      final status = match.value?.status?.toLowerCase();
      bool isFinished = status == 'finished' || status == 'completed' || isHighlightMode;
      fetchMatchDetails(match.value!.sId!, isHighlight: isFinished);
    } else if (Get.arguments is star_model.StarPlayer) {
      starPlayer.value = Get.arguments;
    } else if (Get.arguments is String) {
      fetchMatchDetails(Get.arguments, isHighlight: isHighlightMode);
    }

    // Stop playback if access is revoked
    _setupLockListener();
  }

  void _setupLockListener() {
    // We use a delay to ensure MatchDetailsController is registered if needed,
    // but usually they are put together in the same screen.
    Future.delayed(Duration.zero, () {
      if (Get.isRegistered<MatchDetailsController>()) {
        final matchDetails = Get.find<MatchDetailsController>();
        ever(matchDetails.isLock, (bool locked) {
          if (locked && videoController != null && videoController!.value.isPlaying) {
            videoController?.pause();
            isPlaying.value = false;
            showControls.value = true;
          }
        });
      }
    });
  }

  Future<void> fetchMatchDetails(String matchId, {bool isHighlight = false}) async {
    isLoading.value = true;
    try {
      // 1. If it's a finished match, try to play the first highlight automatically from the new highlights API
      if (isHighlight) {
        final res = await _matchRepo.getHighlights(matchId: matchId);
        if (res['success'] == true && res['highlights'] != null) {
          final List highlightsList = res['highlights'];
          if (highlightsList.isNotEmpty) {
            final firstHighlight = highlightsList.first;
            if (firstHighlight['videoUrl'] != null) {
              initializeVideo(firstHighlight['videoUrl'], isHighlight: true);
              // Do not return here, continue to fetch match details for UI info
            }
          }
        }
      }

      // 2. If it's a live match, fetch from the live streams API
      if (match.value?.status?.toLowerCase() == 'live') {
        final streamsRes = await _matchRepo.getLiveStreams();
        if (streamsRes['success'] == true && streamsRes['streams'] != null) {
          final List streams = streamsRes['streams'];
          final stream = streams.firstWhereOrNull((s) {
            final mData = s['matchId'];
            if (mData is Map) return mData['_id'] == matchId;
            return mData == matchId;
          });

          if (stream != null && stream['streamUrl'] != null) {
            print("Playing live stream: ${stream['streamUrl']}");
            initializeVideo(
              stream['streamUrl'],
              streamType: stream['streamType'],
            );
            // Do not return here, continue to fetch match details for UI info
          }
        }
      }

      // 3. Fetch official watchMatch API for full match object (teams, logos, status etc)
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
      if (!isInitialized.value) {
        Get.snackbar("Error", "Failed to load match video");
      }
    } finally {
      isLoading.value = false;
    }
  }

  void initializeVideo(String url, {bool isHighlight = false, String? streamType}) {
    // Don't initialize if it's currently locked
    if (Get.isRegistered<MatchDetailsController>() && Get.find<MatchDetailsController>().isLock.value) {
      return;
    }

    print("Initializing Video: $url (Type: $streamType)");

    // Reset previous controllers
    videoController?.dispose();
    youtubeController?.dispose();
    videoController = null;
    youtubeController = null;
    isInitialized.value = false;
    isYoutube.value = false;

    // Detect YouTube
    bool isYoutubeUrl = url.contains('youtube.com') || url.contains('youtu.be') || streamType?.toLowerCase() == 'youtube';

    if (isYoutubeUrl) {
      isYoutube.value = true;
      String? videoId = YoutubePlayer.convertUrlToId(url);
      
      // Better ID extraction for various YouTube URL formats
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
      } else {
        print("Failed to extract YouTube ID from: $url");
        Get.snackbar("Error", "Invalid YouTube URL");
      }
    } else {
      isYoutube.value = false;
      videoController = VideoPlayerController.networkUrl(Uri.parse(url))
        ..initialize().then((_) {
          isInitialized.value = true;
          videoController?.play();
          isPlaying.value = true;
        }).catchError((error) {
          print("Video Player Error: $error");
          Get.snackbar("Playback Error", "Failed to play stream");
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
    videoController?.dispose();
    youtubeController?.dispose();
    super.onClose();
  }
}
