import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:video_player/video_player.dart';
import 'package:get/get.dart';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:play_on_app/model/response_model/channel_model.dart' as model;
import 'package:play_on_app/res/app_colors.dart';
import 'package:video_player/video_player.dart';
import 'package:get/get.dart';

class ChannelPlayScreen extends StatefulWidget {
  const ChannelPlayScreen({super.key});

  @override
  State<ChannelPlayScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<ChannelPlayScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  model.Channel? channel;

  @override
  void initState() {
    super.initState();
    channel = Get.arguments as model.Channel?;
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final url = channel?.streamUrl ??
        "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4";

    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(url),
    );

    try {
      await _videoPlayerController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: false,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.error,
          handleColor: AppColors.redAccent,
          backgroundColor: AppColors.grey500,
          bufferedColor: AppColors.white24,
        ),
        placeholder: Container(
          color: AppColors.black87,
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.white),
          ),
        ),
        allowedScreenSleep: false,
        allowFullScreen: true,
        fullScreenByDefault: false,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              'Error loading video: $errorMessage',
              style: const TextStyle(color: AppColors.white),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint("Video initialization error: $e");
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    // Reset orientation when leaving
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video Player
            _chewieController != null &&
                    _chewieController!
                        .videoPlayerController.value.isInitialized
                ? Chewie(controller: _chewieController!)
                : const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),

            // Custom Top Bar (Back Button + Title)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (channel != null)
                      Text(
                        channel!.name ?? "Live Stream",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
