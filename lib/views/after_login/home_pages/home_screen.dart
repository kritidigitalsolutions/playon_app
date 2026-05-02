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
import 'package:play_on_app/model/response_model/series_model.dart' as series_model;
import 'package:play_on_app/model/response_model/star_player_model.dart' as star_player_model;
import 'package:play_on_app/model/response_model/podcast_model.dart' as podcast_model;
import 'package:play_on_app/view_model/after_controller/player_controller.dart';

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                          var displayLiveMatches = ctr.filteredLiveMatches.toList();

                          if (displayLiveMatches.isEmpty) {
                            return const SizedBox.shrink();
                          }

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
                        // Trending Matches Section
                        Obx(() {
                          String dashboardSport = (ctr.selectedTabIndex.value != 0
                              ? ctr.sportsList[ctr.selectedTabIndex.value]
                              : "");
                          var trendingMatches = ctr.allMatches.where((m) => m.isTrending == true).toList();
                          
                          if (dashboardSport.isNotEmpty) {
                            trendingMatches = trendingMatches
                                .where((m) => m.sport?.toLowerCase() == dashboardSport.toLowerCase())
                                .toList();
                          }
                          
                          return _buildTrendingMatches(trendingMatches);
                        }),
                        const SizedBox(height: 16),
                        // Series Sections
                        Obx(() {
                          String dashboardSport = (ctr.selectedTabIndex.value != 0
                              ? ctr.sportsList[ctr.selectedTabIndex.value]
                              : "");
                          var seriesList = ctr.seriesList.toList();
                          
                          if (dashboardSport.isNotEmpty) {
                            seriesList = seriesList
                                .where((s) => s.sport?.toLowerCase() == dashboardSport.toLowerCase())
                                .toList();
                          }
                          
                          return _buildSeriesSection(seriesList);
                        }),
                        const SizedBox(height: 16),
                        // Upcoming Matches Section
                        Builder(builder: (context) {
                          var upcomingMatches = ctr.filteredMatches
                              .where((m) =>
                          m.status?.toLowerCase() == 'upcoming')
                              .toList();

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
                          if (topHighlights.isEmpty) return const SizedBox.shrink();
                          return _buildHighlightsSlider(topHighlights);
                        }),
                        const SizedBox(height: 16),
                        // Star Player Edition
                        Obx(() {
                          String dashboardSport = (ctr.selectedTabIndex.value != 0
                              ? ctr.sportsList[ctr.selectedTabIndex.value]
                              : "");
                          var players = ctr.starPlayers.toList();

                          if (dashboardSport.isNotEmpty) {
                            players = players
                                .where((p) =>
                                    p.sportId?.name?.toLowerCase() ==
                                    dashboardSport.toLowerCase())
                                .toList();
                          }
                          return _buildStarPlayerSection(players);
                        }),
                        const SizedBox(height: 24),
                        // Podcasts Section
                        Obx(() {
                          String dashboardSport = (ctr.selectedTabIndex.value != 0
                              ? ctr.sportsList[ctr.selectedTabIndex.value]
                              : "");
                          var podcasts = ctr.podcastList.toList();

                          if (dashboardSport.isNotEmpty) {
                            podcasts = podcasts
                                .where((p) =>
                                    p.category?.toLowerCase() ==
                                    dashboardSport.toLowerCase())
                                .toList();
                          }
                          return _buildPodcastSection(podcasts);
                        }),
                        const SizedBox(height: 16),
                      ],

                      // Category Chips
                      // _buildSectionHeader("Search by Category", ""),
                      // const SizedBox(height: 8),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 12),
                      //   child: Wrap(
                      //     spacing: 8,
                      //     runSpacing: 8,
                      //     children: (ctr.selectedTabIndex.value == 0
                      //         ? ctr.sportsList.skip(1).toList()
                      //         : [ctr.sportsList[ctr.selectedTabIndex.value]]).map<Widget>((tab) {
                      //       return _buildCategoryChip(
                      //         tab,
                      //             () {
                      //           searchController.clear();
                      //           ctr.searchQuery.value = "";
                      //           ctr.selectSubCategory(tab);
                      //         },
                      //         isSelected: ctr.selectedCategory.value == tab ||
                      //                    (ctr.selectedTabIndex.value != 0 && ctr.sportsList[ctr.selectedTabIndex.value] == tab),
                      //       );
                      //     }).toList(),
                      //   ),
                      // ),

                      // const SizedBox(height: 16),
                      //
                      // // Results Section (Highlights/Filtered)
                      // Builder(builder: (context) {
                      //   // Current Sport determines which sections to show
                      //   String topSport = ctr.selectedTabIndex.value != 0
                      //       ? ctr.sportsList[ctr.selectedTabIndex.value]
                      //       : "";
                      //
                      //   // If a specific search is active, show grid
                      //   if (ctr.searchQuery.value.isNotEmpty) {
                      //     String currentSportFilter = ctr.selectedCategory.value.isNotEmpty
                      //         ? ctr.selectedCategory.value
                      //         : topSport;
                      //
                      //     var matchesToFilter = ctr.filteredMatches;
                      //     var finalMatches = matchesToFilter
                      //         .where((m) =>
                      //             (m.status?.toLowerCase() == 'finished' ||
                      //                 m.status?.toLowerCase() == 'completed') &&
                      //             (currentSportFilter.isEmpty ||
                      //                 m.sport?.toLowerCase() ==
                      //                     currentSportFilter.toLowerCase()))
                      //         .toList();
                      //
                      //     return Column(
                      //       crossAxisAlignment: CrossAxisAlignment.start,
                      //       children: [
                      //         Padding(
                      //           padding: const EdgeInsets.only(left: 12, bottom: 8),
                      //           child: Text(
                      //             currentSportFilter.isNotEmpty ? "$currentSportFilter Search Results" : "Search Results",
                      //             style: text24(fontWeight: FontWeight.bold),
                      //           ),
                      //         ),
                      //         if (finalMatches.isEmpty)
                      //           Padding(
                      //             padding: const EdgeInsets.symmetric(vertical: 40),
                      //             child: Center(
                      //                 child: Text("No matches found",
                      //                     style: text14(color: AppColors.white70))),
                      //           )
                      //         else
                      //           GridView.builder(
                      //             shrinkWrap: true,
                      //             physics: const NeverScrollableScrollPhysics(),
                      //             padding: const EdgeInsets.symmetric(horizontal: 12),
                      //             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      //               crossAxisCount: 2,
                      //               crossAxisSpacing: 12,
                      //               mainAxisSpacing: 16,
                      //               childAspectRatio: 0.85,
                      //             ),
                      //             itemCount: finalMatches.length,
                      //             itemBuilder: (context, index) {
                      //               return _buildHighlightsGridItem(finalMatches[index]);
                      //             },
                      //           ),
                      //       ],
                      //     );
                      //   }
                      //
                      //   // Default view (List with "See all")
                      //   List<String> sportsToDisplay = [];
                      //   if (topSport.isNotEmpty) {
                      //     // If top tab is not 'All', only show that sport
                      //     sportsToDisplay = [topSport];
                      //   } else if (ctr.selectedCategory.value.isNotEmpty) {
                      //     // If 'All' tab but a sub-category is selected
                      //     sportsToDisplay = [ctr.selectedCategory.value];
                      //   } else {
                      //     // Show all sports
                      //     sportsToDisplay = ctr.sportsList.skip(1).toList();
                      //   }
                      //
                      //   return Column(
                      //     children: sportsToDisplay.map((sport) {
                      //       var sportMatches = ctr.allMatches
                      //           .where((m) =>
                      //               (m.status?.toLowerCase() == 'finished' ||
                      //                   m.status?.toLowerCase() == 'completed') &&
                      //               m.sport?.toLowerCase() == sport.toLowerCase())
                      //           .toList();
                      //
                      //       if (sportMatches.isEmpty && ctr.selectedCategory.value.isEmpty && topSport.isEmpty) {
                      //         return const SizedBox.shrink();
                      //       }
                      //
                      //       return Column(
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: [
                      //           _buildSectionHeader(sport, "See all", onActionTap: () {
                      //             Get.toNamed(
                      //               AppRoutes.seeAllMatches,
                      //               arguments: {
                      //                 'title': "$sport Matches",
                      //                 'matches': sportMatches,
                      //               },
                      //             );
                      //           }),
                      //           const SizedBox(height: 8),
                      //           _buildRecapMatchList(matches: sportMatches),
                      //           const SizedBox(height: 16),
                      //         ],
                      //       );
                      //     }).toList(),
                      //   );
                      // }),

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
          Obx(() {
            if (ctr.isSocialLoading.value) {
              return const SizedBox(
                height: 40,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }
            if (ctr.socialMediaList.isEmpty) {
              return const SizedBox.shrink();
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ctr.socialMediaList.map((social) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _socialIcon(_getSocialIcon(social.platform ?? ""), social.url ?? ""),
                );
              }).toList(),
            );
          }),

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
                  Get.toNamed(AppRoutes.matchPlay, arguments: match);
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
        String launchUrlStr = url;
        // Check if it's an email address without mailto: scheme
        if (url.contains('@') && !url.startsWith('mailto:') && !url.startsWith('http')) {
          launchUrlStr = 'mailto:$url';
        }

        final uri = Uri.parse(launchUrlStr);
        try {
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            // Fallback for mailto if canLaunchUrl fails (common on some Android versions)
            if (launchUrlStr.startsWith('mailto:')) {
              await launchUrl(uri);
            }
          }
        } catch (e) {
          debugPrint("Error launching URL: $e");
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

  IconData _getSocialIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return FontAwesomeIcons.facebookF;
      case 'instagram':
        return FontAwesomeIcons.instagram;
      case 'twitter':
      case 'x':
        return FontAwesomeIcons.xTwitter;
      case 'youtube':
        return FontAwesomeIcons.youtube;
      case 'linkedin':
        return FontAwesomeIcons.linkedinIn;
      case 'email':
      case 'mail':
        return FontAwesomeIcons.envelope;
      default:
        return FontAwesomeIcons.globe;
    }
  }

  Widget _buildLiveMatchCard(model.Match match) {
    return Obx(() {
      final canWatch = Get.find<PlanController>().canWatchMatch(match);
      return GestureDetector(
        onTap: () {
          if (canWatch) {
            Get.toNamed(AppRoutes.matchPlay, arguments: match);
          } else {
            ctr.handleProtectedAction(() {
              Get.toNamed(AppRoutes.matchPlay, arguments: match);
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
                    if (match.isPremium != false && !canWatch)
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
                  text: "Watch Now",
                  icon: canWatch ? Icons.play_arrow : Icons.lock_outline,
                  onPressed: () {
                    if (canWatch) {
                      ctr.handleProtectedAction(() {
                        Get.toNamed(AppRoutes.matchPlay, arguments: match);
                      });
                    } else {
                      ctr.handleProtectedAction(() {
                        Get.toNamed(AppRoutes.matchPlay, arguments: match);
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

  Widget _buildTrendingMatches(List<model.Match> matches) {
    if (matches.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Trending Matches", ""),
        const SizedBox(height: 14),

        SizedBox(
          height: 190,
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
                    if (canWatch) {
                      Get.toNamed(AppRoutes.matchPlay, arguments: match);
                    } else {
                      ctr.handleProtectedAction(() {
                        Get.toNamed(AppRoutes.matchPlay, arguments: match);
                      });
                    }
                  },
                  child: Container(
                    width: 280,
                    margin: const EdgeInsets.only(right: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        /// 🔹 Background Image
                        Hero(
                          tag: 'trending_${match.sId}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.network(
                              match.thumbnail ?? "",
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Image.asset(
                                'assets/auth/cri.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),

                        /// 🔹 Gradient Overlay
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.8),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),

                        /// 🔥 Trending Badge
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orangeAccent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.local_fire_department, size: 14, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  "TRENDING",
                                  style: text10(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        /// 🔻 Bottom Content
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    /// Sport Tag
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        match.sport?.toUpperCase() ?? "SPORT",
                                        style: text10(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (match.isPremium != false && !canWatch)
                                      const Icon(Icons.lock, color: Colors.white, size: 16),
                                  ],
                                ),

                                const SizedBox(height: 6),

                                /// Match Title
                                Text(
                                  match.title ?? "${match.teamA} vs ${match.teamB}",
                                  style: text14(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSeriesSection(List<series_model.Series> series) {
    if (series.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: series.map((item) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(item.title ?? "Series", "View All", onActionTap: () {
              Get.toNamed(AppRoutes.seeAllMatches, arguments: {
                'title': item.title ?? "Series",
                'matches': item.fullMatches ?? [],
              });
            }),
            const SizedBox(height: 12),
            if (item.fullMatches != null && item.fullMatches!.isNotEmpty)
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: item.fullMatches!.length,
                  itemBuilder: (context, index) {
                    final match = item.fullMatches![index];
            return Obx(() {
              final canWatch = Get.find<PlanController>().canWatchMatch(match);
              return GestureDetector(
                onTap: () {
                  if (canWatch) {
                    Get.toNamed(AppRoutes.matchPlay, arguments: match);
                  } else {
                    ctr.handleProtectedAction(() {
                      Get.toNamed(AppRoutes.matchPlay, arguments: match);
                    });
                  }
                },
                child: Container(
                  width: 240,
                  margin: const EdgeInsets.only(right: 14),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.white.withOpacity(0.1), width: 1),
                    image: DecorationImage(
                      image: match.thumbnail != null && match.thumbnail!.isNotEmpty
                          ? NetworkImage(match.thumbnail!)
                          : const AssetImage('assets/auth/cri.png') as ImageProvider,
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.4),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                match.status?.toUpperCase() ?? "UPCOMING",
                                style: text10(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              match.title ?? "${match.teamA} vs ${match.teamB}",
                              style: text14(fontWeight: FontWeight.bold, color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 12, color: AppColors.white70),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    match.venue ?? "Stadium",
                                    style: text11(color: AppColors.white70),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if ((match.isPremium != false || item.isPremium != false) && !canWatch)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: const Icon(Icons.lock, color: Colors.white, size: 16),
                        )
                      else if (match.status?.toLowerCase() == 'live')
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            });
                  },
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "No matches currently available",
                  style: text12(color: AppColors.white60),
                ),
              ),
            const SizedBox(height: 24),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildStarPlayerSection(List<star_player_model.StarPlayer> players) {
    if (players.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Star Player Edition", ""),
        const SizedBox(height: 16),

        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: players.length,
            itemBuilder: (context, index) {
              final player = players[index];

              return Obx(() {
                final canWatch = Get.find<PlanController>().canWatchHighlight(player);
                return GestureDetector(
                  onTap: () {
                    if (canWatch) {
                      ctr.handleProtectedAction(() {
                        Get.toNamed(AppRoutes.highlightsPlayer, arguments: player);
                      });
                    } else {
                      ctr.handleProtectedAction(() {
                        Get.toNamed(AppRoutes.highlightsPlayer, arguments: player);
                      });
                    }
                  },
                  child: Container(
                    width: 170,
                    margin: const EdgeInsets.only(right: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Stack(
                        children: [

                          /// 🖼 IMAGE
                          Positioned.fill(
                            child: Image.network(
                              player.thumbnail ?? "",
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[900],
                                child: const Icon(Icons.person,
                                    color: Colors.white24, size: 50),
                              ),
                            ),
                          ),

                          /// 🌈 STRONG GRADIENT (cinematic)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.95),
                                    Colors.black.withOpacity(0.6),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ),
                              ),
                            ),
                          ),

                          /// 🔥 PLAY BUTTON (glass style)
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white30),
                              ),
                              child: Icon(
                                canWatch ? Icons.play_arrow : Icons.lock_outline,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),

                          /// 🏷 TOP TAG (SPORT)
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                player.sportId?.name?.toUpperCase() ?? "SPORT",
                                style: text10(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          /// 🔻 TEXT INFO
                          Positioned(
                            bottom: 12,
                            left: 12,
                            right: 12,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        player.playerName ?? "Star Athlete",
                                        style: text14(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (player.isPremium != false && !canWatch)
                                      const Icon(Icons.lock, color: Colors.white70, size: 14),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  player.title ?? "Match Highlights",
                                  style: text11(
                                    color: AppColors.white70,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          /// ✨ SHADOW OVERLAY (depth)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPodcastSection(List<podcast_model.Podcast> podcasts) {
    if (podcasts.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Latest Podcasts", "Explore", onActionTap: () {
          Get.toNamed(AppRoutes.podcastList);
        }),
        const SizedBox(height: 14),
        SizedBox(
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: podcasts.length,
            itemBuilder: (context, index) {
              final podcast = podcasts[index];
              return Obx(() {
                final canWatch = Get.find<PlanController>().canWatchPodcast(podcast);
                return GestureDetector(
                  onTap: () {
                    if (canWatch) {
                      Get.toNamed(AppRoutes.podcastPlay, arguments: podcast);
                    } else {
                      ctr.handleProtectedAction(() {
                        Get.toNamed(AppRoutes.podcastPlay, arguments: podcast);
                      });
                    }
                  },
                  child: Container(
                    width: 150,
                    margin: const EdgeInsets.only(right: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// 🔥 Podcast Cover
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: podcast.thumbnail != null && podcast.thumbnail!.isNotEmpty
                                  ? Image.network(
                                      podcast.thumbnail!,
                                      height: 130,
                                      width: 150,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Image.asset(
                                        'assets/auth/cri.png',
                                        height: 130,
                                        width: 150,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Image.asset(
                                      'assets/auth/cri.png',
                                      height: 130,
                                      width: 150,
                                      fit: BoxFit.cover,
                                    ),
                            ),

                            /// Gradient Overlay
                            Container(
                              height: 130,
                              width: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.6),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),

                            /// ▶ Play Button
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  canWatch ? Icons.play_arrow : Icons.lock_outline,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                            if (podcast.isPremium != false && !canWatch)
                              Positioned(
                                top: 8,
                                left: 8,
                                child: const Icon(Icons.lock, color: Colors.white70, size: 16),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        /// 🎧 Title
                        Text(
                          podcast.title ?? "Sports Talk",
                          style: text14(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),

                        /// ⏱ Duration + Channel
                        Row(
                          children: [
                            const Icon(Icons.headset, size: 12, color: AppColors.white70),
                            const SizedBox(width: 4),
                            Text(
                              podcast.duration?.isNotEmpty == true ? podcast.duration! : "Podcast",
                              style: text11(color: AppColors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTab(String text, int index, bool isSelected) {
    return GestureDetector(
      onTap: () {
        searchController.clear();
        ctr.searchQuery.value = "";
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
                  Get.toNamed(AppRoutes.matchPlay, arguments: match);
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
                          if (match.isPremium != false && !canWatch)
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
                Get.toNamed(AppRoutes.matchPlay, arguments: match);
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
            Get.toNamed(AppRoutes.matchPlay, arguments: match);
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
