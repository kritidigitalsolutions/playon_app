import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/routes/app_routes.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/utils/custom_button.dart';
import 'dart:ui';

import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';

class SportChannelList extends StatelessWidget {
  const SportChannelList({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundWithOutImg(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Live Sports\nChannels",
                      style: text24(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 1,
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
                ],
              ),
            ),

            // Category Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildCategoryTab("All Sports", true),
                  _buildCategoryTab("Cricket", false),
                  _buildCategoryTab("Football", false),
                  _buildCategoryTab("Tennis", false),
                  _buildCategoryTab("Basketball", false),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Channels List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildChannelItem("Star Sports", "assets/star_sports.png"),
                  _buildChannelItem("Sky Sports", "assets/sky_sports.png"),
                  _buildChannelItem("Star Sports", "assets/star_sports.png"),
                  _buildChannelItem("Sky Sports", "assets/sky_sports.png"),
                  _buildChannelItem("Star Sports", "assets/star_sports.png"),
                  _buildChannelItem("Sky Sports", "assets/sky_sports.png"),
                  _buildChannelItem("Star Sports", "assets/star_sports.png"),
                  _buildChannelItem("Sky Sports", "assets/sky_sports.png"),
                ],
              ),
            ),

            // // View More
            // Padding(
            //   padding: const EdgeInsets.only(bottom: 20),
            //   child: TextButton(
            //     onPressed: () {},
            //     child: const Text(
            //       "View More",
            //       style: TextStyle(
            //         color: Colors.blueAccent,
            //         fontSize: 15,
            //         fontWeight: FontWeight.w500,
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // Category Tab
  Widget _buildCategoryTab(String text, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.white.withValues(alpha: 0.15)
            : AppColors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? AppColors.white.withValues(alpha: 0.4)
              : AppColors.transparent,
        ),
      ),
      child: Text(
        text,
        style: text14(
          color: isSelected ? AppColors.white : AppColors.white70,

          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }

  // Channel Item with Glass Effect
  Widget _buildChannelItem(String channelName, String logoPath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.white.withOpacity(0.18),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              // Channel Logo
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    logoPath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.tv,
                        color: AppColors.white70,
                        size: 28,
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Channel Name
              Expanded(
                child: Text(
                  channelName,
                  style: text16(fontWeight: FontWeight.w500),
                ),
              ),

              // Watch Button
              AppButton(
                title: "Watch",
                onTap: () {
                  Get.toNamed(AppRoutes.channelPlay);
                },
                height: 25,
                textStyle: text13(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
