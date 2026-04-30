import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/routes/app_routes.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/utils/custom_button.dart';
import 'package:play_on_app/view_model/after_controller/match_controller/match_controller.dart';
import 'package:play_on_app/view_model/after_controller/watchlist_controller.dart';
import 'package:play_on_app/views/after_login/match_pages/full_video_play_screen.dart';
import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';
import 'package:play_on_app/model/response_model/match_model.dart' as model;
import 'package:video_player/video_player.dart';

class RecapMatchScreen extends StatefulWidget {
  const RecapMatchScreen({super.key});

  @override
  State<RecapMatchScreen> createState() => _RecapMatchScreenState();
}

class _RecapMatchScreenState extends State<RecapMatchScreen> {
  final videoControllerX = Get.put(VideoControllerX());
  final MatchDetailsController controller = Get.put(MatchDetailsController());
  final WatchlistController watchlistController = Get.find<WatchlistController>();

  final RxBool isInWatchlist = false.obs;
  final RxBool isWatchlistLoading = false.obs;

  @override
  void initState() {
    super.initState();
    _checkWatchlistStatus();
    // Listen for match changes to ensure watchlist status is accurate
    ever(videoControllerX.match, (_) => _checkWatchlistStatus());
  }

  Future<void> _checkWatchlistStatus() async {
    final match = videoControllerX.match.value;
    if (match != null && match.sId != null) {
      isInWatchlist.value = await watchlistController.isBookmarked("match", match.sId!);
    }
  }

  // @override
  // void initState() {
  //   super.initState();
  //   // Video initialize hone ke baad lock status check kar sakte ho
  //   videoControllerX.videoController.addListener(_checkVideoStatus);
  // }

  // void _checkVideoStatus() {
  //   if (videoControllerX.videoController.value.isInitialized) {
  //     // Video ready hai toh lock false kar do (unlock)
  //     if (controller.isLock.value) {
  //       controller
  //           .unlockMatch(); // Aapke controller mein ye method hona chahiye
  //     }
  //   }
  // }

  // @override
  // void dispose() {
  //   videoControllerX.videoController.removeListener(_checkVideoStatus);
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWithOneLight(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Video Player Section
                _buildVideoPlayer(),

                // Match Info Section
                _buildMatchInfo(),

                // Tab Section
                _buildHighlights(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================== VIDEO PLAYER WITH LOCK LOGIC ==================
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
              if (controller.isLock.value) {
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

              if (!videoControllerX.isInitialized.value || videoControllerX.videoController == null) {
                return const Center(child: Text("Loading recap...", style: TextStyle(color: Colors.white)));
              }

              return AspectRatio(
                aspectRatio: videoControllerX.videoController!.value.aspectRatio,
                child: Center(
                  child: VideoPlayer(videoControllerX.videoController!),
                ),
              );
            }),

            /// RECAP BADGE
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.black87, AppColors.black26],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "RECAP",
                  style: text12(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            /// 🔒 LOCK OVERLAY (Main Logic)
            Obx(() {
              if (controller.isLock.value) {
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
                        const SizedBox(height: 20),
                        Text(
                          "This Recap is Locked",
                          style: text20(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Buy a plan to watch full recap",
                          style: text15(color: Colors.white70),
                        ),
                        const SizedBox(height: 30),

                        // Unlock Button
                        CustomElevatedIconButton(
                          height: 30,
                          iconSize: 18,
                          text: "Unlock Now",
                          icon: Icons.lock,
                          onPressed: () {
                            Get.toNamed(AppRoutes.accessPlan, arguments: controller.match.value);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox();
            }),

            /// 🎮 CONTROLS (Only when unlocked)
            Obx(() {
              if (controller.isLock.value ||
                  !videoControllerX.showControls.value) {
                return const SizedBox();
              }

              return Stack(
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: videoControllerX.togglePlay,
                      child: Container(
                        width: 65,
                        height: 65,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          videoControllerX.isPlaying.value
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white,
                          size: 38,
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
                          colors: VideoProgressColors(
                            playedColor: Colors.red,
                            backgroundColor: Colors.white24,
                            bufferedColor: Colors.white38,
                          ),
                        )
                      : const SizedBox(),
                  ),

                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Column(
                      children: [
                        const Icon(Icons.volume_up, color: Colors.white),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () {
                            if (videoControllerX.videoController != null) {
                              Get.to(
                                () => FullScreenVideoPage(
                                  controller: videoControllerX.videoController!,
                                ),
                              );
                            }
                          },
                          child: const Icon(
                            Icons.fullscreen,
                            color: Colors.white,
                          ),
                        ),
                      ],
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

  // ================== MATCH INFO SECTION ==================
  Widget _buildMatchInfo() {
    return Obx(() {
      final match = videoControllerX.match.value;
      if (match == null) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Loading Match Info...",
                style: text20(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${match.teamA} vs ${match.teamB}',
                        style: text20(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${match.tournament} • ${match.sport?.toUpperCase()}',
                        style: text14(color: AppColors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() => CustomElevatedIconButton(
              height: 36,
              isLoading: isWatchlistLoading.value,

              text: isInWatchlist.value ? "Saved" : "Watchlist",

              icon: isInWatchlist.value
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,

              onPressed: () async {
                final match = videoControllerX.match.value;

                if (match != null && match.sId != null) {
                  isWatchlistLoading.value = true;

                  final success = await watchlistController
                      .toggleWatchlist(match.sId!, "match");

                  if (success) {
                    // 🔥 Watchlist refresh karo
                    await watchlistController.fetchWatchlist();

                    // 🔥 LOCAL LIST se check karo (fast & correct)
                    final exists = watchlistController.watchlistItems
                        .any((e) => e.sId == match.sId);

                    isInWatchlist.value = exists;

                    Get.snackbar(
                      "Watchlist",
                      exists ? "Added to watchlist" : "Removed from watchlist",
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }

                  isWatchlistLoading.value = false;
                }
              },
            )),
          ],
        ),
      );
    });
  }

  Widget _buildHighlights() {
    return Obx(() {
      final match = videoControllerX.match.value;
      
      // If no stats are available, don't show the sections or show placeholders
      final hasStats = match?.description != null || match?.score != null;
      
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHighlightCard(
              'Match Recap',
              '${match?.teamA ?? "Team A"}: ${match?.score?.split('-').first.trim() ?? "0"}',
              '${match?.teamB ?? "Team B"}: ${match?.score?.split('-').last.trim() ?? "0"}',
              matchSummary: match?.description,
            ),
            if (hasStats) ...[
              const SizedBox(height: 16),
              _buildMatchStats(match),
            ],
            // Only show performers if we have some data or it's a major match
            const SizedBox(height: 16),
            _buildCurrentPlayersSection(match),
          ],
        ),
      );
    });
  }

  Widget _buildHighlightCard(String title, String team1, String team2, {String? matchSummary}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.white.withValues(alpha: 0.11),
                AppColors.white.withValues(alpha: 0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.white.withValues(alpha: (0.35)),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Match Highlights',
                style: text18(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(title, style: text15(fontWeight: FontWeight.w500)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      team1,
                      style: text14(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      team2,
                      style: text14(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Match Summary",
                    style: text14(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    matchSummary ?? "Brazil secured a narrow win with a decisive goal in the final minutes",
                    style: text13(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchStats(model.Match? match) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.white.withValues(alpha: 0.11),
                AppColors.white.withValues(alpha: 0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Match Stats",
                style: text18(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Full Time Score",
                style: text16(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    match?.teamA ?? "Team A",
                    style: text14(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    match?.score ?? "0 - 0",
                    style: text18(fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  Text(
                    match?.teamB ?? "Team B",
                    style: text14(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildStatRow(
                label: "Possession",
                team1: match?.teamA ?? "Team A",
                team1Value: "54%",
                team2: match?.teamB ?? "Team B",
                team2Value: "46%",
              ),
              const SizedBox(height: 20),
              _buildStatRow(
                label: "Shots on Target",
                team1: match?.teamA ?? "Team A",
                team1Value: "7",
                team2: match?.teamB ?? "Team B",
                team2Value: "5",
              ),
              const SizedBox(height: 20),
              _buildStatRow(
                label: "Total Attempts",
                team1: match?.teamA ?? "Team A",
                team1Value: "14",
                team2: match?.teamB ?? "Team B",
                team2Value: "11",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentPlayersSection(model.Match? match) {
    // If it's a real match, we might want to hide these placeholders if we don't have real data
    // For now, I'll keep them but make them slightly more generic if no data exists
    final hasPerformers = match?.tournament?.contains("World Cup") ?? false;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.18),
              width: 1.3,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Top Performers',
                style: text18(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildPlayerRow(
                      'Match Status',
                      match?.status ?? 'Completed',
                    ),
                  ),
                  Expanded(
                    child: _buildPlayerRow(
                      'Venue',
                      'International Stadium',
                    ),
                  ),
                ],
              ),
              if (hasPerformers) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildPlayerRow(
                        'Featured',
                        "High intensity match with multiple goal attempts.",
                      ),
                    ),
                  ],
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for clean stat rows
  Widget _buildStatRow({
    required String label,
    required String team1,
    required String team1Value,
    required String team2,
    required String team2Value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Team 1
            Expanded(
              flex: 5,
              child: Text(
                team1,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                team1Value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Expanded(
              flex: 1,
              child: Text(
                "|",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54),
              ),
            ),
            // Team 2
            Expanded(
              flex: 5,
              child: Text(
                team2,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                team2Value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlayerRow(String role, String player) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          role,
          style: text13(color: AppColors.white, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 5),
        Text(
          player,
          style: text13(color: AppColors.white70, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}
