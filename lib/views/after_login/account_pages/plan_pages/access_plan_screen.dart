import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/routes/app_routes.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/utils/custom_button.dart';
import 'dart:ui';

import 'package:play_on_app/views/custom_background.dart/custom_widget.dart'; // For BackdropFilter

class AccessPlansScreen extends StatelessWidget {
  const AccessPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWithOutImg(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // Title
                Text(
                  "Access & Plans",
                  style: text24(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),

                // Subtitle
                Text(
                  "Choose how you want to watch,\nfull access or just a match",
                  style: text15(color: AppColors.textSecondary),
                ),

                const SizedBox(height: 28),

                // Unlimited Sports Pass Card
                _buildPlanCard(
                  title: "Unlimited Sports Pass",
                  price: "₹199 / Month",
                  features: const [
                    "Watch all live matches",
                    "Full match replays & highlights",
                    "Ad-free experience",
                    "Multi-device access",
                  ],
                  buttonText: "Unlock Now",
                  isPrimary: true,
                  onTap: () {
                    Get.back();
                  },
                ),

                const SizedBox(height: 20),

                // Match Pass Card
                _buildPlanCard(
                  title: "Match Pass",
                  price: "₹25 / Match",
                  features: const [
                    "Access to one live match",
                    "Includes highlights & replay",
                    "Valid for 24 hours",
                  ],
                  buttonText: "Choose The Match",
                  isPrimary: false,
                  onTap: () {
                    Get.toNamed(AppRoutes.chooseMatch);
                  },
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required List<String> features,
    required String buttonText,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isPrimary
                ? AppColors.primary.withValues(
                    alpha: 0.4,
                  ) // Slightly brighter blue for primary card
                : AppColors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isPrimary
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : AppColors.white.withValues(alpha: 0.18),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(title, style: text18(fontWeight: FontWeight.bold)),

              const SizedBox(height: 12),

              // Price
              Text(
                price,
                style: text24(
                  color: isPrimary ? AppColors.white : AppColors.textSecondary,

                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 20),

              // Features
              ...features.map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(feature, style: text14())),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Button
              CustomElevatedIconButton(
                text: buttonText,
                icon: Icons.lock_open_outlined,
                onPressed: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
