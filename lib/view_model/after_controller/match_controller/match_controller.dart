import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:play_on_app/repo/match_repository.dart';
import 'package:video_player/video_player.dart';
import 'package:play_on_app/model/response_model/match_model.dart' as model;
import 'package:play_on_app/view_model/after_controller/plan_controller.dart';
import 'package:play_on_app/data/network/notification_service.dart';

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
      
      // Check if reminder is already set in local storage
      _checkReminderStatus();

      // Re-check access whenever plan status changes
      ever(planController.hasAccess, (_) => checkAccess());
      ever(planController.mySubscription, (_) => checkAccess());
      checkAccess();
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
    videoController = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
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
