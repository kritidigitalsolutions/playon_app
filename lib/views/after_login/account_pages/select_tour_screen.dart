import 'package:flutter/material.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'dart:ui';

import 'package:play_on_app/view_model/after_controller/home_contollers/home_controller.dart';
import 'package:play_on_app/routes/app_routes.dart';
import 'package:play_on_app/model/response_model/match_model.dart' as match_model;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/model/response_model/series_model.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/view_model/after_controller/player_controller.dart';
import 'package:play_on_app/view_model/after_controller/series_controller.dart';
import 'dart:ui';

import 'package:play_on_app/view_model/after_controller/home_contollers/home_controller.dart';
import 'package:play_on_app/routes/app_routes.dart';
import 'package:play_on_app/model/response_model/match_model.dart' as match_model;

import '../../custom_background.dart/custom_widget.dart';

class SelectTourScreen extends StatefulWidget {
  const SelectTourScreen({super.key});

  @override
  State<SelectTourScreen> createState() => _SelectTourScreenState();
}

class _SelectTourScreenState extends State<SelectTourScreen> {
  final SeriesController _seriesController = Get.put(SeriesController());
  final PlayerController _playerController = Get.find<PlayerController>();
  final RxSet<String> _expandedSeriesIds = <String>{}.obs;
  final TextEditingController _searchController = TextEditingController();
  final RxString _searchQuery = "".obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWithOutImg(
        child: SafeArea(
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: AppColors.white, size: 18),
                      onPressed: () => Get.back(),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: (value) => _searchQuery.value = value.toLowerCase(),
                                decoration: const InputDecoration(
                                  hintText: "Search Series",
                                  hintStyle: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 16,
                                  ),
                                  border: InputBorder.none,
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(right: 16),
                              child: Icon(
                                Icons.search,
                                color: Colors.white70,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Suggested Series Title
              const Padding(
                padding: EdgeInsets.only(left: 20, top: 10, bottom: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Suggested Series",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // Series List
              Expanded(
                child: Obx(() {
                  if (_seriesController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }

                  final filteredSeries = _seriesController.allSeries.where((series) {
                    return series.title?.toLowerCase().contains(_searchQuery.value) ?? false;
                  }).toList();

                  if (filteredSeries.isEmpty) {
                    return Center(
                      child: Text(
                        _searchQuery.isEmpty ? "No series available" : "No results found",
                        style: text16(color: Colors.white38),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredSeries.length,
                    itemBuilder: (context, index) {
                      return _buildSeriesCard(filteredSeries[index]);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeriesCard(Series series) {
    return Obx(() {
      final isExpanded = _expandedSeriesIds.contains(series.sId);
      final isFollowed = _seriesController.isSeriesFollowed(series.sId!);

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.18)),
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
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white10,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: series.banner != null && series.banner!.isNotEmpty
                                ? Image.network(series.banner!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.emoji_events, color: Colors.amber, size: 28))
                                : const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(series.title ?? "", style: text16(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text("${_formatDate(series.startDate)} - ${_formatDate(series.endDate)}", style: text12(color: Colors.white60)),
                            ],
                          ),
                        ),
                        Icon(
                          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: Colors.white70,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            isFollowed ? Icons.check_circle : Icons.add_circle_outline,
                            color: isFollowed ? const Color(0xFF4CAF50) : Colors.white70,
                            size: 28,
                          ),
                          onPressed: () => _seriesController.toggleFollowSeries(series.sId!),
                        ),
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
        final fullMatchData = homeController.allMatches.firstWhereOrNull((m) => m.sId == match.sId);

        return GestureDetector(
          onTap: () {
            final matchObj = match_model.Match(
              sId: match.sId,
              title: fullMatchData?.title ?? match.matchName,
              matchDate: match.date,
              status: match.status,
              tournament: series.title,
              teamA: series.teamA,
              teamB: series.teamB,
              thumbnail: fullMatchData?.thumbnail,
              banner: fullMatchData?.banner,
              sport: fullMatchData?.sport ?? series.sport,
            );
            Get.toNamed(AppRoutes.matchPlay, arguments: matchObj);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
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
        return Padding(
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

