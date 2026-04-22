import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/res/app_image.dart';
import 'package:play_on_app/routes/app_routes.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/utils/custom_button.dart';
import 'package:play_on_app/view_model/after_controller/home_contollers/home_controller.dart';
import 'package:play_on_app/model/response_model/match_model.dart' as model;

import '../../custom_background.dart/custom_widget.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController ctr = Get.find();
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = "".obs;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWithOutImg(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Bar - Reduced padding
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 4, // Reduced from 6
              ),
              child: Row(
                children: [
                  Image.asset(
                    AppImage.logo,
                    height: 50, // Reduced from 60
                    width: 100, // Reduced from 120
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(width: 4), // Reduced from 5
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12, // Reduced from 16
                            vertical: 6, // Reduced from 8
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white24.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.25),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: AppColors.white70,
                                size: 18, // Reduced from 20
                              ),
                              const SizedBox(width: 6), // Reduced from 8
                              Expanded(
                                child: TextField(
                                  controller: searchController,
                                  onChanged: (value) {
                                    ctr.searchQuery.value = value;
                                  },
                                  style: text13(color: AppColors.white),
                                  decoration: InputDecoration(
                                    hintText: "Search Matches",
                                    hintStyle:
                                        text13(color: AppColors.textSecondary),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4), // Reduced from 5
                  Obx(() => AppIconButton(
                    icon: ctr.isLogin.value ? Icons.person : Icons.login,
                    color: AppColors.white,
                    onTap: () {
                      if (ctr.isLogin.value) {
                        Get.toNamed(AppRoutes.profilePage);
                      } else {
                        ctr.handleProtectedAction(() {
                          Get.toNamed(AppRoutes.profilePage);
                        });
                      }
                    },
                  )),
                  const SizedBox(width: 4), // Reduced from 5
                  AppIconButton(
                    icon: Icons.notifications,
                    color: AppColors.warning,
                    onTap: () {
                      ctr.handleProtectedAction(() {
                        Get.toNamed(AppRoutes.notification);
                      });
                    },
                  ),
                  const SizedBox(width: 4), // Reduced from 5
                ],
              ),
            ),

            // Category Tabs - Reduced padding
            Obx(
              () => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                ), // Reduced from 16
                child: Row(
                  children: List.generate(
                    ctr.tabs.length,
                    (index) => _buildTab(
                      ctr.tabs[index],
                      index,
                      ctr.selectedTabIndex.value == index,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ), // Reduced from 5 but increased for better separation

            Expanded(
              child: Obx(() {
                if (ctr.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                return RefreshIndicator(
                  onRefresh: () async {
                    await ctr.fetchMatches(
                      sport: ctr.tabs[ctr.selectedTabIndex.value],
                    );
                  },
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    children: [
                    const SizedBox(height: 8),
                    // MacBook Pro Ad Banner
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Container(
                        height: 160,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/iPhone.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    // Live Matches Carousel
                    Builder(builder: (context) {
                      var displayLiveMatches = ctr.selectedTabIndex.value == 0
                          ? ctr.filteredLiveMatches
                          : ctr.filteredLiveMatches
                              .where((m) =>
                                  m.sport?.toLowerCase() ==
                                  ctr.tabs[ctr.selectedTabIndex.value].toLowerCase())
                              .toList();

                      if (displayLiveMatches.isEmpty) return const SizedBox.shrink();

                      return CarouselSlider.builder(
                        itemCount: displayLiveMatches.length,
                        itemBuilder: (context, index, realIndex) {
                          return _buildLiveMatchCard(displayLiveMatches[index]);
                        },
                        options: CarouselOptions(
                          height: 200,
                          enlargeCenterPage: true,
                          viewportFraction: 0.85,
                          enableInfiniteScroll: displayLiveMatches.length > 1,
                          autoPlay: displayLiveMatches.length > 1,
                          autoPlayInterval: const Duration(seconds: 4),
                          autoPlayAnimationDuration: const Duration(milliseconds: 800),
                          autoPlayCurve: Curves.fastOutSlowIn,
                          enlargeFactor: 0.25,
                          enlargeStrategy: CenterPageEnlargeStrategy.scale,
                        ),
                      );
                    }),

                    const SizedBox(height: 16),
                    // Upcoming Matches Section
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Text(
                        ctr.selectedTabIndex.value == 0
                            ? "Upcoming Matches"
                            : "${ctr.tabs[ctr.selectedTabIndex.value]} Matches",
                        style: text20(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildUpcomingMatch(ctr.filteredMatches
                        .where((m) => m.status?.toLowerCase() == 'upcoming')
                        .toList()),

                    if (ctr.selectedTabIndex.value == 0) ...[
                      const SizedBox(height: 16),
                      _buildSectionHeader("Search by Category", ""),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ctr.tabs.skip(1).map((tab) {
                            return _buildCategoryChip(tab, () {
                              int index = ctr.tabs.indexOf(tab);
                              if (index != -1) {
                                ctr.changeTab(index);
                              }
                            });
                          }).toList(),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                    Builder(builder: (context) {
                      var footballMatches = ctr.filteredMatches.where((m) => m.sport?.toLowerCase() == 'football').toList();
                      if (footballMatches.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader("Football", "See all"),
                          const SizedBox(height: 8),
                          _buildHorizontalMatchList(
                            matches: footballMatches,
                            isFootball: true,
                          ),
                        ],
                      );
                    }),

                    const SizedBox(height: 16),
                    Builder(builder: (context) {
                      var cricketMatches = ctr.filteredMatches.where((m) => m.sport?.toLowerCase() == 'cricket').toList();
                      if (cricketMatches.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader("Cricket", "See all"),
                          const SizedBox(height: 8),
                          _buildHorizontalMatchList(
                            matches: cricketMatches,
                            isFootball: false,
                          ),
                        ],
                      );
                    }),

                    const SizedBox(height: 80),
                  ],
                )
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveMatchCard(model.Match match) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF0A1F3D),
        image: DecorationImage(
          image: match.banner != null && match.banner!.isNotEmpty
              ? NetworkImage(match.banner!)
              : const AssetImage("assets/auth/cri.png") as ImageProvider,
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text("LIVE", style: text12(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  match.tournament ?? "LIVE MATCH",
                  style: text13(color: AppColors.white70),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${match.teamA} vs ${match.teamB}",
                    style: text18(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Score: ${match.score ?? '0-0'}",
                    style: text14(color: AppColors.white70),
                  ),
                ],
              ),
            ),
            AppButton(
              title: "Watch Live",
              onTap: () {
                ctr.handleProtectedAction(() {
                  Get.toNamed(AppRoutes.matchDetails, arguments: match);
                });
              },
              height: 40,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String text, int index, bool isSelected) {
    return GestureDetector(
      onTap: () {
        ctr.changeTab(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(right: 10), // Reduced from 12
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ), // Reduced padding
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.white : AppColors.transparent,
              width: 2, // Increased from 1.2 for better visibility
            ),
          ),
        ),
        child: Text(
          text,
          style: text13(
            color: isSelected ? AppColors.white : AppColors.white60,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String action) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12), // Reduced from 16
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: text20(fontWeight: FontWeight.bold)),
          if (action.isNotEmpty)
            Text(
              action,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUpcomingMatch(List<model.Match> matches) {
    if (matches.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: matches.length,
        itemBuilder: (context, index) {
          final match = matches[index];
          return GestureDetector(
            onTap: () {
              ctr.handleProtectedAction(() {
                Get.toNamed(AppRoutes.matchDetails, arguments: match);
              });
            },
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        image: DecorationImage(
                          image: match.thumbnail != null && match.thumbnail!.isNotEmpty
                              ? NetworkImage(match.thumbnail!)
                              : const AssetImage('assets/auth/cri.png') as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [AppColors.primary, AppColors.error],
                      ).createShader(bounds),
                      child: Text(
                        match.sport?.toUpperCase() ?? "SPORTS",
                        style: text14(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Text(
                    match.title ?? "Upcoming Match",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text13(
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHorizontalMatchList({
    required List<model.Match> matches,
    bool isFootball = false,
  }) {
    if (matches.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: matches.length,
        itemBuilder: (context, index) {
          final match = matches[index];
          return GestureDetector(
            onTap: () {
              ctr.handleProtectedAction(() {
                Get.toNamed(AppRoutes.matchDetails, arguments: match);
              });
            },
            child: Container(
              width: 180,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: match.thumbnail != null && match.thumbnail!.isNotEmpty
                              ? NetworkImage(match.thumbnail!)
                              : AssetImage(isFootball
                                      ? 'assets/auth/football.png'
                                      : 'assets/auth/cri.png')
                                  as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [AppColors.primary, AppColors.error],
                          ).createShader(bounds),
                          child: Text(
                            match.sport?.toUpperCase() ?? (isFootball ? "FOOTBALL" : "CRICKET"),
                            style: text14(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            match.matchDate?.split('T')[0] ?? "TBA",
                            maxLines: 1,
                            style: text13(
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    match.title ?? "${match.teamA} vs ${match.teamB}",
                    overflow: TextOverflow.ellipsis,
                    style: text13(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ), // Reduced padding
        decoration: BoxDecoration(
          color: AppColors.secPrimary.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white24),
        ),
        child: Text(label, style: text14(color: AppColors.white70)),
      ),
    );
  }
}
