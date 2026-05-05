import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:play_on_app/model/response_model/highlight_model.dart';
import 'package:play_on_app/model/response_model/comment_model.dart' as comment_model;
import 'package:play_on_app/model/response_model/star_player_model.dart' as star_model;
import 'package:play_on_app/repo/match_repository.dart';
import 'package:video_player/video_player.dart';
import 'package:play_on_app/model/response_model/match_model.dart' as model;
import 'package:play_on_app/view_model/after_controller/plan_controller.dart';
import 'package:play_on_app/data/network/notification_service.dart';

class MatchDetailsController extends GetxController {
  final match = Rxn<model.Match>();
  final starPlayer = Rxn<star_model.StarPlayer>();
  var isLive = false.obs;
  var remainingTime = "".obs;
  var isReminderOn = false.obs;
  var isLock = true.obs;

  var highlights = <HighlightItem>[].obs;
  var isHighlightsLoading = false.obs;

  var comments = <comment_model.Comment>[].obs;
  var isCommentsLoading = false.obs;
  final commentController = TextEditingController();

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
    } else if (Get.arguments is star_model.StarPlayer) {
      starPlayer.value = Get.arguments;
      fetchComments();
    } else if (Get.arguments is String) {
      // Handle deep link ID
      fetchMatchDetailsById(Get.arguments);
    }

    checkAccess();
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
        _initializeMatchStatus();
        _checkReminderStatus();
        fetchHighlights();
        fetchComments();
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
      final res = await _repository.getMatchHighlights(match.value!.sId!);
      if (res['success'] == true) {
        final data = HighlightModel.fromJson(res);
        highlights.assignAll(data.data?.highlights ?? []);
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

  final match = Rxn<model.Match>();
  final starPlayer = Rxn<star_model.StarPlayer>();
  var isInitialized = false.obs;
  var isPlaying = false.obs;
  var showControls = true.obs;
  var matchData = Rxn<model.WatchMatchResponse>();
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    
    if (Get.arguments is model.Match) {
      match.value = Get.arguments;
      fetchMatchDetails(match.value!.sId!);
    } else if (Get.arguments is star_model.StarPlayer) {
      starPlayer.value = Get.arguments;
    } else if (Get.arguments is String) {
      fetchMatchDetails(Get.arguments);
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
      if (isHighlight) {
        final res = await _matchRepo.getMatchHighlights(matchId);
        if (res['success'] == true) {
          final data = HighlightModel.fromJson(res);
          if (data.data?.highlights != null && data.data!.highlights!.isNotEmpty) {
            final videoUrl = data.data!.highlights!.first.videoUrl;
            if (videoUrl != null) {
              initializeVideo(videoUrl, isHighlight: true);
              return;
            }
          }
        }
      }

      final response = await _matchRepo.watchMatch(matchId);
      matchData.value = model.WatchMatchResponse.fromJson(response);
      
      // Update match if API returns more detailed info
      if (matchData.value?.match != null) {
        final newMatch = matchData.value!.match!;
        // Preserve isSeriesPremium flag which might have been set by HomeController
        newMatch.isSeriesPremium = match.value?.isSeriesPremium;
        match.value = newMatch;
      }
      
      if (matchData.value?.stream?.streamUrl != null) {
        initializeVideo(matchData.value!.stream!.streamUrl!);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load match details");
    } finally {
      isLoading.value = false;
    }
  }

  void initializeVideo(String url, {bool isHighlight = false}) {
    // Don't initialize if it's currently locked
    if (Get.isRegistered<MatchDetailsController>() && Get.find<MatchDetailsController>().isLock.value) {
      return;
    }

    videoController = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        isInitialized.value = true;
        videoController?.play();
        isPlaying.value = true;

        // If it's a highlight, stop after 10 seconds (Auto-play preview)
        if (isHighlight) {
          Future.delayed(const Duration(seconds: 5), () {
            if (videoController != null && videoController!.value.isPlaying) {
              videoController?.pause();
              isPlaying.value = false;
              showControls.value = true; // Show controls so user can resume if they want
            }
          });
        }
      });

    // Auto hide controls after 3 sec
    ever(isPlaying, (_) {
      if (isPlaying.value) {
        Future.delayed(const Duration(seconds: 3), () {
          showControls.value = false;
        });
      }
    });
  }

  void togglePlay() {
    if (videoController == null) return;
    if (videoController!.value.isPlaying) {
      videoController!.pause();
      isPlaying.value = false;
    } else {
      videoController!.play();
      isPlaying.value = true;
    }
    showControls.value = true;
  }

  void toggleControls() {
    showControls.value = !showControls.value;
  }

  @override
  void onClose() {
    videoController?.dispose();
    super.onClose();
  }
}
