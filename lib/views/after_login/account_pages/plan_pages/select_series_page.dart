import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/model/response_model/plan_model.dart';
import 'package:play_on_app/model/response_model/series_model.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/view_model/after_controller/plan_controller.dart';
import 'package:play_on_app/view_model/after_controller/series_controller.dart';
import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';

import '../../../../routes/app_routes.dart';
import '../../../custom_background.dart/custum_date.dart';

class SelectSeriesPage extends StatefulWidget {
  const SelectSeriesPage({super.key});

  @override
  State<SelectSeriesPage> createState() => _SelectSeriesPageState();
}

class _SelectSeriesPageState extends State<SelectSeriesPage> {
  final PlanController planController = Get.find<PlanController>();
  final SeriesController seriesController = Get.put(SeriesController());
  late Plan? selectedPlan;

  // Use a local RxSet for expansion state to mirror Following/Discovery UI
  final expandedSeries = <String>{}.obs;

  @override
  void initState() {
    super.initState();
    selectedPlan = Get.arguments as Plan?;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWithOutImg(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                    Text("Select Series", style: text20(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Unlock all matches for a specific series with this ${selectedPlan?.title ?? 'Pass'}.",
                  style: text14(color: AppColors.white70),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Obx(() {
                  if (seriesController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }

                  if (seriesController.allSeries.isEmpty) {
                    return Center(
                      child: Text("No series available", style: text16(color: AppColors.white70)),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: seriesController.allSeries.length,
                    itemBuilder: (context, index) {
                      final series = seriesController.allSeries[index];
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
    return Obx(() {
      final isExpanded = expandedSeries.contains(series.sId);
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isExpanded ? AppColors.primary.withValues(alpha: 0.5) : AppColors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                if (isExpanded) {
                  expandedSeries.remove(series.sId);
                } else {
                  expandedSeries.add(series.sId!);
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.emoji_events, color: AppColors.primary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(series.title ?? "", style: text16(fontWeight: FontWeight.bold), maxLines: 3, overflow: TextOverflow.ellipsis),
                              if (series.startDate != null)
                                Text(
                                  "${formatDate(series.startDate!)}"
                                      "${series.endDate != null ? ' - ${formatDate(series.endDate!)}' : ''}",
                                  style: text12(color: AppColors.white70),
                                ),
                            ],
                          ),
                        ),
                        Icon(
                          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: AppColors.white70,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(color: AppColors.white24),
                    const SizedBox(height: 8),
                    Text(series.description ?? "No description available", style: text13(color: AppColors.white70)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Total Matches: ${series.totalMatches ?? 0}", style: text12(color: AppColors.white70)),
                            const SizedBox(height: 4),
                            Text("Sport: ${series.sport?.capitalizeFirst ?? 'N/A'}", style: text12(color: AppColors.white70)),
                          ],
                        ),
                        Obx(() {
                          final isPurchased = planController.hasPurchasedItem(seriesId: series.sId);
                          return ElevatedButton(
                            onPressed: () {
                              if (isPurchased) {
                                Get.toNamed(AppRoutes.followedPage);
                              } else if (selectedPlan?.id != null && series.sId != null) {
                                planController.buyPlan(selectedPlan!.id!,
                                    seriesId: series.sId,
                                    promoCode: planController.isPromoApplied.value ? planController.appliedPromoCode.value : null);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isPurchased ? Colors.green : AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                            ),
                            child: Text(isPurchased ? "Watch Now" : "Select Series",
                                style: text12(fontWeight: FontWeight.bold, color: Colors.white)),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }
}
