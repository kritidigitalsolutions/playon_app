import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/view_model/after_controller/match_controller/match_controller.dart';
import 'package:play_on_app/views/after_login/match_pages/full_video_play_screen.dart';
import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';
import 'package:play_on_app/model/response_model/match_model.dart' as model;
import 'package:video_player/video_player.dart';

class HighlightsPlayerScreen extends StatefulWidget {
  const HighlightsPlayerScreen({super.key});

  @override
  State<HighlightsPlayerScreen> createState() => _HighlightsPlayerScreenState();
}

class _HighlightsPlayerScreenState extends State<HighlightsPlayerScreen> {
  final videoControllerX = Get.put(VideoControllerX());
  final MatchDetailsController controller = Get.put(MatchDetailsController());

  @override
  void initState() {
    super.initState();
    if (Get.arguments is model.Match) {
      final match = Get.arguments as model.Match;
      videoControllerX.match.value = match;
      // Fetch highlights specifically for this screen
      videoControllerX.fetchMatchDetails(match.sId!, isHighlight: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWithOneLight(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button and Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                    Text(
                      "Match Highlights",
                      style: text18(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              // Video Player Section
              _buildVideoPlayer(),

              // Match Info Section
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildMatchSummary(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return GestureDetector(
      onTap: videoControllerX.toggleControls,
      child: Container(
        height: 220,
        width: double.infinity,
        color: Colors.black,
        child: Stack(
          children: [
            Obx(() {
              if (videoControllerX.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!videoControllerX.isInitialized.value || videoControllerX.videoController == null) {
                return const Center(child: Text("No highlight video found", style: TextStyle(color: Colors.white)));
              }

              return AspectRatio(
                aspectRatio: videoControllerX.videoController!.value.aspectRatio,
                child: Center(
                  child: VideoPlayer(videoControllerX.videoController!),
                ),
              );
            }),

            // Controls
            Obx(() {
              if (!videoControllerX.showControls.value) return const SizedBox();
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
                          videoControllerX.isPlaying.value ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: videoControllerX.videoController != null
                        ? VideoProgressIndicator(
                            videoControllerX.videoController!,
                            allowScrubbing: true,
                            colors: const VideoProgressColors(
                              playedColor: AppColors.primary,
                              backgroundColor: Colors.white24,
                              bufferedColor: Colors.white38,
                            ),
                          )
                        : const SizedBox(),
                  ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: GestureDetector(
                      onTap: () {
                        if (videoControllerX.videoController != null) {
                          Get.to(() => FullScreenVideoPage(controller: videoControllerX.videoController!));
                        }
                      },
                      child: const Icon(Icons.fullscreen, color: Colors.white),
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

  Widget _buildMatchSummary() {
    return Obx(() {
      final match = videoControllerX.match.value;
      if (match == null) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${match.teamA} vs ${match.teamB}',
              style: text24(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${match.tournament} • ${match.sport?.toUpperCase()}',
              style: text14(color: AppColors.white70),
            ),
            const SizedBox(height: 20),
            
            // Match Result Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTeamInfo(match.teamA ?? "Team A", true),
                      Column(
                        children: [
                          Text(
                            match.score ?? "FT",
                            style: text20(fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                          Text("FINAL SCORE", style: text10(color: AppColors.white70)),
                        ],
                      ),
                      _buildTeamInfo(match.teamB ?? "Team B", false),
                    ],
                  ),
                  // const Divider(height: 32, color: Colors.white10),
                  // _infoRow("Toss", match.tossWinner != null ? "${match.tossWinner} won and chose to ${match.tossDecision ?? 'bat'}" : "TBD"),
                  // const SizedBox(height: 12),
                  // _infoRow("Winner", match.winner != null ? "${match.winner} won by ${match.winMargin ?? 'N/A'}" : "Completed"),
                  // const SizedBox(height: 12),
                  // _infoRow("Venue", match.venue ?? "International Stadium"),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            Text("Match Description", style: text16(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              match.description ?? "Experience the best moments from this thrilling match. Catch all the goals, wickets, and game-changing plays in this quick highlights package.",
              style: text14(color: AppColors.white70),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTeamInfo(String name, bool isLeft) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white10,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24),
          ),
          child: const Icon(Icons.shield, color: Colors.white54),
        ),
        const SizedBox(height: 8),
        Text(name, style: text14(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: text14(color: AppColors.white70)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: text14(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
