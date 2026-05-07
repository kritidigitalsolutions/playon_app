import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/view_model/after_controller/home_contollers/home_controller.dart';
import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';
import 'package:play_on_app/model/response_model/series_model.dart';
import 'package:play_on_app/routes/app_routes.dart';

class SeriesListScreen extends StatelessWidget {
  const SeriesListScreen({super.key});

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
                  "All Series",
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
                  if (controller.isSeriesLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final selectedSport = controller.selectedTabIndex.value == 0 
                      ? "" 
                      : controller.sportsList[controller.selectedTabIndex.value].toLowerCase();

                  final filteredSeries = controller.seriesList.where((s) {
                    return selectedSport.isEmpty || s.sport?.toLowerCase() == selectedSport;
                  }).toList();

                  if (filteredSeries.isEmpty) {
                    return Center(child: Text("No series available", style: text14(color: Colors.white70)));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredSeries.length,
                    itemBuilder: (context, index) {
                      final series = filteredSeries[index];
                      return _buildSeriesCard(series);
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
    return GestureDetector(
      onTap: () {
        // Handle series click - maybe show matches in this series
        if (series.fullMatches != null && series.fullMatches!.isNotEmpty) {
           Get.toNamed(AppRoutes.seeAllMatches, arguments: {
            'title': series.title ?? 'Series Matches',
            'matches': series.fullMatches,
          });
        }
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
            if (series.banner != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  series.banner!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 150,
                    color: Colors.grey.withOpacity(0.2),
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
                      if (series.isPremium == true)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "PREMIUM",
                            style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${series.sport?.toUpperCase()} • ${series.tourCountry ?? 'Global'}",
                    style: text13(color: AppColors.white60),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    series.description ?? "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text12(color: Colors.white70),
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
