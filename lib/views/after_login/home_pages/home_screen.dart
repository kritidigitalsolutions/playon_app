import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
import '../../custom_background.dart/ad_banner_widget.dart';
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
                        const AdBannerWidget(),
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

                          if (upcomingMatches.isEmpty) return const SizedBox.shrink();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader(
                                "Upcoming Matches",
                                "See all",
                                onActionTap: () {
                                  Get.toNamed(
                                    AppRoutes.seeAllMatches,
                                    arguments: {
                                      'title': "Upcoming Matches",
                                      'matches': upcomingMatches,
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              _buildUpcomingMatch(upcomingMatches),
                            ],
                          );
                        }),
                        // Highlights Slider
                        Obx(() {
                          String dashboardSport = (ctr.selectedTabIndex.value != 0
                              ? ctr.sportsList[ctr.selectedTabIndex.value]
                              : "");

                          var recentlyFinished = ctr.allMatches
                              .where((m) =>
                                  m.status?.toLowerCase() == 'finished' ||
                                  m.status?.toLowerCase() == 'completed')
                              .toList();

                          if (dashboardSport.isNotEmpty) {
                            recentlyFinished = recentlyFinished
                                .where((m) =>
                                    m.sport?.toLowerCase() ==
                                    dashboardSport.toLowerCase())
                                .toList();
                          }

                          // Take top 5 recent matches for highlights slider
                          final topHighlights = recentlyFinished.take(5).toList();
                          return _buildHighlightsSlider(topHighlights);
                        }),
                        const SizedBox(height: 16),
                      ],

                      // Category Chips
                      _buildSectionHeader("Search by Category", ""),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (ctr.selectedTabIndex.value == 0 
                              ? ctr.sportsList.skip(1).toList() 
                              : [ctr.sportsList[ctr.selectedTabIndex.value]]).map<Widget>((tab) {
                            return _buildCategoryChip(
                              tab,
                                  () {
                                searchController.clear();
                                ctr.searchQuery.value = "";
                                ctr.selectSubCategory(tab);
                              },
                              isSelected: ctr.selectedCategory.value == tab || 
                                         (ctr.selectedTabIndex.value != 0 && ctr.sportsList[ctr.selectedTabIndex.value] == tab),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Results Section (Highlights/Filtered)
                      Builder(builder: (context) {
                        // Current Sport determines which sections to show
                        String topSport = ctr.selectedTabIndex.value != 0 
                            ? ctr.sportsList[ctr.selectedTabIndex.value] 
                            : "";

                        // If a specific search is active, show grid
                        if (ctr.searchQuery.value.isNotEmpty) {
                          String currentSportFilter = ctr.selectedCategory.value.isNotEmpty
                              ? ctr.selectedCategory.value
                              : topSport;

                          var matchesToFilter = ctr.filteredMatches;
                          var finalMatches = matchesToFilter
                              .where((m) =>
                                  (m.status?.toLowerCase() == 'finished' ||
                                      m.status?.toLowerCase() == 'completed') &&
                                  (currentSportFilter.isEmpty ||
                                      m.sport?.toLowerCase() ==
                                          currentSportFilter.toLowerCase()))
                              .toList();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 12, bottom: 8),
                                child: Text(
                                  currentSportFilter.isNotEmpty ? "$currentSportFilter Search Results" : "Search Results",
                                  style: text24(fontWeight: FontWeight.bold),
                                ),
                              ),
                              if (finalMatches.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 40),
                                  child: Center(
                                      child: Text("No matches found",
                                          style: text14(color: AppColors.white70))),
                                )
                              else
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 0.85,
                                  ),
                                  itemCount: finalMatches.length,
                                  itemBuilder: (context, index) {
                                    return _buildHighlightsGridItem(finalMatches[index]);
                                  },
                                ),
                            ],
                          );
                        }

                        // Default view (List with "See all")
                        List<String> sportsToDisplay = [];
                        if (topSport.isNotEmpty) {
                          // If top tab is not 'All', only show that sport
                          sportsToDisplay = [topSport];
                        } else if (ctr.selectedCategory.value.isNotEmpty) {
                          // If 'All' tab but a sub-category is selected
                          sportsToDisplay = [ctr.selectedCategory.value];
                        } else {
                          // Show all sports
                          sportsToDisplay = ctr.sportsList.skip(1).toList();
                        }

                        return Column(
                          children: sportsToDisplay.map((sport) {
                            var sportMatches = ctr.allMatches
                                .where((m) =>
                                    (m.status?.toLowerCase() == 'finished' ||
                                        m.status?.toLowerCase() == 'completed') &&
                                    m.sport?.toLowerCase() == sport.toLowerCase())
                                .toList();

                            if (sportMatches.isEmpty && ctr.selectedCategory.value.isEmpty && topSport.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader(sport, "See all", onActionTap: () {
                                  Get.toNamed(
                                    AppRoutes.seeAllMatches,
                                    arguments: {
                                      'title': "$sport Matches",
                                      'matches': sportMatches,
                                    },
                                  );
                                }),
                                const SizedBox(height: 8),
                                _buildRecapMatchList(matches: sportMatches),
                                const SizedBox(height: 16),
                              ],
                            );
                          }).toList(),
                        );
                      }),

                      const SizedBox(height: 20),
                      _buildFooter(),
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

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        children: [
          // Company Logo
          Image.asset(
            AppImage.logo,
            height: 100,
          ),

          const SizedBox(height: 16),

          // Social Media Icons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _socialIcon(FontAwesomeIcons.facebookF, "https://www.facebook.com/share/1EUtkYpvCG/"),
              const SizedBox(width: 16),

              _socialIcon(FontAwesomeIcons.instagram, "https://www.instagram.com/play_on2026/"),
              const SizedBox(width: 16),

              _socialIcon(FontAwesomeIcons.xTwitter, "https://x.com/playon2026"),
              const SizedBox(width: 16),

              _socialIcon(FontAwesomeIcons.youtube, "https://www.youtube.com/@playon2026"),
              const SizedBox(width: 16),

              _socialIcon(FontAwesomeIcons.linkedinIn, "https://linkedin.com"),
              const SizedBox(width: 16),

              _socialIcon(FontAwesomeIcons.envelope, "mailto:playontvindia@gmail.com"),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            "© 2026 PlayOn. All rights reserved.",
            style: text12(color: AppColors.white60),
          ),
          const SizedBox(height: 10),

          // Policy Links
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _policyText("Privacy Policy", AppRoutes.privacyPolicy),
              _divider(),

              _policyText("Refund Policy", AppRoutes.refundPolicy),
              _divider(),

              _policyText("Terms of Use", AppRoutes.termsConditions),
              _divider(),

              _policyText("About Us", AppRoutes.aboutUs),
            ],
          ),
        ],
      ),
    );
  }
  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        "|",
        style: text13(color: AppColors.white60),
      ),
    );
  }

  Widget _buildHighlightsSlider(List<model.Match> matches) {
    if (matches.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          "Latest Highlights",
          "",
        ),
        const SizedBox(height: 12),
        CarouselSlider.builder(
          itemCount: matches.length,
          itemBuilder: (context, index, realIndex) {
            final match = matches[index];
            return GestureDetector(
              onTap: () {
                ctr.handleProtectedAction(() {
                  Get.toNamed(AppRoutes.highlightsPlayer, arguments: match);
                });
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: match.thumbnail != null && match.thumbnail!.isNotEmpty
                        ? NetworkImage(match.thumbnail!)
                        : const AssetImage('assets/auth/cri.png') as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            match.title ?? "${match.teamA} vs ${match.teamB}",
                            style: text18(fontWeight: FontWeight.bold, color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            match.tournament ?? "Match Highlights",
                            style: text12(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          options: CarouselOptions(
            height: 180,
            viewportFraction: 0.9,
            enlargeCenterPage: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            enableInfiniteScroll: matches.length > 1,
          ),
        ),
      ],
    );
  }

  Widget _policyText(String text, String route) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(route);
      },
      child: Text(
        text,
        style: text13(
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  Widget _socialIcon(IconData icon, String url) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: FaIcon(
          icon,
          color: AppColors.white,
          size: 18,
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
                      match.title ?? "Match Highlights",
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

  Widget _buildHighlightsGridItem(model.Match match) {
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
