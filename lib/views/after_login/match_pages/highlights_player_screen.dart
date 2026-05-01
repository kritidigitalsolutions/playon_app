import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/view_model/after_controller/match_controller/match_controller.dart';
import 'package:play_on_app/views/after_login/match_pages/full_video_play_screen.dart';
import 'package:play_on_app/utils/custom_button.dart';
import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';
import 'package:play_on_app/model/response_model/match_model.dart' as model;
import 'package:play_on_app/model/response_model/star_player_model.dart' as star_model;
import 'package:play_on_app/view_model/after_controller/player_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../view_model/after_controller/plan_controller.dart';
import 'package:video_player/video_player.dart';

class HighlightsPlayerScreen extends StatefulWidget {
  const HighlightsPlayerScreen({super.key});

  @override
  State<HighlightsPlayerScreen> createState() => _HighlightsPlayerScreenState();
}

class _HighlightsPlayerScreenState extends State<HighlightsPlayerScreen> {
  final videoControllerX = Get.put(VideoControllerX());
  final MatchDetailsController matchDetailsController = Get.put(MatchDetailsController());
  final PlayerController playerController = Get.put(PlayerController());
  final PlanController planController = Get.find<PlanController>();

  late star_model.StarPlayer player;

  @override
  void initState() {
    super.initState();

    /// ✅ Get only star player
    player = Get.arguments as star_model.StarPlayer;

    videoControllerX.starPlayer.value = player;
    matchDetailsController.starPlayer.value = player;

    if (player.videoUrl != null) {
      videoControllerX.initializeVideo(player.videoUrl!, isHighlight: true);
    }
  }

  // Remove the local _checkHighlightAccess as it's now handled by matchDetailsController
  // void _checkHighlightAccess() { ... }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWithOneLight(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// 🔙 Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                    Expanded(
                      child: Text(
                        player.playerName ?? "Player Highlights",
                        style: text18(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    /// 🔗 Share
                    IconButton(
                      onPressed: () {
                        final text =
                            "${player.playerName} Highlights 🔥\n${player.videoUrl}";
                        Get.snackbar("Share", text);
                        // Use share_plus in real
                      },
                      icon: const Icon(Icons.share, color: Colors.white),
                    ),
                  ],
                ),
              ),

              /// 🎬 Video Player
              _buildVideoPlayer(),

              /// 📄 Info Section
              Expanded(
                child: SingleChildScrollView(
                  child: _buildPlayerInfo(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🎬 VIDEO PLAYER
  Widget _buildVideoPlayer() {
    return GestureDetector(
      onTap: videoControllerX.toggleControls,
      child: Container(
        height: 220,
        width: double.infinity,
        color: Colors.black,
        child: Stack(
          children: [
            /// 🎥 VIDEO (Only show if unlocked)
            Obx(() {
              if (matchDetailsController.isLock.value) {
                return Container(
                  color: Colors.black,
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      size: 80,
                      color: Colors.white38,
                    ),
                  ),
                );
              }

              if (videoControllerX.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!videoControllerX.isInitialized.value ||
                  videoControllerX.videoController == null) {
                return const Center(
                  child: Text(
                    "No video found",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              return AspectRatio(
                aspectRatio:
                videoControllerX.videoController!.value.aspectRatio,
                child: VideoPlayer(videoControllerX.videoController!),
              );
            }),

            /// 🔒 LOCK OVERLAY
            Obx(() {
              if (matchDetailsController.isLock.value) {
                return Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.88),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lock_rounded,
                          size: 75,
                          color: Colors.white70,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Unlock Now",
                          style: text20(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Buy plan to watch highlight",
                          style: text15(color: Colors.white70),
                        ),
                        const SizedBox(height: 24),

                        CustomElevatedIconButton(
                          height: 30,
                          iconSize: 18,
                          text: "Watch Now",
                          icon: Icons.play_arrow_rounded,
                          onPressed: () {
                            Get.toNamed(AppRoutes.accessPlan, arguments: player);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox();
            }),

            /// ▶ Controls
            Obx(() {
              if (matchDetailsController.isLock.value || !videoControllerX.showControls.value) {
                return const SizedBox();
              }

              return Stack(
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: videoControllerX.togglePlay,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          videoControllerX.isPlaying.value
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                    ),
                  ),

                  /// Progress
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: VideoProgressIndicator(
                      videoControllerX.videoController!,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: AppColors.primary,
                        backgroundColor: Colors.white24,
                        bufferedColor: Colors.white38,
                      ),
                    ),
                  ),

                  /// Fullscreen
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: GestureDetector(
                      onTap: () {
                        Get.to(() => FullScreenVideoPage(
                          controller: videoControllerX.videoController!,
                        ));
                      },
                      child:
                      const Icon(Icons.fullscreen, color: Colors.white),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 👤 PLAYER INFO UI
  Widget _buildPlayerInfo() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// 🔥 Player Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (player.playerId?.sId != null) {
                      playerController
                          .navigateToPlayerDetail(player.playerId!.sId!);
                    }
                  },
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: player.playerId?.image != null
                        ? NetworkImage(player.playerId!.image!)
                        : (player.thumbnail != null
                            ? NetworkImage(player.thumbnail!)
                            : null),
                    child: (player.playerId?.image == null &&
                            player.thumbnail == null)
                        ? const Icon(Icons.person)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.playerName ?? "",
                        style: text18(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        player.team ?? player.sportId?.name ?? "",
                        style: text14(color: AppColors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// 🎯 Title
          Text(
            player.title ?? "",
            style: text18(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 10),

          /// 📝 Description
          Text(
            "Watch top moments of ${player.playerName}. Enjoy powerful performance and match highlights.",
            style: text14(color: AppColors.white70),
          ),

          const SizedBox(height: 20),

          /// 🏷 Tags
          Row(
            children: [
              _chip(player.sportId?.name ?? "Sport"),
              const SizedBox(width: 10),
              Obx(() {
                // Explicitly access observables to ensure proper tracking
                final _ = planController.hasAccess.value; 
                final __ = planController.mySubscription.value;

                final isPremium = player.isPremium == true;
                final hasAccess = !isPremium || planController.canWatchHighlight(player);

                return _chip(isPremium ? (hasAccess ? "Premium ✅" : "Premium 🔒") : "Free Content");
              }),
            ],
          ),

          const SizedBox(height: 30),

          /// 👤 Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (player.playerId?.sId != null) {
                  playerController
                      .navigateToPlayerDetail(player.playerId!.sId!);
                }
              },
              icon: const Icon(Icons.person_outline),
              label: const Text("View Full Profile"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: text12(color: Colors.white)),
    );
  }
}
