import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:collection/collection.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/view_model/after_controller/home_contollers/home_controller.dart';
import 'package:play_on_app/views/custom_background.dart/ad_banner_widget.dart';
import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';
import 'package:play_on_app/model/response_model/highlight_model.dart' as highlight_model;
import 'package:play_on_app/model/response_model/match_model.dart' as model;
import 'package:play_on_app/routes/app_routes.dart';
import '../../../view_model/after_controller/plan_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AllHighlightsScreen extends StatelessWidget {
  const AllHighlightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      body: BackgroundWithOneLight(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "All Highlights",
                  style: text20(fontWeight: FontWeight.bold),
                ),
              ),

              // Sport filter
              Obx(() => SingleChildScrollView(
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
              )),

              const SizedBox(height: 16),

              Expanded(
                child: Obx(() {
                  if (controller.isHighlightsLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final selectedSport = controller.selectedTabIndex.value == 0 
                      ? "" 
                      : controller.sportsList[controller.selectedTabIndex.value].toLowerCase();

                  final highlights = controller.highlightList.where((h) {
                    final matchesSport = selectedSport.isEmpty || h.matchId?.sport?.toLowerCase() == selectedSport;
                    return matchesSport;
                  }).toList();

                  if (highlights.isEmpty) {
                    return Center(child: Text("No highlights available", style: text14(color: Colors.white70)));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: highlights.length,
                    itemBuilder: (context, index) {
                      final highlight = highlights[index];
                      return _buildHighlightCard(highlight);
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

  Widget _buildHighlightCard(highlight_model.HighlightItem highlight) {
    final homeController = Get.find<HomeController>();
    // Try to find the full match from HomeController to get logos/series
    final fullMatch = homeController.allMatches.firstWhereOrNull((m) => m.sId == highlight.matchId?.sId)
        ?? homeController.liveMatches.firstWhereOrNull((m) => m.sId == highlight.matchId?.sId)
        ?? homeController.seriesList.expand((s) => s.fullMatches ?? <model.Match>[]).firstWhereOrNull((m) => m.sId == highlight.matchId?.sId);
    
    // Create a match object for access checking
    final matchArg = fullMatch ?? (highlight.matchId != null ? model.Match(
      sId: highlight.matchId!.sId,
      isPremium: highlight.isPremium,
      status: highlight.matchId!.status,
      teamA: highlight.matchId!.teamA,
      teamB: highlight.matchId!.teamB,
      tournament: highlight.matchId!.tournament,
      sport: highlight.matchId!.sport,
    ) : null);

    return Obx(() {
      final canWatch = Get.find<PlanController>().canWatchMatch(matchArg);
      return GestureDetector(
        onTap: () {
          if (highlight.matchId?.sId != null) {
            // Pass the Match object instead of just ID string
            Get.toNamed("${AppRoutes.matchPlay}?mode=highlight", arguments: matchArg);
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
                        highlight.duration ?? "Highlights",
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
                      highlight.title ?? "Highlights",
                      style: text16(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (fullMatch?.seriesId != null) ...[
                          _seriesInfo(fullMatch!.seriesId!),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (fullMatch != null) ...[
                                _teamMiniLogo(fullMatch.teamALogo),
                                const SizedBox(width: 4),
                                Text(fullMatch.teamA ?? "", style: text12(color: Colors.white70)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: Text("vs", style: text10(color: Colors.white38)),
                                ),
                                Text(fullMatch.teamB ?? "", style: text12(color: Colors.white70)),
                                const SizedBox(width: 4),
                                _teamMiniLogo(fullMatch.teamBLogo),
                              ] else if (highlight.matchId != null) ...[
                                Expanded(
                                  child: Text(
                                    "${highlight.matchId!.teamA} vs ${highlight.matchId!.teamB}",
                                    style: text12(color: Colors.white70),
                                    textAlign: TextAlign.end,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
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

  Widget _seriesInfo(String seriesId) {
    final homeController = Get.find<HomeController>();
    final name = homeController.getSeriesName(seriesId);
    final logo = homeController.getSeriesLogo(seriesId);

    return Row(
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
          Text(name, style: text12(color: AppColors.primary, fontWeight: FontWeight.w500)),
      ],
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
