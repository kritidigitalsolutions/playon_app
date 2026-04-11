import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/routes/app_routes.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/utils/custom_button.dart';
import 'dart:ui';

import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';

class CreateWatchlistScreen extends StatelessWidget {
  const CreateWatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundWithOutImg(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),

              // Title
              Text(
                "Create your\nWatchlist Now",
                textAlign: TextAlign.center,
                style: text24(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 40),

              // Big Plus Button
              GestureDetector(
                onTap: () {
                  //  Get.toNamed(AppRoutes.matchDetails);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.white.withOpacity(0.25),
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add,
                          size: 42,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Suggested Content - Horizontal Scroll
              const Text(
                "Suggested for you",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: 190, // Increased a bit for safety
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return _buildWatchlistCard(index);
                  },
                ),
              ),

              const SizedBox(height: 40),

              // // Search More Button
              // SizedBox(
              //   width: double.infinity,
              //   child: ElevatedButton(
              //     onPressed: () {},
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: Colors.white.withOpacity(0.15),
              //       padding: const EdgeInsets.symmetric(vertical: 16),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(30),
              //       ),
              //       elevation: 0,
              //       side: const BorderSide(color: Colors.white24),
              //     ),
              //     child: const Text(
              //       "Search More",
              //       style: TextStyle(
              //         color: Colors.white,
              //         fontSize: 16,
              //         fontWeight: FontWeight.w600,
              //       ),
              //     ),
              //   ),
              // ),
              const Spacer(flex: 1), // Flexible spacer
            ],
          ),
        ),
      ),
    );
  }

  // Watchlist Card
  Widget _buildWatchlistCard(int index) {
    final List<String> titles = [
      "Australia Tour\nof India",
      "India vs England\nT20 Series",
      "World Cup\nFinal 2023",
      "India vs Pakistan\nAsia Cup",
      "IPL 2026\nOpening Match",
    ];

    final List<String> images = [
      "assets/auth/cri.png",
      "assets/auth/football.png",
      "assets/auth/cri.png",
      "assets/auth/football.png",
      "assets/auth/cri.png",
    ];

    return Stack(
      children: [
        Container(
          width: 135, // Fixed width for horizontal list
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  images[index],
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.sports_cricket,
                        color: Colors.white70,
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Text(
                titles[index],
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: AppButton(
                  title: "Watch Now",
                  onTap: () {
                    Get.toNamed(AppRoutes.recapMatch);
                  },
                  height: 25,
                  textStyle: text10(),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 12,
          top: 0,
          child: AppIconButton(
            icon: Icons.check,
            onTap: () {},
            color: AppColors.success,
          ),
        ),
      ],
    );
  }
}
