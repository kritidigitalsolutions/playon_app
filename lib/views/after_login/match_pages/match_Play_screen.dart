import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/routes/app_routes.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/utils/custom_button.dart';
import 'package:play_on_app/views/custom_background.dart/ad_banner_widget.dart';
import 'package:play_on_app/view_model/after_controller/match_controller/match_controller.dart';
import 'package:play_on_app/views/after_login/match_pages/full_video_play_screen.dart';
import 'package:video_player/video_player.dart';
import 'package:play_on_app/model/response_model/match_model.dart' as model;
import 'package:play_on_app/utils/hive_service/hive_service.dart';
import 'package:play_on_app/utils/share_helper.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../../view_model/after_controller/home_contollers/home_controller.dart';
import '../../custom_background.dart/custom_widget.dart';

class MatchPlayScreen extends StatefulWidget {
  const MatchPlayScreen({super.key});

  @override
  State<MatchPlayScreen> createState() => _MatchPlayScreenState();
}

class _MatchPlayScreenState extends State<MatchPlayScreen> {
  final videoControllerX = Get.put(VideoControllerX());
  final MatchDetailsController controller = Get.put(MatchDetailsController());
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    // Force authentication check for any match/highlight content
    if (!HiveService.isLogin()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
        Get.toNamed(AppRoutes.login);
        Get.snackbar(
          "Authentication Required",
          "Please login to watch matches and highlights.",
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      });
      return;
    }

    // Check if we should start in highlight mode
    if (Get.parameters['mode'] == 'highlight') {
      _selectedTabIndex = 0;
      if (videoControllerX.match.value != null) {
        videoControllerX.fetchMatchDetails(videoControllerX.match.value!.sId!, isHighlight: true);
      }
    }
  }

  void _shareMatch() {
    final match = videoControllerX.match.value;
    if (match != null) {
      final String text = 'Check out this match: ${match.teamA} vs ${match.teamB} on PlayOn!\n'
          'Tournament: ${match.tournament}\n\n'
          'Watch it here: https://playon.app/match/${match.sId}';
      ShareHelper.shareMatchWithImage(text: text, imageUrl: match.thumbnail);
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
              // Video Player Section - Fixed at the top
              _buildVideoPlayer(),

              // Content section with sticky tab bar
              Expanded(
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverToBoxAdapter(
                        child: _buildMatchInfo(),
                      ),
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: AdBannerWidget(),
                        ),
                      ),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _SliverAppBarDelegate(
                          _buildTabBar(),
                        ),
                      ),
                    ];
                  },
                  body: _buildTabContent(),
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
                return const Center(child: Text("Loading stream...", style: TextStyle(color: Colors.white)));
              }

              return AspectRatio(
                aspectRatio: videoControllerX.videoController!.value.aspectRatio,
                child: Center(
                  child: VideoPlayer(videoControllerX.videoController!),
                ),
              );
            }),

            /// 🔴 LIVE BADGE
            Obx(() {
              final match = videoControllerX.match.value;
              if (match?.status?.toLowerCase() != 'live') return const SizedBox();
              return Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "LIVE",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              );
            }),

            /// 🔒 LOCK OVERLAY
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
                        const SizedBox(height: 16),
                        Text(
                          "Unlock Now",
                          style: text20(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Buy plan to watch match",
                          style: text15(color: Colors.white70),
                        ),
                        const SizedBox(height: 24),

                        CustomElevatedIconButton(
                          height: 30,
                          iconSize: 18,
                          text: "Watch Now",
                          icon: Icons.play_arrow_rounded,
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

            /// 🎮 CONTROLS
            Obx(() {
              if (controller.isLock.value || !videoControllerX.showControls.value) {
                return const SizedBox();
              }

              return Stack(
                children: [
                  /// ▶️ CENTER PLAY BUTTON
                  Center(
                    child: GestureDetector(
                      onTap: videoControllerX.togglePlay,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          videoControllerX.isPlaying.value
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),
                  ),

                  /// ⏳ PROGRESS BAR
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

                  /// ⚙️ RIGHT SIDE BUTTONS
                  Positioned(
                    right: 10,
                    bottom: 15,
                    child: Column(
                      children: [
                        Icon(Icons.volume_up, color: Colors.white),
                        SizedBox(height: 15),
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

  Widget _buildMatchInfo() {
    return Obx(() {
      final match = videoControllerX.match.value;
      if (match == null) return const SizedBox();

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Match Title
            Text(
              "${match.teamA ?? ""} vs ${match.teamB ?? ""}",
              style: text20(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            /// 📋 Match Description
            if (match.description != null && match.description!.isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
                ),
                child: Text(
                  match.description!,
                  style: text13(color: Colors.white70),
                ),
              ),

            // Series section
            Row(
              children: [
                Obx(() {
                  final match = videoControllerX.match.value;
                  final homeController = Get.find<HomeController>();
                  final seriesLogo = homeController.getSeriesLogo(match?.seriesId);

                  return Container(
                    height: 35,
                    width: 35,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: seriesLogo.isNotEmpty
                        ? Image.network(
                            seriesLogo,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.emoji_events, color: AppColors.primary, size: 20),
                          )
                        : const Icon(Icons.emoji_events, color: AppColors.primary, size: 20),
                  );
                }),
                const SizedBox(width: 10),
                Expanded(
                  child: Obx(() {
                    final match = videoControllerX.match.value;
                    final homeController = Get.find<HomeController>();
                    final seriesName = homeController.getSeriesName(match?.seriesId);
                    
                    return Text(
                      seriesName.isNotEmpty ? seriesName : (match?.tournament ?? "Series"),
                      style: text16(color: Colors.white, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  }),
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined, color: Colors.white70, size: 22),
                  onPressed: _shareMatch,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Modern Scoreboard (Logos and Score)
            Builder(builder: (context) {
              final isCricket = match.sport?.toLowerCase() == 'cricket';
              final scores = match.score?.split('-') ?? ["0", "0"];
              final teamAScore = scores[0].trim();
              final teamBScore = scores.length > 1 ? scores[1].trim() : "0";

              return Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.white.withValues(alpha: 0.05)),
                ),
                child: Row(
                  children: [
                    // Team A
                    Expanded(
                      child: Column(
                        children: [
                          _teamLogo(match.teamALogo, size: 55),
                          const SizedBox(height: 10),
                          Text(
                            match.teamA ?? "",
                            textAlign: TextAlign.center,
                            style: text13(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (isCricket) ...[
                            const SizedBox(height: 6),
                            Text(
                              teamAScore,
                              style: text15(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Score & Status (Middle Section)
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          if (!isCricket)
                            Text(
                              match.score ?? "0 - 0",
                              style: text24(fontWeight: FontWeight.bold, color: AppColors.primary),
                            )
                          else
                            Text(
                              "VS",
                              style: text18(
                                fontWeight: FontWeight.w900,
                                color: AppColors.white.withValues(alpha: 0.15),
                              ),
                            ),
                          const SizedBox(height: 12),
                          if (match.status?.toLowerCase() == 'live')
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.red.withOpacity(0.5)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 5,
                                    height: 5,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text("LIVE",
                                      style: text10(fontWeight: FontWeight.bold, color: Colors.red)),
                                ],
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                match.status?.toUpperCase() ?? "",
                                style: text10(color: Colors.white60, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Team B
                    Expanded(
                      child: Column(
                        children: [
                          _teamLogo(match.teamBLogo, size: 55),
                          const SizedBox(height: 10),
                          Text(
                            match.teamB ?? "",
                            textAlign: TextAlign.center,
                            style: text13(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (isCricket) ...[
                            const SizedBox(height: 6),
                            Text(
                              teamBScore,
                              style: text15(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
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
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
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

  Widget _buildTabBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.20),
              width: 1.4,
            ),
          ),
          child: Row(
            children: [
              _buildTab('Highlights', 0),
              const SizedBox(width: 6),
              _buildTab('Lineup', 1),
              const SizedBox(width: 6),
              _buildTab('Scoreboard', 2),
              const SizedBox(width: 6),
              _buildTab('Comments', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: text13(
              color: isSelected ? AppColors.primary : AppColors.white60,

              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    Widget content;
    switch (_selectedTabIndex) {
      case 0:
        content = _buildHighlights();
        break;
      case 1:
        content = _buildLineup();
        break;
      case 2:
        content = _buildScoreboard();
        break;
      case 3:
        content = _buildComments();
        break;
      default:
        content = _buildHighlights();
    }
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: content,
    );
  }

  Widget _buildLineup() {
    final match = videoControllerX.match.value;
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Match Lineup',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTeamLineup(
                  match?.teamA ?? 'Team A',
                  [
                    {'name': 'Vivid Patel (C)', 'role': 'Batsman'},
                    {'name': 'Josh Butler (WK)', 'role': 'WK-Batsman'},
                    {'name': 'Kane Shawon', 'role': 'Batsman'},
                    {'name': 'Kapils Pandey', 'role': 'All-rounder'},
                    {'name': 'Shivam Shubho', 'role': 'All-rounder'},
                    {'name': 'Mark Wood', 'role': 'Bowler'},
                    {'name': 'Jofra Archer', 'role': 'Bowler'},
                    {'name': 'Adil Rashid', 'role': 'Bowler'},
                    {'name': 'Chris Woakes', 'role': 'Bowler'},
                    {'name': 'Ben Stokes', 'role': 'All-rounder'},
                    {'name': 'Sam Curran', 'role': 'All-rounder'},
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTeamLineup(
                  match?.teamB ?? 'Team B',
                  [
                    {'name': 'Quinton de Kock (WK)', 'role': 'WK-Batsman'},
                    {'name': 'Temba Bavuma (C)', 'role': 'Batsman'},
                    {'name': 'Aiden Markram', 'role': 'Batsman'},
                    {'name': 'David Miller', 'role': 'Batsman'},
                    {'name': 'Heinrich Klaasen', 'role': 'WK-Batsman'},
                    {'name': 'Kagiso Rabada', 'role': 'Bowler'},
                    {'name': 'Anrich Nortje', 'role': 'Bowler'},
                    {'name': 'Lungi Ngidi', 'role': 'Bowler'},
                    {'name': 'Tabraiz Shamsi', 'role': 'Bowler'},
                    {'name': 'Keshav Maharaj', 'role': 'Bowler'},
                    {'name': 'Marco Jansen', 'role': 'All-rounder'},
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamLineup(String teamName, List<Map<String, String>> players) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
          ),
          child: Text(
            teamName,
            style: text14(fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 12),
        ...players.map((player) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          player['name'] ?? '',
                          style: text13(color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 14.0),
                    child: Text(
                      player['role'] ?? '',
                      style: text11(color: AppColors.white60),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildHighlights() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            if (controller.isHighlightsLoading.value) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            if (controller.highlights.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    "No highlights available for this match",
                    style: text14(color: AppColors.white70),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.highlights.length,
              itemBuilder: (context, index) {
                final item = controller.highlights[index];
                return _buildMomentCard(
                  item.title ?? "Highlights",
                  "Duration: ${item.duration ?? '0:00'}",
                  item.thumbnail ?? 'https://via.placeholder.com/300x200',
                  item.duration ?? '0:00',
                  onPlay: () {
                    if (item.videoUrl != null) {
                      videoControllerX.initializeVideo(item.videoUrl!);
                    }
                  },
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHighlightCard(String title, String team1, String team2) {
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
              Text(title, style: text16(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      team1,
                      style: text14(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      team2,
                      style: text14(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Run Rate: 5.47",
                      style: text13(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "Run Rate: 5.47",
                      style: text13(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Match Situation",
                    style: text14(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "India needs 65 runs in 65 balls",
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
  // Widget _buildStatsSection() {
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: const Color(0xFF1E3A5F),
  //       borderRadius: BorderRadius.circular(12),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text(
  //           'Match Statistics',
  //           style: TextStyle(
  //             color: Colors.white,
  //             fontSize: 16,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         const SizedBox(height: 12),
  //         _buildStatRow('Fours', '25 (England)', '18 (South Africa)'),
  //         _buildStatRow('Sixes', '8 (England)', '12 (South Africa)'),
  //         _buildStatRow('Run Rate', '5.12', '4.98'),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildStatRow(String label, String value1, String value2) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 8),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(
  //           label,
  //           style: const TextStyle(color: Colors.white70, fontSize: 13),
  //         ),
  //         Text(
  //           '$value1 vs $value2',
  //           style: const TextStyle(color: Colors.white, fontSize: 13),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildCurrentPlayersSection() {
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
                'Current Players',
                style: text16(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Batter Row
              Row(
                children: [
                  Expanded(
                    child: _buildPlayerRow('Striker', 'Vivid Patel - 78 (45)'),
                  ),

                  // Non-Striker Row
                  Expanded(
                    child: _buildPlayerRow(
                      'Non Striker',
                      'Kagiso Rabada - 12 (18)',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildPlayerRow(
                      'Bowler',
                      "Mark Wood – 7.1 overs • 2 wickets",
                    ),
                  ),

                  // Non-Striker Row
                  SizedBox.shrink(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerRow(String role, String player) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          role,
          style: text13(color: AppColors.white, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 5),
        Text(
          player,
          style: text13(color: AppColors.white, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildScoreboard() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Match Scoreboard',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInningsScorecard('India Innings', '256/6 (50 Overs)', [
            {
              'name': 'Kane Shawon',
              'score': '78',
              'balls': '65',
              'fours': '9',
              'sixes': '2',
            },
            {
              'name': 'Vivid Patel',
              'score': '45',
              'balls': '38',
              'fours': '4',
              'sixes': '1',
            },
            {
              'name': 'Josh Butler',
              'score': '28',
              'balls': '24',
              'fours': '3',
              'sixes': '1',
            },
            {
              'name': 'Kapils Pandey',
              'score': '43',
              'balls': '35',
              'fours': '5',
              'sixes': '1',
            },
            {
              'name': 'Shivam Shubho',
              'score': '28',
              'balls': '22',
              'fours': '1',
              'sixes': '1',
            },
          ]),
          const SizedBox(height: 20),
          _buildInningsScorecard('South Africa Innings', '249/6 (50 Overs)', [
            {
              'name': 'Quinton de Kock',
              'score': '78',
              'balls': '60',
              'fours': '8',
              'sixes': '2',
            },
            {
              'name': 'Temba Bavuma',
              'score': '52',
              'balls': '48',
              'fours': '6',
              'sixes': '0',
            },
            {
              'name': 'Aiden Markram',
              'score': '38',
              'balls': '32',
              'fours': '5',
              'sixes': '1',
            },
            {
              'name': 'David Miller',
              'score': '35',
              'balls': '28',
              'fours': '3',
              'sixes': '2',
            },
            {
              'name': 'Heinrich Klaasen',
              'score': '33',
              'balls': '26',
              'fours': '2',
              'sixes': '1',
            },
          ]),
        ],
      ),
    );
  }

  Widget _buildInningsScorecard(
    String title,
    String total,
    List<Map<String, String>> players,
  ) {
    return Container(
      decoration: BoxDecoration(
        // color: AppColors.secPrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary, width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.secPrimary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: text15(fontWeight: FontWeight.bold)),
                Text(
                  'Total: $total',
                  style: const TextStyle(
                    color: Colors.lightBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: const [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Batsman',
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'R',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'B',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '4s',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '6s',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          ...players.map(
            (player) => _buildPlayerScoreRow(
              player['name']!,
              player['score']!,
              player['balls']!,
              player['fours']!,
              player['sixes']!,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerScoreRow(
    String name,
    String runs,
    String balls,
    String fours,
    String sixes,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF2A3F5F), width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              name,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              runs,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              balls,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              fours,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              sixes,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComments() {
    return Container(
      padding: const EdgeInsets.all(16),
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

  Widget _buildMomentCard(
    String title,
    String subtitle,
    String imageUrl,
    String duration, {
    VoidCallback? onPlay,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.085),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.20),
              width: 1.4,
            ),
          ),
          child: Row(
            children: [
              // Thumbnail with Play Icon
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Image.network(
                      imageUrl,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 72,
                          height: 72,
                          color: Colors.blueGrey.shade800,
                          child: const Icon(
                            Icons.play_circle_fill,
                            color: Colors.white70,
                            size: 36,
                          ),
                        );
                      },
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.4),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text14(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: text13(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),

              // Play Button
              AppButton(
                title: "Play Now",
                onTap: onPlay ?? () {},
                height: 25,
                textStyle: text12(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final Widget _tabBar;

  @override
  double get minExtent => 70;
  @override
  double get maxExtent => 70;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.black, // Match your app theme background
      alignment: Alignment.center,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
