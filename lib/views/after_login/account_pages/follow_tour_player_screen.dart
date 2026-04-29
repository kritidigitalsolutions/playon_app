import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/model/response_model/series_model.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/view_model/after_controller/player_controller.dart';
import 'package:play_on_app/view_model/after_controller/series_controller.dart';
import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';
import 'dart:ui';
import 'package:play_on_app/model/response_model/player_model.dart';

import '../../../routes/app_routes.dart';

import 'package:play_on_app/view_model/after_controller/home_contollers/home_controller.dart';
import 'package:play_on_app/view_model/after_controller/plan_controller.dart';
import 'package:play_on_app/model/response_model/match_model.dart' as match_model;

import '../../../utils/custom_button.dart';

class FollowingScreen extends StatefulWidget {
  const FollowingScreen({super.key});

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  final PlayerController _playerController = Get.find<PlayerController>();
  final SeriesController _seriesController = Get.put(SeriesController());
  final PlanController _planController = Get.find<PlanController>();
  final RxSet<String> _expandedSeriesIds = <String>{}.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWithOutImg(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
                      onPressed: () => Get.back(),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Followed Series",
                      style: text20(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _buildSeriesList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeriesList() {
    return Expanded(
      child: Obx(() {
      if (_seriesController.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
      }
      
      final followedSeries = _seriesController.followedSeriesList;
      
      if (followedSeries.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events_outlined, size: 64, color: Colors.white24),
              const SizedBox(height: 16),
              Text("No followed series", style: text16(color: Colors.white38)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Get.toNamed(AppRoutes.selectTour),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text("Explore Series", style: text14(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: followedSeries.length,
        itemBuilder: (context, index) {
          return _buildSeriesCard(followedSeries[index]);
        },
      );
    }
    )
    );
  }

  Widget _buildSeriesCard(Series series) {
    return Obx(() {
      final isExpanded = _expandedSeriesIds.contains(series.sId);
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    if (isExpanded) {
                      _expandedSeriesIds.remove(series.sId);
                    } else {
                      _expandedSeriesIds.add(series.sId!);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white10,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: series.banner != null && series.banner!.isNotEmpty
                                ? Image.network(series.banner!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.emoji_events, color: Colors.amber, size: 30))
                                : const Icon(Icons.emoji_events, color: Colors.amber, size: 30),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(series.title ?? "", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text("${_formatDate(series.startDate)} - ${_formatDate(series.endDate)}", style: const TextStyle(color: Colors.white60, fontSize: 13)),
                            ],
                          ),
                        ),
                        Icon(
                          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 8),
                        Obx(() {
                          final isPurchased = _planController.hasPurchasedItem(seriesId: series.sId);
                          // if (isPurchased) {
                          //   return CustomElevatedIconButton(
                          //     height: 25,
                          //     iconSize: 12,
                          //     backgroundColor: AppColors.success,
                          //     textStyle: text11(fontWeight: FontWeight.bold),
                          //     text: "Watch",
                          //     icon: Icons.play_arrow,
                          //     onPressed: () {
                          //       // You could navigate to first match or a series detail
                          //     },
                          //   );
                          // }
                          return IconButton(
                            icon: const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 28),
                            onPressed: () => _seriesController.toggleFollowSeries(series.sId!),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                if (isExpanded) ...[
                  const Divider(color: Colors.white10, height: 1),
                  _buildExpandedContent(series),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildExpandedContent(Series series) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Matches", style: text14(fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 12),
          _buildInlineMatchesList(series),
          const SizedBox(height: 20),
          Text("Players", style: text14(fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 12),
          _buildInlinePlayersView(series),
        ],
      ),
    );
  }

  Widget _buildInlineMatchesList(Series series) {
    if (series.matches == null || series.matches!.isEmpty) {
      return const Text("No matches scheduled", style: TextStyle(color: Colors.white38, fontSize: 12));
    }
    final HomeController homeController = Get.find<HomeController>();

    return Column(
      children: series.matches!.take(3).map((match) {
        // Try to find full match data from HomeController to get thumbnail
        final fullMatchData = homeController.allMatches.firstWhereOrNull((m) => m.sId == match.sId);

        return GestureDetector(
          onTap: () {
            // Map SeriesMatch to Match model for navigation
            final matchObj = match_model.Match(
              sId: match.sId,
              title: fullMatchData?.title ?? match.matchName,
              matchDate: match.date,
              status: match.status,
              tournament: series.title,
              teamA: series.teamA,
              teamB: series.teamB,
              thumbnail: fullMatchData?.thumbnail, // Pass the actual image
              banner: fullMatchData?.banner,
              sport: fullMatchData?.sport ?? series.sport,
            );
            Get.toNamed(AppRoutes.matchDetails, arguments: matchObj);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(match.matchName ?? "", style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                      Text(_formatDateWithTime(match.date), style: const TextStyle(color: Colors.white60, fontSize: 11)),
                    ],
                  ),
                ),
                Text(
                  match.status?.toUpperCase() ?? "",
                  style: TextStyle(
                    color: match.status?.toLowerCase() == 'live' ? Colors.redAccent : Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Obx(() {
                  final isAccessible = _planController.canWatchMatch(match_model.Match(
                    sId: match.sId,
                    tournament: series.sId,
                    teamA: series.teamA,
                    teamB: series.teamB,
                  ));
                  
                  if (isAccessible) {
                    return Icon(Icons.play_circle_fill, color: AppColors.success, size: 20);
                  }
                  return Icon(Icons.lock_outline, color: Colors.white24, size: 16);
                }),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInlinePlayersView(Series series) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(series.teamA ?? "Team A", style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildInlinePlayerIdList(series.teamAPlayers),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(series.teamB ?? "Team B", style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildInlinePlayerIdList(series.teamBPlayers),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInlinePlayerIdList(List<String>? playerIds) {
    if (playerIds == null || playerIds.isEmpty) {
      return const Text("No players", style: TextStyle(color: Colors.white24, fontSize: 11));
    }
    return Column(
      children: playerIds.take(5).map((playerId) {
        final player = _playerController.allAvailablePlayers.firstWhereOrNull((p) => p.id == playerId);
        return GestureDetector(
          onTap: () {
            if (player != null) {
              Get.toNamed(AppRoutes.playerDetail, arguments: player);
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.white10,
                  backgroundImage: player?.image != null ? NetworkImage(player!.image!) : null,
                  child: player?.image == null ? const Icon(Icons.person, size: 10, color: Colors.white38) : null,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    player?.name ?? "Player",
                    style: const TextStyle(color: Colors.white60, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }


  String _formatDate(String? dateStr) {
    if (dateStr == null) return "";
    try {
      final date = DateTime.parse(dateStr);
      return "${date.day} ${_getMonth(date.month)}";
    } catch (e) {
      return "";
    }
  }

  String _formatDateWithTime(String? dateStr) {
    if (dateStr == null) return "";
    try {
      final date = DateTime.parse(dateStr);
      return "${date.day} ${_getMonth(date.month)} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "";
    }
  }

  String _getMonth(int month) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[month - 1];
  }
}
