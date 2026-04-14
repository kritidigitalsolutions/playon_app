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
import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final HomeController ctr = Get.find();

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
                                child: Text(
                                  "Search Matches",
                                  overflow: TextOverflow.ellipsis,
                                  style: text13(color: AppColors.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4), // Reduced from 5
                  AppIconButton(
                    icon: Icons.person_outline,
                    color: AppColors.white,
                    onTap: () {
                      Get.toNamed(AppRoutes.profilePage);
                    },
                  ),
                  const SizedBox(width: 4), // Reduced from 5
                  AppIconButton(
                    icon: Icons.notifications,
                    color: AppColors.warning,
                    onTap: () {
                      Get.toNamed(AppRoutes.notification);
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
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero, // Remove default padding
                children: [
                  const SizedBox(height: 8), // Reduced from 6
                  // MacBook Pro Ad Banner
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                    ), // Reduced from 16
                    child: Container(
                      height: 160, // Reduced from 180
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/iPhone.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12), // Reduced from 20
                  // Improved Carousel Slider
                  CarouselSlider.builder(
                    itemCount: 5,
                    itemBuilder: (context, index, realIndex) {
                      return _buildLiveMatchCard(index);
                    },
                    options: CarouselOptions(
                      height: 200, // Set explicit height
                      enlargeCenterPage: true,
                      viewportFraction:
                          0.85, // Reduced from 0.9 for better side visibility
                      enableInfiniteScroll: true,
                      autoPlay: true,
                      autoPlayInterval: const Duration(
                        seconds: 4,
                      ), // Increased from 3
                      autoPlayAnimationDuration: const Duration(
                        milliseconds: 800,
                      ),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enlargeFactor: 0.25, // Better scale effect
                      enlargeStrategy: CenterPageEnlargeStrategy.scale,
                    ),
                  ),
                  const SizedBox(height: 16), // Reduced from 28
                  // Upcoming Matches Section
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(
                      "Upcoming Matches",
                      style: text20(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8), // Reduced from 12
                  _buildUpcomingMatch(),

                  const SizedBox(height: 16), // Reduced from 28
                  // Search by Category
                  _buildSectionHeader("Search by Category", ""),
                  const SizedBox(height: 8), // Reduced from 12
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                    ), // Reduced from 16
                    child: Wrap(
                      spacing: 8, // Reduced from 12
                      runSpacing: 8, // Reduced from 12
                      children: [
                        _buildCategoryChip("Cricket"),
                        _buildCategoryChip("Football"),
                        _buildCategoryChip("Basketball"),
                        _buildCategoryChip("Tennis"),
                        _buildCategoryChip("Motorsports"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16), // Reduced from 30
                  // Football Section
                  _buildSectionHeader("Football", "See all"),
                  const SizedBox(height: 8), // Reduced from 12
                  _buildHorizontalMatchList(isFootball: true),

                  const SizedBox(height: 16), // Reduced from 30
                  // Cricket Section
                  _buildSectionHeader("Cricket", "See all"),
                  const SizedBox(height: 8), // Reduced from 12
                  _buildHorizontalMatchList(isFootball: false),

                  const SizedBox(height: 16), // Reduced from 30
                  // Basketball Section
                  _buildSectionHeader("Basketball", "See all"),
                  const SizedBox(height: 8), // Reduced from 12
                  _buildHorizontalMatchList(isFootball: true),

                  const SizedBox(height: 80), // Reduced from 100
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveMatchCard(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 4,
      ), // Add margin for better spacing
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF0A1F3D),
        image: const DecorationImage(
          image: AssetImage("assets/auth/cri.png"),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
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
                        decoration: BoxDecoration(
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
                  "3RD ODI, SYDNEY",
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
                    "AUS vs IND\nPRE MATCH",
                    style: text18(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "India vs Australia",
                    style: text14(color: AppColors.white70),
                  ),
                ],
              ),
            ),
            AppButton(
              title: "Watch Live",
              onTap: () {
                print(ctr.isLogin.value);
                ctr.handleProtectedAction(() {
                  Get.toNamed(AppRoutes.matchDetails);
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

  Widget _buildUpcomingMatch() {
    return SizedBox(
      height: 300, // Reduced from 190
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12), // Reduced from 16
        itemCount: 5,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              ctr.handleProtectedAction(() {
                Get.toNamed(AppRoutes.matchDetails);
              });
            },
            child: Container(
              width: 160, // Reduced from 160
              margin: const EdgeInsets.only(right: 12), // Reduced from 12
              decoration: BoxDecoration(
                // color: AppColors.blackCard,
                // borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Match Image / Teams
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        image: DecorationImage(
                          image: AssetImage('assets/auth/cri.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 8), // Reduced from 10
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [AppColors.primary, AppColors.error],
                      ).createShader(bounds),
                      child: Text(
                        "CRICKET",
                        style: text14(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Text(
                    "APR 8, 2026",
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
    bool isFootball = false,
    bool isUpcaming = false,
  }) {
    return SizedBox(
      height: 160, // Reduced from 190
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12), // Reduced from 16
        itemCount: 5,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              print(ctr.isLogin.value);
              ctr.handleProtectedAction(() {
                if (isUpcaming) {
                  Get.toNamed(AppRoutes.matchDetails);
                } else {
                  Get.toNamed(AppRoutes.recapMatch);
                }
              });
            },
            child: Container(
              width: 180, // Reduced from 160
              margin: const EdgeInsets.only(right: 12), // Reduced from 12
              decoration: BoxDecoration(
                // color: AppColors.blackCard,
                // borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Match Image / Teams
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        // borderRadius: const BorderRadius.vertical(
                        //   top: Radius.circular(12),
                        // ),
                        image: DecorationImage(
                          image: AssetImage(
                            isFootball
                                ? 'assets/auth/football.png'
                                : 'assets/auth/cri.png',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 8), // Reduced from 10
                    child: Row(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [AppColors.primary, AppColors.error],
                          ).createShader(bounds),
                          child: Text(
                            isFootball ? "FOOTBALL" : "CRICKET",
                            style: text14(fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(width: 3),
                        Text(
                          "APR 8, 2026",
                          style: text13(
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "IND | Indian Womens Vs Pak Womens",
                    overflow: TextOverflow.ellipsis,
                    style: text13(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 8), // Add bottom spacing
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    return Container(
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
    );
  }
}
