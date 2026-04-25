import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/routes/app_routes.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/utils/custom_button.dart';

import 'package:play_on_app/view_model/after_controller/match_controller/match_controller.dart';
import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';

class MatchDetailScreen extends StatelessWidget {
  final MatchDetailsController controller = Get.put(MatchDetailsController());

  MatchDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWithOneLight(
        child: Obx(() {
          final match = controller.match.value;
          if (match == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            slivers: [
              // Pinned Header with Player Images (SliverAppBar style)
              SliverAppBar(
                automaticallyImplyLeading: false,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
                expandedHeight: 260,
                pinned: true,
                backgroundColor: AppColors.secPrimary,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Players Images / Match Banner
                      Positioned.fill(
                        child: match.banner != null && match.banner!.isNotEmpty
                            ? Image.network(
                                match.banner!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset(
                                  'assets/auth/cri.png',
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Image.asset(
                                'assets/auth/cri.png',
                                fit: BoxFit.cover,
                              ),
                      ),
                      // Overlay Text
                      Positioned(
                        top: 80,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            Text(
                              "${match.teamA}  ${match.teamB}",
                              style: text30(
                                fontWeight: FontWeight.bold,
                              ).copyWith(letterSpacing: 4),
                            ),
                            Text(
                              match.tournament ?? "",
                              style: text16(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),

                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (controller.isLive.value)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.stream,
                                      color: AppColors.white,
                                      size: 15,
                                    ),
                                    const SizedBox(width: 5),
                                    Text("Live", style: text13()),
                                  ],
                                ),
                              )
                            else
                              GestureDetector(
                                onTap: controller.toggleReminder,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: controller.isReminderOn.value
                                        ? AppColors.primary
                                        : AppColors.secPrimary.withOpacity(0.6),
                                    border: Border.all(
                                      color: AppColors.white24,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        controller.isReminderOn.value
                                            ? Icons.notifications_active
                                            : Icons.notifications_on_outlined,
                                        color: AppColors.white,
                                        size: 15,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        controller.isReminderOn.value
                                            ? "Reminder Set"
                                            : "Remind Me",
                                        style: text13(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            const SizedBox(height: 8),

                            Text(
                              controller.remainingTime.value,
                              style: text12(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Match Info
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${match.teamA} vs ${match.teamB}",
                                  style: text20(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "${match.sport?.toUpperCase()} • ${match.venue ?? 'TBA'}",
                                  style: text14(color: AppColors.white70),
                                ),
                                if (match.score != null && match.score!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      "Score: ${match.score}",
                                      style: text16(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (controller.isLive.value)
                              CustomElevatedIconButton(
                              height: 25,
                              iconSize: 15,
                              backgroundColor: controller.isLock.value
                                  ? AppColors.error
                                  : AppColors.success,
                              textStyle: text11(),
                              text: controller.isLock.value
                                  ? "Lock Now"
                                  : "Watch Now",
                              icon: controller.isLock.value
                                  ? Icons.lock_outline
                                  : Icons.remove_red_eye,
                              onPressed: () {
                                if (controller.isLock.value) {
                                  Get.toNamed(AppRoutes.accessPlan);
                                } else {
                                  Get.toNamed(AppRoutes.matchPlay, arguments: match);
                                }
                              },
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      if (match.description != null && match.description!.isNotEmpty)
                        Text(
                          match.description!,
                          style: text14(color: AppColors.white70),
                        ),
                    ],
                  ),
                ),
              ),

              // Players to Watch (Example - you can make this dynamic if API supports it)
              if (match.sport?.toLowerCase() == 'cricket')
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Players to Watch",
                          style: text16(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Kohli • Rohit • Joe Root • Ben Stokes",
                          style: text14(color: AppColors.white70),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

            // MacBook Air Ad (Glassmorphism style)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      height: 180,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.white.withOpacity(0.15),
                        ),
                        image: const DecorationImage(
                          image: AssetImage(
                            'assets/images/iPhone.png',
                          ), // Add your image
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Starting at",
                                style: text14(color: AppColors.white70),
                              ),
                              Text(
                                "₹699",
                                style: text24(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        );
      }),
      ),
    );
  }
}
