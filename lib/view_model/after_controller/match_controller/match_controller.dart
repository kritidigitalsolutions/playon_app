import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/repo/match_repository.dart';
import 'package:video_player/video_player.dart';
import 'package:play_on_app/model/response_model/match_model.dart' as model;
import 'package:play_on_app/view_model/after_controller/plan_controller.dart';

class MatchDetailsController extends GetxController {
  final match = Rxn<model.Match>();
  var isLive = false.obs;
  var remainingTime = "".obs;
  var isReminderOn = false.obs;
  var isLock = true.obs;

  final MatchRepository _repository = MatchRepository();
  final planController = Get.put(PlanController());

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    
    if (Get.arguments is model.Match) {
      match.value = Get.arguments;
      _initializeMatchStatus();
      
      // Re-check access whenever plan status changes
      ever(planController.hasAccess, (_) => checkAccess());
      ever(planController.mySubscription, (_) => checkAccess());
      checkAccess();
    }
  }

  void checkAccess() {
    if (match.value == null) return;
    
    // Check if user has overall access or has purchased this specific match/series/team
    isLock.value = !planController.canWatchMatch(match.value);
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

  void toggleReminder() {
    isReminderOn.value = !isReminderOn.value;
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
    super.onClose();
  }
}

class VideoControllerX extends GetxController {
  final _matchRepo = MatchRepository();
  VideoPlayerController? videoController;

  final match = Rxn<model.Match>();
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
    }
  }

  Future<void> fetchMatchDetails(String matchId) async {
    isLoading.value = true;
    try {
      final response = await _matchRepo.watchMatch(matchId);
      matchData.value = model.WatchMatchResponse.fromJson(response);
      
      // Update match if API returns more detailed info
      if (matchData.value?.match != null) {
        match.value = matchData.value!.match;
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

  void initializeVideo(String url) {
    videoController = VideoPlayerController.network(url)
      ?..initialize().then((_) {
        isInitialized.value = true;
        videoController?.play();
        isPlaying.value = true;
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
