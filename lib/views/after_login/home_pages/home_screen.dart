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

                  SizedBox(width: 5),

                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 16,
                          sigmaY: 16,
                        ), // Crystal blur intensity
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white24.withValues(
                              alpha: 0.15,
                            ), // Semi-transparent for glass effect
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: AppColors.white.withValues(
                                alpha: 0.25,
                              ), // Crystal shine border
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: AppColors.white70,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
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
                  SizedBox(width: 5),

                  AppIconButton(
                    icon: Icons.person_outline,
                    color: AppColors.white,
                    onTap: () {
                      Get.toNamed(AppRoutes.profilePage);
                    },
                  ),
                  SizedBox(width: 5),
                  AppIconButton(
                    icon: Icons.notifications,
                    color: AppColors.warning,
                    onTap: () {
                      Get.toNamed(AppRoutes.notification);
                    },
                  ),
                  SizedBox(width: 5),
                ],
              ),
            ),

            // Category Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildTab("Live", true),
                  _buildTab("Cricket", false),
                  _buildTab("Football", false),
                  _buildTab("Tennis", false),
                  _buildTab("Sports", false),
                  _buildTab("Basketball", false),
                  _buildTab("Hockey", false),
                  _buildTab("Badminton", false),
                ],
              ),
            ),
            SizedBox(height: 5),

            Expanded(
              child: ListView(
                physics: BouncingScrollPhysics(),
                children: [
                  const SizedBox(height: 6),

                  // MacBook Pro Ad Banner
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),

                        image: const DecorationImage(
                          image: AssetImage(
                            'assets/images/iPhone.png',
                          ), // Add your image
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  CarouselSlider.builder(
                    itemCount: 5, // number of cards
                    itemBuilder: (context, index, realIndex) {
                      return _buildLiveMatchCard(index);
                    },
                    options: CarouselOptions(
                      enlargeCenterPage: true, // ⭐ center card big
                      viewportFraction: 0.9, // side cards visible
                      enableInfiniteScroll: true,
                      autoPlay: true,
                      autoPlayInterval: Duration(seconds: 3),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Upcoming Matches Section
                  _buildSectionHeader("Upcoming Matches", "See all"),
                  const SizedBox(height: 12),
                  _buildHorizontalMatchList(isUpcaming: true),

                  const SizedBox(height: 28),

                  // Search by Category
                  _buildSectionHeader("Search by Category", ""),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildCategoryChip("Cricket"),
                        _buildCategoryChip("Football"),
                        _buildCategoryChip("Basketball"),
                        _buildCategoryChip("Tennis"),
                        _buildCategoryChip("Motorsports"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Football Section (from second screenshot)
                  _buildSectionHeader("Football", "See all"),
                  const SizedBox(height: 12),
                  _buildHorizontalMatchList(isFootball: true),

                  const SizedBox(height: 30),

                  // Football Section (from second screenshot)
                  _buildSectionHeader("Cricket", "See all"),
                  const SizedBox(height: 12),
                  _buildHorizontalMatchList(isFootball: false),

                  const SizedBox(height: 30),

                  // Football Section (from second screenshot)
                  _buildSectionHeader("Basketball", "See all"),
                  const SizedBox(height: 12),
                  _buildHorizontalMatchList(isFootball: true),

                  const SizedBox(height: 100), // Extra space for bottom nav
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF0A1F3D),
        image: DecorationImage(
          image: AssetImage("assets/auth/cri.png"),
          fit: BoxFit.cover,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "LIVE",
                    style: text12(fontWeight: FontWeight.bold),
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
              // ⭐ important
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

  Widget _buildTab(String text, bool isSelected) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors
                      .primary // Keep your selected color solid
                : AppColors.white.withValues(
                    alpha: 0.15,
                  ), // ← Changed for glass effect
            borderRadius: BorderRadius.circular(30),
            border: isSelected
                ? null
                : Border.all(
                    color: AppColors.white.withValues(alpha: 0.25),
                    width: 1.2,
                  ),
          ),
          child: Text(
            text,
            style: text13(
              color: isSelected ? AppColors.white : AppColors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String action) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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

  Widget _buildHorizontalMatchList({
    bool isFootball = false,
    bool isUpcaming = false,
  }) {
    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: AppColors.blackCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Match Image / Teams
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    // color: isFootball ? AppColors. : AppColors.primary,
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
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "India vs England",
                    textAlign: TextAlign.center,
                    style: text13(),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: AppButton(
                    title: "Watch Now",
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
                    radius: 8,
                    height: 25,
                    textStyle: text12(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.secPrimary.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(label, style: text14(color: AppColors.white70)),
    );
  }
}
