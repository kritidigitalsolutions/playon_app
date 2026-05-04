import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/view_model/after_controller/home_contollers/home_controller.dart';
import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';
import 'package:play_on_app/model/response_model/match_model.dart' as model;
import 'package:play_on_app/routes/app_routes.dart';

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
                          color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.1),
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
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final selectedSport = controller.selectedTabIndex.value == 0 
                      ? "" 
                      : controller.sportsList[controller.selectedTabIndex.value].toLowerCase();

                  // We consider highlights for completed matches or matches that have highlight data
                  final highlightMatches = controller.allMatches.where((m) {
                    final matchesSport = selectedSport.isEmpty || m.sport?.toLowerCase() == selectedSport;
                    final isCompleted = m.status?.toLowerCase() == 'completed';
                    return matchesSport && isCompleted;
                  }).toList();

                  if (highlightMatches.isEmpty) {
                    return Center(child: Text("No highlights available", style: text14(color: Colors.white70)));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: highlightMatches.length,
                    itemBuilder: (context, index) {
                      final match = highlightMatches[index];
                      return _buildHighlightCard(match);
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

  Widget _buildHighlightCard(model.Match match) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.matchPlay, arguments: match, parameters: {'mode': 'highlight'});
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    match.thumbnail ?? 'https://via.placeholder.com/400x225',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      color: Colors.grey.withOpacity(0.2),
                      child: const Icon(Icons.play_circle_outline, color: Colors.white24, size: 50),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow, color: Colors.white, size: 30),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "Highlights",
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
                    match.title ?? "${match.teamA} vs ${match.teamB}",
                    style: text16(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (match.seriesId != null)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          height: 20,
                          width: 20,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: Image.network(
                              Get.find<HomeController>().getSeriesLogo(match.seriesId),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.emoji_events,
                                size: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      Expanded(
                        child: Text(
                          "${Get.find<HomeController>().getSeriesName(match.seriesId) ?? match.tournament} • ${match.sport?.toUpperCase()}",
                          style: text13(color: AppColors.white60),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
  }
}
