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
                _buildTabBar(),

                // Ad Banner
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: AdBannerWidget(),
                ),

                // Content based on selected tab
                _buildTabContent(),
              ],
            ),
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
                          "This Match is Locked",
                          style: text20(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Subscribe to watch live",
                          style: text15(color: Colors.white70),
                        ),
                        const SizedBox(height: 24),

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
        padding: const EdgeInsets.all(16),
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${match.tournament} • ${match.sport?.toUpperCase()}',
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                AppIconButton(
                  icon: Icons.share,
                  onTap: () {},
                  color: AppColors.white,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTeamScore(
                    match.teamA ?? '',
                    match.score?.split('-').first ?? '0',
                    '',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTeamScore(
                    match.teamB ?? '',
                    match.score?.split('-').last ?? '0',
                    '',
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTeamScore(String team, String score, String overs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(team, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 4),
        Text(
          score,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          overs,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
      ],
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
              _buildTab('Scoreboard', 1),
              const SizedBox(width: 6),
              _buildTab('Match Moments', 2),
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
    switch (_selectedTabIndex) {
      case 0:
        return _buildHighlights();
      case 1:
        return _buildScoreboard();
      case 2:
        return _buildMatchMoments();
      default:
        return _buildHighlights();
    }
  }

  Widget _buildHighlights() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Highlights & Moments',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          _buildHighlightCard(
            'Live Match Score',
            '${controller.match.value?.teamA}: ${controller.match.value?.score?.split('-').first ?? '0'}',
            '${controller.match.value?.teamB}: ${controller.match.value?.score?.split('-').last ?? '0'}',
          ),
          const SizedBox(height: 16),
          _buildCurrentPlayersSection(),
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

  Widget _buildMatchMoments() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Match Moments',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildMomentCard(
            'Kapil Pandey 6 in the first over',
            'Bowler: G.S',
            'https://via.placeholder.com/60x60/1565c0/ffffff?text=6',
            '3:10 Video',
          ),
          _buildMomentCard(
            'Kapil Patel 6 in the final minutes',
            'Bowler: D.M',
            'https://via.placeholder.com/60x60/1565c0/ffffff?text=6',
            '4:32 Video',
          ),
          _buildMomentCard(
            'Broad leads 4 in the final minutes',
            'Bowler: G.S',
            'https://via.placeholder.com/60x60/1565c0/ffffff?text=4',
            '2:45 Video',
          ),
          _buildMomentCard(
            'Kapil Patel 6 in the final minutes',
            'Bowler: D.M',
            'https://via.placeholder.com/60x60/1565c0/ffffff?text=6',
            '3:18 Video',
          ),
          _buildMomentCard(
            'Broad leads 6 in the final minutes',
            'Bowler: G.S',
            'https://via.placeholder.com/60x60/1565c0/ffffff?text=6',
            '2:55 Video',
          ),
          _buildMomentCard(
            'Kapil Patel 6 in the final minutes',
            'Bowler: D.M',
            'https://via.placeholder.com/60x60/1565c0/ffffff?text=6',
            '4:12 Video',
          ),
        ],
      ),
    );
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
