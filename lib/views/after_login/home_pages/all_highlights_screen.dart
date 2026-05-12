import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:collection/collection.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/view_model/after_controller/home_contollers/home_controller.dart';
import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';
import 'package:play_on_app/views/widgets/admob_banner_widget.dart';
import 'package:play_on_app/model/response_model/highlight_model.dart' as highlight_model;
import 'package:play_on_app/model/response_model/match_model.dart' as model;
import 'package:play_on_app/model/response_model/series_model.dart' as series_model;
import 'package:play_on_app/routes/app_routes.dart';
import '../../../view_model/after_controller/plan_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../custom_background.dart/ad_banner_widget.dart';

class AllHighlightsScreen extends StatefulWidget {
  const AllHighlightsScreen({super.key});

  @override
  State<AllHighlightsScreen> createState() => _AllHighlightsScreenState();
}

class _AllHighlightsScreenState extends State<AllHighlightsScreen> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      body: BackgroundWithOneLight(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    if (controller.selectedHighlightSeries.value != null) ...[
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () {
                          controller.selectedHighlightSeries.value = null;
                          controller.fetchHighlights(); // Fetch global highlights again
                        },
                      ),
                      if (controller.selectedHighlightSeries.value!.tournamentLogo != null || controller.selectedHighlightSeries.value!.banner != null)
                        Container(
                          height: 40,
                          width: 40,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: controller.selectedHighlightSeries.value!.tournamentLogo ?? controller.selectedHighlightSeries.value!.banner!,
                              fit: BoxFit.contain,
                              errorWidget: (context, url, error) => const Icon(Icons.emoji_events, color: AppColors.primary, size: 20),
                            ),
                          ),
                        ),
                    ],
                    Expanded(
                      child: Text(
                        controller.selectedHighlightSeries.value == null ? "All Series" : (controller.selectedHighlightSeries.value!.title ?? "Highlights"),
                        style: text20(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),

              // Sport filter - Only show when no series is selected
              Obx(() => controller.selectedHighlightSeries.value == null ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: controller.sportsList.map((sport) {
                    final index = controller.sportsList.indexOf(sport);
                    final isSelected = controller.selectedTabIndex.value == index;
                    return GestureDetector(
                      onTap: () => controller.changeTab(index),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          sport,
                          style: text14(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ) : const SizedBox.shrink()),

              Expanded(
                child: Obx(() {
                  if (controller.isSeriesLoading.value || 
                      (controller.selectedHighlightSeries.value == null ? controller.isHighlightsLoading.value : controller.isSeriesHighlightsLoading.value)) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.selectedHighlightSeries.value == null) {
                    return _buildSeriesList(controller);
                  } else {
                    return _buildHighlightsList(controller);
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeriesList(HomeController controller) {
    final selectedSport = controller.selectedTabIndex.value == 0 
        ? "" 
        : controller.sportsList[controller.selectedTabIndex.value].toLowerCase();

    final filteredSeries = controller.seriesList.where((s) {
      return selectedSport.isEmpty || s.sport?.toLowerCase() == selectedSport;
    }).toList();

    if (filteredSeries.isEmpty && controller.searchQuery.value.isNotEmpty) {
      return Center(child: Text("No series found", style: text14(color: Colors.white70)));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredSeries.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const Column(
            children: [
              AdBannerWidget(position: "highlights_top"),
              SizedBox(height: 8),
              AdMobBannerWidget(position: "highlights_top"),
              SizedBox(height: 16),
            ],
          );
        }
        final series = filteredSeries[index - 1];
        return _buildSeriesCard(controller, series);
      },
    );
  }

  Widget _buildSeriesCard(HomeController controller, series_model.Series series) {
    return GestureDetector(
      onTap: () {
        controller.selectedHighlightSeries.value = series;
        if (series.sId != null) {
          controller.fetchHighlights(seriesId: series.sId);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (series.banner != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: CachedNetworkImage(
                  imageUrl: series.banner!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(
                    height: 150,
                    color: Colors.grey.withValues(alpha: 0.2),
                    child: const Icon(Icons.image, color: Colors.white24),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          series.title ?? "",
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: text16(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${series.sport?.toUpperCase()} • ${series.tourCountry ?? 'Global'}",
                    style: text13(color: AppColors.white60),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightsList(HomeController controller) {
    final highlights = controller.selectedHighlightSeries.value == null 
        ? controller.highlightList.toList() 
        : controller.seriesHighlightList.toList();

    if (highlights.isEmpty) {
      return Center(child: Text("No highlights available for this series", style: text14(color: Colors.white70)));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: highlights.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const Column(
            children: [
              AdBannerWidget(position: "highlights_top"),
              SizedBox(height: 8),
              AdMobBannerWidget(position: "highlights_top"),
              SizedBox(height: 16),
            ],
          );
        }
        final highlight = highlights[index - 1];
        return _buildHighlightCard(highlight);
      },
    );
  }

  Widget _buildHighlightCard(highlight_model.HighlightItem highlight) {
    final homeController = Get.find<HomeController>();
    
    String teamA = highlight.teamA?.name ?? highlight.matchId?.teamA ?? homeController.selectedHighlightSeries.value?.teamA ?? "";
    String teamB = highlight.teamB?.name ?? highlight.matchId?.teamB ?? homeController.selectedHighlightSeries.value?.teamB ?? "";
    String? teamALogo = highlight.teamA?.logo;
    String? teamBLogo = highlight.teamB?.logo;

    // Lookup names if they are IDs
    if (homeController.selectedHighlightSeries.value?.teams != null) {
      if (highlight.teamA == null) {
        final tA = homeController.selectedHighlightSeries.value!.teams!.firstWhereOrNull((t) => t.sId == teamA);
        if (tA != null) {
          teamA = tA.name ?? teamA;
          teamALogo ??= tA.logo;
        }
      }
      
      if (highlight.teamB == null) {
        final tB = homeController.selectedHighlightSeries.value!.teams!.firstWhereOrNull((t) => t.sId == teamB);
        if (tB != null) {
          teamB = tB.name ?? teamB;
          teamBLogo ??= tB.logo;
        }
      }
    }

    final displayTitle = (teamA.isNotEmpty && teamB.isNotEmpty) 
        ? "$teamA vs $teamB" 
        : (highlight.title ?? "Highlights");

    // Try to find the full match from HomeController to get logos/series
    final fullMatch = homeController.allMatches.firstWhereOrNull((m) => m.sId == highlight.matchId?.sId)
        ?? homeController.liveMatches.firstWhereOrNull((m) => m.sId == highlight.matchId?.sId)
        ?? homeController.seriesList.expand((s) => s.fullMatches ?? <model.Match>[]).firstWhereOrNull((m) => m.sId == highlight.matchId?.sId);
    
    // Create a match object for access checking and UI display
    final matchArg = fullMatch ?? (highlight.matchId != null ? model.Match(
      sId: highlight.matchId!.sId,
      isPremium: highlight.isPremium,
      status: highlight.matchId!.status,
      teamA: teamA,
      teamB: teamB,
      teamALogo: teamALogo,
      teamBLogo: teamBLogo,
      tournament: highlight.matchId!.tournament,
      sport: highlight.matchId!.sport,
      seriesId: highlight.seriesId?.sId,
      videoUrl: highlight.videoUrl, // Ensure video URL is passed
      thumbnail: highlight.thumbnail,
      title: highlight.title,
    ) : (highlight.seriesId != null ? model.Match(
      sId: highlight.sId, // Use highlight ID
      isPremium: highlight.isPremium,
      seriesId: highlight.seriesId!.sId,
      tournament: highlight.seriesId!.title,
      sport: highlight.seriesId!.sport,
      teamA: teamA.isNotEmpty ? teamA : highlight.seriesId!.title, // Fallback title
      teamB: teamB.isNotEmpty ? teamB : "Highlights",
      teamALogo: teamALogo,
      teamBLogo: teamBLogo,
      videoUrl: highlight.videoUrl,
      thumbnail: highlight.thumbnail,
      title: highlight.title,
    ) : null));

    return Obx(() {
      final canWatch = Get.find<PlanController>().canWatchMatch(matchArg);
      return GestureDetector(
        onTap: () {
          if (matchArg != null) {
            homeController.handleProtectedAction(() {
              // Pass the Match object instead of just ID string
              Get.toNamed("${AppRoutes.matchPlay}?mode=highlight", arguments: matchArg);
            }, checkAccess: true, hasPermission: canWatch);
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: CachedNetworkImage(
                      imageUrl: highlight.thumbnail ?? '',
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(height: 180, color: Colors.white10),
                      errorWidget: (context, url, error) => Container(
                        height: 180,
                        color: Colors.grey.withValues(alpha: 0.2),
                        child: const Icon(Icons.play_circle_outline, color: Colors.white24, size: 50),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(canWatch ? Icons.play_arrow : Icons.lock_outline, color: Colors.white, size: 30),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _formatDuration(highlight.duration),
                        style: text11(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayTitle,
                      style: text16(fontWeight: FontWeight.bold),
                    ),
                    if (highlight.title != null && highlight.title != displayTitle)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          highlight.title!,
                          style: text13(color: AppColors.white60),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (matchArg?.seriesId != null) ...[
                          _seriesInfo(matchArg!.seriesId!),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _teamMiniLogo(matchArg?.teamALogo),
                              const SizedBox(width: 4),
                              Flexible(child: Text(matchArg?.teamA ?? "", style: text12(color: Colors.white70), maxLines: 2, overflow: TextOverflow.ellipsis)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: Text("vs", style: text10(color: Colors.white38)),
                              ),
                              Flexible(child: Text(matchArg?.teamB ?? "", style: text12(color: Colors.white70), maxLines: 2, overflow: TextOverflow.ellipsis)),
                              const SizedBox(width: 4),
                              _teamMiniLogo(matchArg?.teamBLogo),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  String _formatDuration(String? duration) {
    if (duration == null) return "Highlights";
    try {
      final seconds = int.parse(duration);
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
    } catch (e) {
      return duration;
    }
  }

  Widget _seriesInfo(String seriesId) {
    final homeController = Get.find<HomeController>();
    final name = homeController.getSeriesName(seriesId);
    final logo = homeController.getSeriesLogo(seriesId);

    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (logo.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: CachedNetworkImage(
                imageUrl: logo,
                height: 18,
                width: 18,
                fit: BoxFit.contain,
                errorWidget: (_, __, ___) => const Icon(Icons.emoji_events, size: 14, color: AppColors.primary),
              ),
            ),
          if (name.isNotEmpty)
            Flexible(
              child: Text(
                name, 
                style: text12(color: AppColors.primary, fontWeight: FontWeight.w500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _teamMiniLogo(String? url) {
    return Container(
      height: 20,
      width: 20,
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: ClipOval(
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: CachedNetworkImage(
            imageUrl: url ?? "",
            fit: BoxFit.contain,
            errorWidget: (_, __, ___) => const Icon(Icons.shield, size: 12, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
