import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:play_on_app/model/response_model/match_model.dart' as model;

class MatchDetailsController extends GetxController {
  final match = Rxn<model.Match>();
  var isLive = false.obs;
  var remainingTime = "".obs;
  var isReminderOn = false.obs;
  var isLock = true.obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    
    if (Get.arguments is model.Match) {
      match.value = Get.arguments;
      _initializeMatchStatus();
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
      backgroundColor: Colors.green.withOpacity(0.9),
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
  late VideoPlayerController videoController;

  var isInitialized = false.obs;
  var isPlaying = false.obs;
  var showControls = true.obs;

  @override
  void onInit() {
    super.onInit();

    videoController =
        VideoPlayerController.network(
            "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
          )
          ..initialize().then((_) {
            isInitialized.value = true;
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
    if (videoController.value.isPlaying) {
      videoController.pause();
      isPlaying.value = false;
    } else {
      videoController.play();
      isPlaying.value = true;
    }
    showControls.value = true;
  }

  void toggleControls() {
    showControls.value = !showControls.value;
  }

  @override
  void onClose() {
    videoController.dispose();
    super.onClose();
  }
}
