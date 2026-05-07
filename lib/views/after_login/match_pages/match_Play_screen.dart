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
import 'package:play_on_app/model/response_model/highlight_model.dart' as highlight_model;
import 'package:play_on_app/utils/hive_service/hive_service.dart';
import 'package:play_on_app/utils/share_helper.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:play_on_app/model/response_model/score_model.dart' as score_model;

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
              if (!videoControllerX.isInitialized.value || (videoControllerX.videoController == null && videoControllerX.youtubeController == null)) {
                return const Center(child: Text("Loading stream...", style: TextStyle(color: Colors.white)));
              }

              if (videoControllerX.isYoutube.value && videoControllerX.youtubeController != null) {
                return YoutubePlayer(
                  controller: videoControllerX.youtubeController!,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: Colors.red,
                  onReady: () {
                    videoControllerX.isInitialized.value = true;
                  },
                );
              }

              if (videoControllerX.videoController != null && videoControllerX.videoController!.value.isInitialized) {
                return AspectRatio(
                  aspectRatio: videoControllerX.videoController!.value.aspectRatio,
                  child: Center(
                    child: VideoPlayer(videoControllerX.videoController!),
                  ),
                );
              }

              return const Center(child: CircularProgressIndicator());
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
                    child: videoControllerX.isYoutube.value 
                      ? const SizedBox() // YouTube player has its own progress bar
                      : (videoControllerX.videoController != null 
                        ? VideoProgressIndicator(
                            videoControllerX.videoController!,
                            allowScrubbing: true,
                            colors: VideoProgressColors(
                              playedColor: Colors.red,
                              backgroundColor: Colors.white24,
                              bufferedColor: Colors.white38,
                            ),
                          )
                        : const SizedBox()),
                  ),

                  /// ⚙️ RIGHT SIDE BUTTONS
                  Positioned(
                    right: 10,
                    bottom: 15,
                    child: Column(
                      children: [
                        const Icon(Icons.volume_up, color: Colors.white),
                        const SizedBox(height: 15),
                        GestureDetector(
                          onTap: () {
                            if (videoControllerX.isYoutube.value) {
                               // YouTube player handles its own fullscreen or we can implement it
                               videoControllerX.youtubeController?.toggleFullScreenMode();
                            } else if (videoControllerX.videoController != null) {
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
      final match = controller.match.value ?? videoControllerX.match.value;
      if (match == null) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(40.0),
            child: CircularProgressIndicator(),
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Match Title - More prominent like MatchDetailScreen
            Text(
              "${match.teamA ?? ""} vs ${match.teamB ?? ""}",
              style: text24(fontWeight: FontWeight.bold),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              "${match.sport?.toUpperCase() ?? ""} • ${match.venue ?? 'TBA'}",
              style: text12(color: Colors.white54),
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
                  final seriesId = match?.seriesId;
                  final seriesLogo = homeController.getSeriesLogo(seriesId);

                  return Container(
                    height: 35,
                    width: 35,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: seriesLogo.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: seriesLogo,
                            fit: BoxFit.contain,
                            errorWidget: (context, url, error) =>
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
                      maxLines: 3,
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
            Obx(() {
              final homeController = Get.find<HomeController>();
              final liveScore = match.sId != null ? homeController.liveScores[match.sId] : null;

              final isCricket = match.sport?.toLowerCase() == 'cricket';
              
              // Use live scores if available, otherwise fall back to static score
              String teamAScore = "0";
              String teamBScore = "0";
              String mainScore = match.score ?? "0 - 0";
              String? matchReport = liveScore?.report;
              String? homeLogo = liveScore?.homeLogo ?? match.teamALogo;
              String? awayLogo = liveScore?.awayLogo ?? match.teamBLogo;
              String? homeTeam = liveScore?.homeTeam ?? match.teamA;
              String? awayTeam = liveScore?.awayTeam ?? match.teamB;

              if (liveScore != null) {
                teamAScore = liveScore.homeScore ?? "0";
                teamBScore = liveScore.awayScore ?? "0";
                mainScore = "$teamAScore - $teamBScore";
              } else {
                final scores = match.score?.split('-') ?? ["0", "0"];
                teamAScore = scores[0].trim();
                teamBScore = scores.length > 1 ? scores[1].trim() : "0";
              }

              return Column(
                children: [
                  Container(
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
                              _teamLogo(homeLogo, size: 55),
                              const SizedBox(height: 10),
                              Text(
                                homeTeam ?? "",
                                textAlign: TextAlign.center,
                                style: text13(fontWeight: FontWeight.bold),
                                maxLines: 2,
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
                                  mainScore,
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
                              _teamLogo(awayLogo, size: 55),
                              const SizedBox(height: 10),
                              Text(
                                awayTeam ?? "",
                                textAlign: TextAlign.center,
                                style: text13(fontWeight: FontWeight.bold),
                                maxLines: 2,
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
                  ),
                  if (matchReport != null && matchReport.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        matchReport,
                        textAlign: TextAlign.center,
                        style: text13(color: AppColors.primary, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ],
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
          child: (url != null && url.isNotEmpty)
              ? CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 2),
                  errorWidget: (context, url, error) => Icon(
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
    return Obx(() {
      final status = videoControllerX.match.value?.status?.toLowerCase();
      bool isLive = status == 'live';
      
      List<String> tabs = [];
      if (!isLive) tabs.add('Highlights');
      tabs.addAll(['Squads', 'Scorecard', 'Stats', 'Comments']);

      return Container(
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: tabs.asMap().entries.map((entry) {
              return _buildTab(entry.value, entry.key);
            }).toList(),
          ),
        ),
      );
    });
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: text13(
            color: isSelected ? Colors.white : AppColors.white60,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return Obx(() {
      final status = videoControllerX.match.value?.status?.toLowerCase();
      bool isLive = status == 'live';

      List<Widget> contentList = [];
      if (!isLive) contentList.add(_buildHighlights());
      contentList.addAll([
        _buildLineup(),
        _buildScoreboard(),
        _buildStats(),
        _buildComments(),
      ]);

      Widget content = contentList.length > _selectedTabIndex 
          ? contentList[_selectedTabIndex] 
          : (contentList.isNotEmpty ? contentList[0] : const SizedBox.shrink());

      return SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: content,
      );
    });
  }

  Widget _buildLineup() {
    return Obx(() {
      final playersData = controller.matchPlayers.value;
      if (playersData == null) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (playersData.squad == null || playersData.squad!.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text("Squad details not available"),
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Squads',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: playersData.squad!.map((squad) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: _buildTeamLineup(
                      squad.team ?? 'Team',
                      squad.players ?? [],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTeamLineup(String teamName, List<dynamic> players) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
          ),
          child: Text(
            teamName,
            style: text14(fontWeight: FontWeight.bold, color: AppColors.primary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
                          player.name ?? '',
                          style: text13(color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  if (player.roles != null && player.roles!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 14.0),
                    child: Text(
                      player.roles!.join(", "),
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
                  "Match Moment",
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

  Widget _buildStats() {
    return Obx(() {
      final statsData = controller.matchStats.value;
      if (statsData == null) {
        return const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()));
      }

      if (statsData.stats == null || statsData.stats!.isEmpty) {
        return const Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text("Stats not available")));
      }

      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Match Statistics',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...statsData.stats!.map((stat) => _buildStatCard(stat)),
          ],
        ),
      );
    });
  }

  Widget _buildStatCard(dynamic stat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Inning ${stat.inningNumber} - ${stat.team}", style: text15(fontWeight: FontWeight.bold, color: AppColors.primary)),
              Text("${stat.totalRuns}/${stat.totalWickets}", style: text16(fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 24, color: Colors.white10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem("Fours", stat.totalFours.toString()),
              _buildStatItem("Sixes", stat.totalSixes.toString()),
              _buildStatItem("Extras", stat.extras.toString()),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem("Wides", stat.wides.toString()),
              _buildStatItem("No Balls", stat.noBalls.toString()),
              const SizedBox(width: 60), // spacer
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: text16(fontWeight: FontWeight.bold)),
        Text(label, style: text11(color: AppColors.white60)),
      ],
    );
  }

  Widget _buildTopPerformers() {
    return Obx(() {
      final performers = controller.topPerformers.value;
      if (performers == null) {
        return const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()));
      }

      final top = performers.topPerformers;
      if (top == null || (top.batsmen == null && top.bowlers == null)) {
        return const Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text("Performers data not available")));
      }

      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (top.batsmen != null && top.batsmen!.isNotEmpty) ...[
              const Text('Top Batsmen', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...top.batsmen!.map((b) => _buildBatsmanRow(b)),
              const SizedBox(height: 24),
            ],
            if (top.bowlers != null && top.bowlers!.isNotEmpty) ...[
              const Text('Top Bowlers', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...top.bowlers!.map((b) => _buildBowlerRow(b)),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildBatsmanRow(dynamic b) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _teamLogo(b.teamLogo, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.name ?? "", style: text14(fontWeight: FontWeight.bold)),
                Text(b.team ?? "", style: text11(color: AppColors.white60)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("${b.runs} Runs", style: text14(fontWeight: FontWeight.bold, color: AppColors.primary)),
              Text("SR: ${b.strikeRate}", style: text11(color: AppColors.white60)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBowlerRow(dynamic b) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _teamLogo(b.teamLogo, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.name ?? "", style: text14(fontWeight: FontWeight.bold)),
                Text(b.team ?? "", style: text11(color: AppColors.white60)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("${b.wickets} Wkts", style: text14(fontWeight: FontWeight.bold, color: AppColors.primary)),
              Text("Eco: ${b.economy}", style: text11(color: AppColors.white60)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEvents() {
    return Obx(() {
      final eventsData = controller.matchEvents.value;
      if (eventsData == null) {
        return const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()));
      }

      if (eventsData.events == null || eventsData.events!.isEmpty) {
        return const Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text("No events recorded")));
      }

      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Match Events', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...eventsData.events!.reversed.map((e) => _buildEventItem(e)),
          ],
        ),
      );
    });
  }

  Widget _buildEventItem(dynamic e) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: _getEventColor(e.type), width: 4)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            alignment: Alignment.center,
            child: Text("${e.overs} ov", style: text11(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.type ?? "EVENT", style: text12(fontWeight: FontWeight.bold, color: _getEventColor(e.type))),
                const SizedBox(height: 2),
                Text(e.text ?? "", style: text13()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getEventColor(String? type) {
    switch (type?.toUpperCase()) {
      case 'WICKET': return Colors.red;
      case 'FOUR': return Colors.blue;
      case 'SIX': return Colors.green;
      default: return AppColors.primary;
    }
  }

  Widget _buildScoreboard() {
    return Obx(() {
      final score = controller.scoreboardData.value;
      if (score == null) {
        return const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()));
      }

      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(score.title ?? 'Match Scorecard', style: text18(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            // Score Summary Card
            _buildScoreSummaryCard(score),
            
            const SizedBox(height: 24),
            
            if (score.innings != null && score.innings!.isNotEmpty) ...[
              ...score.innings!.map((inning) => _buildInningScorecard(inning)),
            ] else ...[
              const Center(child: Text("Detailed scorecard not available")),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildScoreSummaryCard(score_model.ScoreData score) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _teamInfo(score.homeTeam, score.homeLogo, score.homeScore, score.homeInfo),
              Text("VS", style: text18(fontWeight: FontWeight.w900, color: Colors.white24)),
              _teamInfo(score.awayTeam, score.awayLogo, score.awayScore, score.awayInfo),
            ],
          ),
          if (score.report != null) ...[
            const Divider(height: 24, color: Colors.white10),
            Text(score.report!, textAlign: TextAlign.center, style: text13(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ],
        ],
      ),
    );
  }

  Widget _buildInningScorecard(score_model.Inning inning) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Inning Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Inning ${inning.inningNumber}: ${inning.team}", style: text15(fontWeight: FontWeight.bold, color: AppColors.primary)),
                if (inning.teamLogo != null) _teamLogo(inning.teamLogo, size: 24),
              ],
            ),
          ),

          // Batsmen Table
          if (inning.batsmen != null && inning.batsmen!.isNotEmpty) ...[
            _buildBatsmenHeader(),
            ...inning.batsmen!.map((b) => _buildBatsmanRowDetailed(b)),
          ],

          // Extras
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("Extras: ", style: text12(color: AppColors.white60)),
                Text("${inning.extras ?? 0} (w ${inning.wides ?? 0}, nb ${inning.noBalls ?? 0})", style: text12(fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          const Divider(height: 1, color: Colors.white10),

          // Bowlers Table
          if (inning.bowlers != null && inning.bowlers!.isNotEmpty) ...[
             _buildBowlersHeader(),
             ...inning.bowlers!.map((b) => _buildBowlerRowDetailed(b)),
          ],
          
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildBatsmenHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: AppColors.white.withValues(alpha: 0.02),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text("Batsman", style: text11(color: AppColors.white60))),
          Expanded(flex: 1, child: Text("R", textAlign: TextAlign.center, style: text11(color: AppColors.white60))),
          Expanded(flex: 1, child: Text("B", textAlign: TextAlign.center, style: text11(color: AppColors.white60))),
          Expanded(flex: 1, child: Text("4s", textAlign: TextAlign.center, style: text11(color: AppColors.white60))),
          Expanded(flex: 1, child: Text("6s", textAlign: TextAlign.center, style: text11(color: AppColors.white60))),
          Expanded(flex: 2, child: Text("SR", textAlign: TextAlign.center, style: text11(color: AppColors.white60))),
        ],
      ),
    );
  }

  Widget _buildBatsmanRowDetailed(score_model.Batsman b) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white10, width: 0.5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.name ?? "", style: text13(fontWeight: FontWeight.bold)),
                    if (b.dismissal != null)
                      Text(b.dismissal!, style: text10(color: AppColors.white60), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Expanded(flex: 1, child: Text("${b.runs ?? 0}", textAlign: TextAlign.center, style: text13(fontWeight: FontWeight.bold))),
              Expanded(flex: 1, child: Text("${b.balls ?? 0}", textAlign: TextAlign.center, style: text12())),
              Expanded(flex: 1, child: Text("${b.fours ?? 0}", textAlign: TextAlign.center, style: text12())),
              Expanded(flex: 1, child: Text("${b.sixes ?? 0}", textAlign: TextAlign.center, style: text12())),
              Expanded(flex: 2, child: Text("${b.strikeRate ?? 0}", textAlign: TextAlign.center, style: text12())),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBowlersHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: AppColors.white.withValues(alpha: 0.02),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text("Bowler", style: text11(color: AppColors.white60))),
          Expanded(flex: 1, child: Text("O", textAlign: TextAlign.center, style: text11(color: AppColors.white60))),
          Expanded(flex: 1, child: Text("M", textAlign: TextAlign.center, style: text11(color: AppColors.white60))),
          Expanded(flex: 1, child: Text("R", textAlign: TextAlign.center, style: text11(color: AppColors.white60))),
          Expanded(flex: 1, child: Text("W", textAlign: TextAlign.center, style: text11(color: AppColors.white60))),
          Expanded(flex: 2, child: Text("ECO", textAlign: TextAlign.center, style: text11(color: AppColors.white60))),
        ],
      ),
    );
  }

  Widget _buildBowlerRowDetailed(score_model.Bowler b) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white10, width: 0.5))),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text(b.name ?? "", style: text13(fontWeight: FontWeight.bold))),
          Expanded(flex: 1, child: Text("${b.overs ?? 0}", textAlign: TextAlign.center, style: text13())),
          Expanded(flex: 1, child: Text("${b.maidens ?? 0}", textAlign: TextAlign.center, style: text13())),
          Expanded(flex: 1, child: Text("${b.runs ?? 0}", textAlign: TextAlign.center, style: text13())),
          Expanded(flex: 1, child: Text("${b.wickets ?? 0}", textAlign: TextAlign.center, style: text13(fontWeight: FontWeight.bold, color: AppColors.primary))),
          Expanded(flex: 2, child: Text("${b.economy ?? 0}", textAlign: TextAlign.center, style: text13())),
        ],
      ),
    );
  }

  Widget _teamInfo(String? name, String? logo, String? score, String? info) {
    return Expanded(
      child: Column(
        children: [
          _teamLogo(logo, size: 40),
          const SizedBox(height: 8),
          Text(name ?? "", style: text12(fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(score ?? "0", style: text14(fontWeight: FontWeight.bold, color: AppColors.primary)),
          if (info != null && info.isNotEmpty)
            Text(info, style: text10(color: AppColors.white60)),
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
                              Expanded(
                                child: Text(
                                  comment.userName ?? "User",
                                  style: text14(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              /// DELETE BUTTON
                              // if (comment.userId == HiveService.userId)
                                Obx(() {
                                  final isDeleting =
                                      controller.deletingCommentId.value ==
                                          comment.sId;

                                  return GestureDetector(
                                    onTap: isDeleting
                                        ? null
                                        : () {
                                      Get.dialog(
                                        AlertDialog(
                                          backgroundColor: Colors.black,
                                          title: const Text(
                                            "Delete Comment",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          content: const Text(
                                            "Are you sure you want to delete this comment?",
                                            style: TextStyle(
                                              color: Colors.white70,
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Get.back(),
                                              child: const Text("Cancel"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Get.back();

                                                controller.deleteComment(
                                                  comment.sId ?? "",
                                                );
                                              },
                                              child: const Text(
                                                "Delete",
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    child: isDeleting
                                        ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                        : const Icon(
                                      Icons.delete_outline_rounded,
                                      color: Colors.redAccent,
                                      size: 18,
                                    ),
                                  );
                                }),

                              const SizedBox(width: 8),

                              Text(
                                _formatDate(comment.createdAt),
                                style: text10(
                                  color: AppColors.white.withValues(alpha: 0.4),
                                ),
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
            color: Colors.white.withValues(alpha: 0.085),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.20),
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
                              Colors.black.withValues(alpha: 0.4),
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
    return true;
  }
}
