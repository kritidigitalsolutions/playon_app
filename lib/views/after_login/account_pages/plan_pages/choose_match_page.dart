import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/model/response_model/match_model.dart';
import 'package:play_on_app/model/response_model/plan_model.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/res/app_image.dart';
import 'package:play_on_app/routes/app_routes.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/utils/custom_button.dart';
import 'package:play_on_app/view_model/after_controller/home_contollers/home_controller.dart';
import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';

import 'package:play_on_app/view_model/after_controller/plan_controller.dart';

class ChooseMatchPage extends StatefulWidget {
  const ChooseMatchPage({super.key});

  @override
  State<ChooseMatchPage> createState() => _ChooseMatchPageState();
}

class _ChooseMatchPageState extends State<ChooseMatchPage> {
  final HomeController homeController = Get.find<HomeController>();
  final PlanController planController = Get.find<PlanController>();
  late Plan? selectedPlan;

  @override
  void initState() {
    super.initState();
    selectedPlan = Get.arguments as Plan?;
  }

  // ... (inside buildHorizontalMatchList or buildLiveMatchCard)
  // Instead of Get.toNamed(AppRoutes.matchDetails, ...)
  // It should probably be:
  void _onMatchSelected(Match match) {
    if (selectedPlan != null) {
      planController.buyPlan(selectedPlan!.id!,
          matchId: match.sId
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWithOutImg(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    Image.asset(
                      AppImage.logo,
                      height: 60,
                      width: 120,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white24.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: AppColors.white.withValues(alpha: 0.25),
                                width: 1.2,
                              ),
                            ),
                            child: TextField(
                              onChanged: (value) => homeController.searchQuery.value = value,
                              style: text13(),
                              decoration: InputDecoration(
                                icon: const Icon(Icons.search, color: AppColors.white70, size: 20),
                                hintText: "Search Matches",
                                hintStyle: text13(color: AppColors.textSecondary),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.lock_open_rounded, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(selectedPlan?.title ?? "Match Pass Activated",
                                    style: text14(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(
                                    "You can watch only 1 match (${selectedPlan?.currency == 'INR' ? '₹' : selectedPlan?.currency ?? '₹'}${selectedPlan?.price ?? '25'}). Choose wisely.",
                                    style: text12(color: AppColors.white70)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
                            child: Text(
                                "${selectedPlan?.currency == 'INR' ? '₹' : selectedPlan?.currency ?? '₹'}${selectedPlan?.price ?? '25'}",
                                style: text12(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: Obx(() {
                  if (homeController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }

                  return ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      const SizedBox(height: 20),

                      if (homeController.filteredLiveMatches.isNotEmpty)
                        CarouselSlider.builder(
                          itemCount: homeController.filteredLiveMatches.length,
                          itemBuilder: (context, index, realIndex) {
                            return _buildLiveMatchCard(homeController.filteredLiveMatches[index]);
                          },
                          options: CarouselOptions(
                            enlargeCenterPage: true,
                            viewportFraction: 0.9,
                            enableInfiniteScroll: homeController.filteredLiveMatches.length > 1,
                            autoPlay: homeController.filteredLiveMatches.length > 1,
                            autoPlayInterval: const Duration(seconds: 3),
                          ),
                        ),
                      
                      const SizedBox(height: 28),

                      _buildSectionHeader("Upcoming Matches", "See all"),
                      const SizedBox(height: 12),
                      _buildHorizontalMatchList(matches: homeController.filteredMatches.where((m) => m.status == "upcoming").toList()),

                      const SizedBox(height: 28),

                      _buildSectionHeader("Search by Category", ""),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: homeController.sportsList.skip(1).map((tab) => _buildCategoryChip(tab)).toList(),
                        ),
                      ),

                      const SizedBox(height: 30),

                      if (homeController.searchQuery.value.isEmpty ||
                          homeController.searchQuery.value.toLowerCase() == "football")
                        Column(
                          children: [
                            _buildSectionHeader("Football", "See all"),
                            const SizedBox(height: 12),
                            _buildHorizontalMatchList(
                              matches: homeController.filteredMatches
                                  .where((m) => m.sport?.toLowerCase() == "football")
                                  .toList(),
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),

                      if (homeController.searchQuery.value.isEmpty ||
                          homeController.searchQuery.value.toLowerCase() == "cricket")
                        Column(
                          children: [
                            _buildSectionHeader("Cricket", "See all"),
                            const SizedBox(height: 12),
                            _buildHorizontalMatchList(
                              matches: homeController.filteredMatches
                                  .where((m) => m.sport?.toLowerCase() == "cricket")
                                  .toList(),
                            ),
                            const SizedBox(height: 100),
                          ],
                        ),
                      
                      if (homeController.searchQuery.value.isNotEmpty && 
                          homeController.searchQuery.value.toLowerCase() != "football" && 
                          homeController.searchQuery.value.toLowerCase() != "cricket")
                        Column(
                          children: [
                            _buildSectionHeader("Search Results", ""),
                            const SizedBox(height: 12),
                            _buildHorizontalMatchList(matches: homeController.filteredMatches),
                            const SizedBox(height: 100),
                          ],
                        ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveMatchCard(Match match) {
    return Obx(() {
      final isPurchased = planController.hasPurchasedItem(matchId: match.sId);
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF0A1F3D),
          image: DecorationImage(
            image: NetworkImage(match.banner ?? ""),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(20)),
                    child: Text("LIVE", style: text12(fontWeight: FontWeight.bold)),
                  ),
                  const Spacer(),
                  Text(match.venue ?? "", style: text13(color: AppColors.white70)),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("${match.teamA} vs ${match.teamB}", style: text18(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(match.title ?? "", style: text14(color: AppColors.white70)),
                  ],
                ),
              ),
              AppButton(
                height: 35,
                title: isPurchased ? "Watch Now" : (selectedPlan != null ? "Select Match" : "Watch Now"),
                onTap: () {
                  if (isPurchased) {
                    Get.toNamed(AppRoutes.matchDetails, arguments: match);
                  } else if (selectedPlan != null) {
                    planController.buyPlan(selectedPlan!.id!, matchId: match.sId);
                  } else {
                    Get.toNamed(AppRoutes.matchDetails, arguments: match);
                  }
                },
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSectionHeader(String title, String action) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: text20(fontWeight: FontWeight.bold)),
          if (action.isNotEmpty)
            GestureDetector(
              onTap: () {}, // Handle see all
              child: Text(action, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
            ),
        ],
      ),
    );
  }

  Widget _buildHorizontalMatchList({required List<Match> matches}) {
    if (matches.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text("No matches found", style: TextStyle(color: AppColors.white70)),
      );
    }
    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: matches.length,
        itemBuilder: (context, index) {
          final match = matches[index];
          return Obx(() {
            final isPurchased = planController.hasPurchasedItem(matchId: match.sId);
            return Container(
              width: 160,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(color: AppColors.blackCard, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      image: DecorationImage(image: NetworkImage(match.banner ?? ""), fit: BoxFit.cover),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text("${match.teamA} vs ${match.teamB}", textAlign: TextAlign.center, style: text13(), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: AppButton(
                      title: isPurchased ? "Watch Now" : (selectedPlan != null ? "Select Match" : "Watch Now"),
                      onTap: () {
                        if (isPurchased) {
                          Get.toNamed(AppRoutes.matchDetails, arguments: match);
                        } else if (selectedPlan != null) {
                          planController.buyPlan(selectedPlan!.id!, matchId: match.sId);
                        } else {
                          Get.toNamed(AppRoutes.matchDetails, arguments: match);
                        }
                      },
                      radius: 8,
                      height: 25,
                      textStyle: text12(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    return Obx(() {
      final isSelected = homeController.searchQuery.value.toLowerCase() == label.toLowerCase();
      return GestureDetector(
        onTap: () => homeController.searchQuery.value = label,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.secPrimary.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: isSelected ? AppColors.white : Colors.white24, width: isSelected ? 1.5 : 1),
          ),
          child: Text(label,
              style: text14(color: isSelected ? AppColors.white : AppColors.white70, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ),
      );
    });
  }
}
