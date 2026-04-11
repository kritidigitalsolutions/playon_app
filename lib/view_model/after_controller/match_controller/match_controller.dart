import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class MatchDetailsController extends GetxController {
  var isLive = false.obs;
  var remainingTime = "".obs;
  var isReminderOn = false.obs;
  var isLock = true.obs;

  late DateTime matchStartTime;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();

    // 🔥 5 sec timer
    matchStartTime = DateTime.now().add(const Duration(seconds: 5));

    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final diff = matchStartTime.difference(DateTime.now());

      if (diff.inSeconds <= 0) {
        isLive.value = true;
        remainingTime.value = "Live Now";
        timer.cancel();
      } else {
        remainingTime.value = "Starting in ${diff.inSeconds}s";
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
