import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/model/response_model/subscription_model.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/view_model/after_controller/plan_controller.dart';
import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';

import '../../../../routes/app_routes.dart';

class PurchasedItemsPage extends StatelessWidget {
  const PurchasedItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final PlanController controller = Get.find<PlanController>();

    return Scaffold(
      body: BackgroundWithOutImg(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                    Text("My Unlocked Content", style: text20(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Expanded(
                child: Obx(() {
                  final history = controller.subscriptionHistory.value.data?.subscriptions ?? [];

                  final activePasses = history.where((sub) =>
                  sub.status == 'active' &&
                      sub.planId?.slug != 'full-access' &&
                      sub.planId?.slug != 'unlimited-sports-pass'
                  ).toList();

                  if (activePasses.isEmpty) {
                    return Center(
                      child: GestureDetector(
                        onTap: () {
                          Get.toNamed(AppRoutes.accessPlan);
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              size: 64,
                              color: AppColors.white.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),

                            Text(
                              "No specific passes active",
                              style: text16(color: AppColors.white70),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              "Tap to explore plans",
                              style: text12(color: AppColors.white38),
                            ),

                            const SizedBox(height: 20),

                            // 🔥 CTA Button (Better UX)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Text(
                                "View Plans",
                                style: text14(color: AppColors.white),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: activePasses.length,
                    itemBuilder: (context, index) {
                      final sub = activePasses[index];
                      return _buildPurchasedItemCard(sub);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPurchasedItemCard(Subscription sub) {
    String type = "Pass";
    IconData icon = Icons.confirmation_number_outlined;
    
    if (sub.planId?.slug?.contains('match') ?? false) {
      type = "Match Pass";
      icon = Icons.sports_cricket;
    } else if (sub.planId?.slug?.contains('team') ?? false) {
      type = "Team Pass";
      icon = Icons.group;
    } else if (sub.planId?.slug?.contains('series') ?? false) {
      type = "Series Pass";
      icon = Icons.emoji_events;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sub.planId?.title ?? type, style: text16(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("Unlocked on ${_formatDate(sub.startDate)}", style: text12(color: AppColors.white70)),
                      Text("Valid until ${_formatDate(sub.endDate)}", style: text12(color: AppColors.white38)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text("ACTIVE", style: text12(color: AppColors.success, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "N/A";
    try {
      final date = DateTime.parse(dateStr);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateStr;
    }
  }
}
