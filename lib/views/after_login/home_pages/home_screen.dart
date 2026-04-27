import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/res/app_image.dart';
import 'package:play_on_app/routes/app_routes.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/utils/custom_button.dart';
import 'package:play_on_app/view_model/after_controller/notification_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:play_on_app/model/response_model/match_model.dart' as model;

import '../../../view_model/after_controller/home_contollers/home_controller.dart';
import '../../../view_model/after_controller/plan_controller.dart';
import '../../custom_background.dart/custom_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
                                    if (value.isNotEmpty) {
                                      ctr.selectedCategory.value = "";
                                    }
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
                  Stack(
                    children: [
                      AppIconButton(
                        icon: Icons.notifications,
                        color: AppColors.warning,
                        onTap: () {
                          ctr.handleProtectedAction(() {
                            Get.toNamed(AppRoutes.notification);
                          });
                        },
                      ),
                      Obx(() {
                        final notiCtr = Get.find<NotificationController>();
                        return notiCtr.unreadCount.value > 0
                            ? Positioned(
                          right: 5,
                          top: 5,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${notiCtr.unreadCount.value}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                            : const SizedBox.shrink();
                      }),
                    ],
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
                    ctr.sportsList.length,
                        (index) => _buildTab(
                      ctr.sportsList[index],
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
                if (ctr.isLoading.value && ctr.allMatches.isEmpty && ctr.liveMatches.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ctr.fetchMatches(
                      sport: ctr.sportsList[ctr.selectedTabIndex.value],
                    );
                  },
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    children: [
                      if (ctr.isSilentLoading.value)
                        LinearProgressIndicator(
                          minHeight: 2,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      const SizedBox(height: 8),
                      // Dynamic Ad Banners
                      if (ctr.searchQuery.value.isEmpty) ...[
                        Obx(() {
                          if (ctr.isBannerLoading.value && ctr.bannerList.isEmpty) {
                            return const SizedBox(
                              height: 160,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          if (ctr.bannerList.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return CarouselSlider.builder(
                            itemCount: ctr.bannerList.length,
                            options: CarouselOptions(
                              height: 160,
                              viewportFraction: 1.0,
                              autoPlay: ctr.bannerList.length > 1,
                              autoPlayInterval: const Duration(seconds: 5),
                              enlargeCenterPage: false,
                            ),
                            itemBuilder: (context, index, realIndex) {
                              final banner = ctr.bannerList[index];
                              final imageUrl = banner.image ?? "";

                              // Handle relative URLs if necessary
                              final fullImageUrl = imageUrl.startsWith('http')
                                  ? imageUrl
                                  : "http://192.168.1.3:8000$imageUrl";

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: InkWell(
                                  onTap: () {
                                    if (banner.link != null && banner.link!.isNotEmpty) {
                                      launchUrl(Uri.parse(banner.link!));
                                    }
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.grey[900],
                                      image: imageUrl.isNotEmpty ? DecorationImage(
                                        image: NetworkImage(fullImageUrl),
                                        fit: BoxFit.cover,
                                        onError: (exception, stackTrace) {
                                          print("Error loading banner image: $exception");
                                        },
                                      ) : null,
                                    ),
                                    child: imageUrl.isEmpty
                                        ? const Center(child: Icon(Icons.image, color: Colors.white24))
                                        : null,
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                        const SizedBox(height: 16),
                      ],

                      // Live Matches Carousel
                      if (ctr.searchQuery.value.isEmpty) ...[
                        Builder(builder: (context) {
                          // Dashboard (Live/Upcoming) only filters by sport if it's a top-level sport tab.
                          // Category chips (selectedCategory) should NOT filter the dashboard sections.
                          String dashboardSport = (ctr.selectedTabIndex.value != 0
                              ? ctr.sportsList[ctr.selectedTabIndex.value]
                              : "");

                          var displayLiveMatches = ctr.filteredLiveMatches.toList();
                          if (dashboardSport.isNotEmpty) {
                            displayLiveMatches = displayLiveMatches
                                .where((m) =>
                            m.sport?.toLowerCase() ==
                                dashboardSport.toLowerCase())
                                .toList();
                          }

                          if (displayLiveMatches.isEmpty)
                            return const SizedBox.shrink();

                          return CarouselSlider.builder(
                            itemCount: displayLiveMatches.length,
                            itemBuilder: (context, index, realIndex) {
                              return _buildLiveMatchCard(
                                  displayLiveMatches[index]);
                            },
                            options: CarouselOptions(
                              height: 200,
                              enlargeCenterPage: true,
                              viewportFraction: 0.85,
                              enableInfiniteScroll:
                              displayLiveMatches.length > 1,
                              autoPlay: displayLiveMatches.length > 1,
                              autoPlayInterval: const Duration(seconds: 4),
                              autoPlayAnimationDuration:
                              const Duration(milliseconds: 800),
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
                            "Upcoming Matches",
                            style: text20(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Builder(builder: (context) {
                          String dashboardSport = (ctr.selectedTabIndex.value != 0
                              ? ctr.sportsList[ctr.selectedTabIndex.value]
                              : "");
                          var upcomingMatches = ctr.filteredMatches
                              .where((m) =>
                          m.status?.toLowerCase() == 'upcoming')
                              .toList();
                          if (dashboardSport.isNotEmpty) {
                            upcomingMatches = upcomingMatches
                                .where((m) =>
                            m.sport?.toLowerCase() ==
                                dashboardSport.toLowerCase())
                                .toList();
                          }
                          return _buildUpcomingMatch(upcomingMatches);
                        }),
                        const SizedBox(height: 16),
                      ],

                      // Category Chips - Reduced padding
                      _buildSectionHeader("Search by Category", ""),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ctr.sportsList.skip(1).map<Widget>((tab) {
                            return _buildCategoryChip(
                              tab,
                                  () {
                                searchController.clear();
                                ctr.searchQuery.value = "";
                                ctr.selectSubCategory(tab);
                              },
                              isSelected: ctr.selectedCategory.value == tab,
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Results Section (Recap/Filtered)
                      Builder(builder: (context) {
                        String currentSportFilter = ctr.selectedCategory.value.isNotEmpty
                            ? ctr.selectedCategory.value
                            : (ctr.selectedTabIndex.value != 0
                            ? ctr.sportsList[ctr.selectedTabIndex.value]
                            : "");

                        // Show "Search Results" or Sport name header
                        String headerTitle = ctr.searchQuery.value.isNotEmpty
                            ? "Search Results"
                            : (currentSportFilter.isNotEmpty ? currentSportFilter : "Recap");

                        // Filtering matches for the results section
                        var matchesToFilter = ctr.searchQuery.value.isNotEmpty
                            ? ctr.filteredMatches
                            : ctr.allMatches;

                        var finalMatches = matchesToFilter
                            .where((m) =>
                                (ctr.searchQuery.value.isNotEmpty ||
                                    m.status?.toLowerCase() == 'finished' ||
                                    m.status?.toLowerCase() == 'completed') &&
                                (currentSportFilter.isEmpty ||
                                    m.sport?.toLowerCase() ==
                                        currentSportFilter.toLowerCase()))
                            .toList();

                        // If on Home and no specific category selected, show sport-wise sections
                        if (ctr.selectedTabIndex.value == 0 &&
                            ctr.selectedCategory.value.isEmpty &&
                            ctr.searchQuery.value.isEmpty) {
                          return Column(
                            children: ctr.sportsList.skip(1).map((sport) {
                              var sportMatches = ctr.allMatches
                                  .where((m) =>
                              (m.status?.toLowerCase() == 'finished' ||
                                  m.status?.toLowerCase() == 'completed') &&
                                  m.sport?.toLowerCase() == sport.toLowerCase())
                                  .toList();

                              if (sportMatches.isEmpty) return const SizedBox.shrink();

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionHeader(sport, "See all",
                                      onActionTap: () {
                                        int index = ctr.sportsList.indexOf(sport);
                                        if (index != -1) {
                                          ctr.changeTab(index);
                                        }
                                      }),
                                  const SizedBox(height: 8),
                                  _buildRecapMatchList(matches: sportMatches),
                                  const SizedBox(height: 16),
                                ],
                              );
                            }).toList(),
                          );
                        }

                        // Otherwise show a grid of results
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 12, bottom: 8),
                              child: Text(
                                headerTitle,
                                style: text24(fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (finalMatches.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 40),
                                child: Center(
                                    child: Text(
                                        ctr.searchQuery.value.isNotEmpty
                                            ? "No matches found"
                                            : "No completed matches found",
                                        style: text14(color: AppColors.white70))),
                              )
                            else
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.85,
                                ),
                                itemCount: finalMatches.length,
                                itemBuilder: (context, index) {
                                  return _buildRecapGridItem(finalMatches[index]);
                                },
                              ),
                          ],
                        );
                      }),

                      const SizedBox(height: 80),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveMatchCard(model.Match match) {
    return Obx(() {
      final canWatch = Get.find<PlanController>().canWatchMatch(match);
      return GestureDetector(
        onTap: () {
          if (canWatch) {
            Get.toNamed(AppRoutes.matchDetails, arguments: match);
          } else {
            ctr.handleProtectedAction(() {
              Get.toNamed(AppRoutes.matchDetails, arguments: match);
            });
          }
        },
        child: Container(
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
                color: Colors.black.withValues(alpha: 0.3),
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
                    if (!canWatch)
                      const Icon(Icons.lock, color: AppColors.white70, size: 18),
                    const SizedBox(width: 8),
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
                CustomElevatedIconButton(
                  height: 40,
                  backgroundColor: canWatch ? AppColors.success : AppColors.primary,
                  text: canWatch ? "Watch Now" : "Unlock to Watch",
                  icon: canWatch ? Icons.play_arrow : Icons.lock_outline,
                  onPressed: () {
                    if (canWatch) {
                      Get.toNamed(AppRoutes.matchDetails, arguments: match);
                    } else {
                      ctr.handleProtectedAction(() {
                        Get.toNamed(AppRoutes.matchDetails, arguments: match);
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
    });
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

  Widget _buildSectionHeader(String title, String action, {VoidCallback? onActionTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12), // Reduced from 16
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: text20(fontWeight: FontWeight.bold)),
          if (action.isNotEmpty)
            GestureDetector(
              onTap: onActionTap,
              child: Text(
                action,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
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
          return Obx(() {
            final canWatch = Get.find<PlanController>().canWatchMatch(match);
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
                      child: Stack(
                        children: [
                          Container(
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
                          if (!canWatch)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.lock, color: Colors.white, size: 16),
                              ),
                            ),
                        ],
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
          });
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
                        borderRadius: BorderRadius.circular(12),
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

  Widget _buildRecapMatchList({required List<model.Match> matches}) {
    return SizedBox(
      height: 180, // Increased height slightly to accommodate text
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: matches.length,
        itemBuilder: (context, index) {
          final match = matches[index];
          return GestureDetector(
            onTap: () {
              ctr.handleProtectedAction(() {
                Get.toNamed(AppRoutes.recapMatch, arguments: match);
              });
            },
            child: Container(
              width: 180,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: match.thumbnail != null && match.thumbnail!.isNotEmpty
                                  ? NetworkImage(match.thumbnail!)
                                  : const AssetImage('assets/auth/cri.png') as ImageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.play_arrow, color: Colors.white, size: 30),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      match.title ?? "${match.teamA} vs ${match.teamB}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text13(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    match.tournament ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text11(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecapGridItem(model.Match match) {
    bool isCompleted = match.status?.toLowerCase() == 'finished' ||
        match.status?.toLowerCase() == 'completed';

    return GestureDetector(
      onTap: () {
        ctr.handleProtectedAction(() {
          if (isCompleted) {
            Get.toNamed(AppRoutes.recapMatch, arguments: match);
          } else {
            Get.toNamed(AppRoutes.matchDetails, arguments: match);
          }
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: match.thumbnail != null && match.thumbnail!.isNotEmpty
                          ? NetworkImage(match.thumbnail!)
                          : const AssetImage('assets/auth/cri.png') as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (match.status?.toLowerCase() != 'upcoming')
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow, color: Colors.white, size: 24),
                    ),
                  ),
                if (match.status?.toLowerCase() == 'live')
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text("LIVE", style: text12(fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              match.title ?? "${match.teamA} vs ${match.teamB}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text13(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            match.tournament ?? "",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text11(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, VoidCallback onTap, {bool isSelected = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.secPrimary.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.white24,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: text14(
            color: isSelected ? Colors.white : AppColors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
