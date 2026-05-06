import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/routes/app_routes.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/utils/custom_button.dart';
import 'package:play_on_app/view_model/after_controller/match_controller/match_controller.dart';
import 'package:play_on_app/views/after_login/match_pages/full_video_play_screen.dart';
import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';
import 'package:play_on_app/model/response_model/match_model.dart' as model;
import 'package:video_player/video_player.dart';

import '../../../view_model/after_controller/home_contollers/home_controller.dart';

class RecapMatchScreen extends StatefulWidget {
  const RecapMatchScreen({super.key});

  @override
  State<RecapMatchScreen> createState() => _RecapMatchScreenState();
}

class _RecapMatchScreenState extends State<RecapMatchScreen> {
  final videoControllerX = Get.put(VideoControllerX());
  final MatchDetailsController controller = Get.put(MatchDetailsController());
  final HomeController homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
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

                // Comments Section
                _buildCommentsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Comments",
                style: text18(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Obx(() => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${controller.comments.length}",
                      style: text12(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 16),

          // Add Comment Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.commentController,
                    style: text14(),
                    decoration: InputDecoration(
                      hintText: "Add a comment...",
                      hintStyle: text14(color: AppColors.white.withValues(alpha: 0.4)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: controller.addComment,
                  icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Comments List
          Obx(() {
            if (controller.isCommentsLoading.value) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ));
            }

            if (controller.comments.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    "No comments yet. Be the first to comment!",
                    style: text14(color: AppColors.white.withValues(alpha: 0.5)),
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.comments.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final comment = controller.comments[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: comment.userImage ?? "",
                          fit: BoxFit.cover,
                          width: 36,
                          height: 36,
                          placeholder: (context, url) => Center(
                            child: Text(
                              comment.userName?[0].toUpperCase() ?? "U",
                              style: text14(fontWeight: FontWeight.bold),
                            ),
                          ),
                          errorWidget: (context, url, error) => Center(
                            child: Text(
                              comment.userName?[0].toUpperCase() ?? "U",
                              style: text14(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                comment.userName ?? "User",
                                style: text14(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatDate(comment.createdAt),
                                style: text10(color: AppColors.white.withValues(alpha: 0.4)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            comment.comment ?? "",
                            style: text13(color: AppColors.white.withValues(alpha: 0.8)),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          }),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "";
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat("d, MMM, yyyy 'and' HH:mm").format(date);
    } catch (e) {
      return "";
    }
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
      if (match == null) return const SizedBox();

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Team A vs Team B
            Text(
              "${match.teamA ?? ""} vs ${match.teamB ?? ""}",
              style: text20(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Description
            if (match.description != null && match.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  match.description!,
                  style: text14(color: AppColors.white70),
                ),
              ),

            // Series and Watchlist Button
            Row(
              children: [
                if (match.seriesId != null)
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    height: 35,
                    width: 35,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.network(
                      homeController.getSeriesLogo(match.seriesId),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.emoji_events, color: AppColors.primary, size: 18),
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        homeController.getSeriesName(match.seriesId).isNotEmpty ? homeController.getSeriesName(match.seriesId) : (match.tournament ?? "Series"),
                        style: text16(fontWeight: FontWeight.bold, color: AppColors.primary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "${match.sport?.toUpperCase()} • ${match.venue ?? 'TBA'}",
                        style: text12(color: AppColors.white.withOpacity(0.5)),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Logo and Score section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.white.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  // Team A
                  Expanded(
                    child: Column(
                      children: [
                        _teamLogo(match.teamALogo, size: 50),
                        const SizedBox(height: 8),
                        Text(
                          match.teamA ?? "",
                          textAlign: TextAlign.center,
                          style: text12(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Score
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Text(
                          match.score ?? "vs",
                          style: text24(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        if (match.status?.toLowerCase() == 'live')
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.red.withOpacity(0.5)),
                            ),
                            child: Text("LIVE", style: text10(color: Colors.red, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                  ),

                  // Team B
                  Expanded(
                    child: Column(
                      children: [
                        _teamLogo(match.teamBLogo, size: 50),
                        const SizedBox(height: 8),
                        Text(
                          match.teamB ?? "",
                          textAlign: TextAlign.center,
                          style: text12(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _teamLogo(String? url, {double size = 48}) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipOval(
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: url != null && url.isNotEmpty
              ? Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.shield,
                    color: Colors.grey.shade400,
                    size: size * 0.5,
                  ),
                )
              : Icon(
                  Icons.shield,
                  color: Colors.grey.shade400,
                  size: size * 0.5,
                ),
        ),
      ),
    );
  }

  Widget _buildHighlights() {
    return Obx(() {
      final match = videoControllerX.match.value;
      final score = controller.scoreboardData.value;
      final stats = controller.matchStats.value;
      final performers = controller.topPerformers.value;
      final events = controller.matchEvents.value;

      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHighlightCard(
              'Match Recap',
              '${match?.teamA ?? "Team A"}: ${score?.homeScore ?? match?.score?.split('-').first.trim() ?? "0"}',
              '${match?.teamB ?? "Team B"}: ${score?.awayScore ?? match?.score?.split('-').last.trim() ?? "0"}',
              matchSummary: score?.report ?? match?.description,
            ),
            const SizedBox(height: 16),
            
            // Scoreboard Summary
            if (score != null) ...[
               _buildSectionTitle("Scoreboard"),
               _buildScoreboardSummary(score),
               const SizedBox(height: 16),
            ],

            // Stats
            if (stats != null && stats.stats != null && stats.stats!.isNotEmpty) ...[
              _buildSectionTitle("Match Stats"),
              ...stats.stats!.map((s) => _buildStatCard(s)),
              const SizedBox(height: 16),
            ],

            // Top Performers
            if (performers != null && performers.topPerformers != null) ...[
              _buildSectionTitle("Top Performers"),
              _buildPerformersSection(performers.topPerformers!),
              const SizedBox(height: 16),
            ],

            // Events
            if (events != null && events.events != null && events.events!.isNotEmpty) ...[
              _buildSectionTitle("Key Events"),
              ...events.events!.reversed.take(5).map((e) => _buildEventItem(e)),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title, style: text16(fontWeight: FontWeight.bold, color: AppColors.primary)),
    );
  }

  Widget _buildScoreboardSummary(dynamic score) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _teamInfo(score.homeTeam, score.homeLogo, score.homeScore),
          Text("VS", style: text14(fontWeight: FontWeight.bold, color: Colors.white24)),
          _teamInfo(score.awayTeam, score.awayLogo, score.awayScore),
        ],
      ),
    );
  }

  Widget _teamInfo(String? name, String? logo, String? score) {
    return Column(
      children: [
        _teamLogo(logo, size: 35),
        const SizedBox(height: 4),
        Text(name ?? "", style: text11(fontWeight: FontWeight.bold)),
        Text(score ?? "0", style: text13(color: AppColors.primary, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStatCard(dynamic stat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Inning ${stat.inningNumber}: ${stat.team}", style: text12()),
          Text("${stat.totalRuns}/${stat.totalWickets}", style: text13(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPerformersSection(dynamic top) {
    final batsman = top.batsmen?.first;
    final bowler = top.bowlers?.first;
    
    return Row(
      children: [
        if (batsman != null)
          Expanded(child: _buildSimplePerformer(batsman.name, "Runs: ${batsman.runs}")),
        if (bowler != null)
          Expanded(child: _buildSimplePerformer(bowler.name, "Wkts: ${bowler.wickets}")),
      ],
    );
  }

  Widget _buildSimplePerformer(String? name, String? stat) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(name ?? "", style: text12(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(stat ?? "", style: text11(color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _buildEventItem(dynamic e) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text("${e.overs} ov", style: text10(color: AppColors.white60)),
          const SizedBox(width: 10),
          Expanded(child: Text(e.text ?? "", style: text12())),
        ],
      ),
    );
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
}
