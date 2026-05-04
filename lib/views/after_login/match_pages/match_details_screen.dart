import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/routes/app_routes.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/utils/custom_button.dart';

import 'package:play_on_app/views/custom_background.dart/ad_banner_widget.dart';
import 'package:play_on_app/view_model/after_controller/match_controller/match_controller.dart';
import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';

import '../../../view_model/after_controller/home_contollers/home_controller.dart';
import '../../../view_model/after_controller/plan_controller.dart';

class MatchDetailScreen extends StatelessWidget {
  final MatchDetailsController controller = Get.put(MatchDetailsController());
  final PlanController planController = Get.find<PlanController>();

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
                        child: _buildBannerImage(match.banner, match.sport),
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
                            Builder(builder: (context) {
                              final homeController = Get.find<HomeController>();
                              final seriesName = homeController.getSeriesName(match.seriesId);
                              final seriesLogo = homeController.getSeriesLogo(match.seriesId);

                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (seriesLogo.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: Image.network(
                                        seriesLogo,
                                        height: 18,
                                        width: 18,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                                      ),
                                    ),
                                  Text(
                                    seriesName.isNotEmpty ? seriesName : (match.tournament ?? ""),
                                    style: text16(color: AppColors.textSecondary),
                                  ),
                                ],
                              );
                            }),
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
                                if (match.description != null && match.description!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      match.description!,
                                      style: text14(color: AppColors.white70),
                                    ),
                                  ),
                                const SizedBox(height: 20),
                                
                                // Team Logo and Score section
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.white.withOpacity(0.1)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      // Team A
                                      Column(
                                        children: [
                                          _teamLogo(match.teamALogo, size: 50),
                                          const SizedBox(height: 8),
                                          SizedBox(
                                            width: 80,
                                            child: Text(
                                              match.teamA ?? "",
                                              textAlign: TextAlign.center,
                                              style: text12(fontWeight: FontWeight.bold),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      // Score
                                      Column(
                                        children: [
                                          Text(
                                            match.score ?? "vs",
                                            style: text24(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          if (controller.isLive.value)
                                            Container(
                                              margin: const EdgeInsets.only(top: 4),
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(color: Colors.red.withOpacity(0.5)),
                                              ),
                                              child: Text("LIVE", style: text10(color: Colors.red, fontWeight: FontWeight.bold)),
                                            ),
                                        ],
                                      ),

                                      // Team B
                                      Column(
                                        children: [
                                          _teamLogo(match.teamBLogo, size: 50),
                                          const SizedBox(height: 8),
                                          SizedBox(
                                            width: 80,
                                            child: Text(
                                              match.teamB ?? "",
                                              textAlign: TextAlign.center,
                                              style: text12(fontWeight: FontWeight.bold),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),
                                Builder(builder: (context) {
                                  final homeController = Get.find<HomeController>();
                                  final seriesName = homeController.getSeriesName(match.seriesId);
                                  final seriesLogo = homeController.getSeriesLogo(match.seriesId);

                                  return Row(
                                    children: [
                                      if (seriesLogo.isNotEmpty)
                                        Container(
                                          height: 24,
                                          width: 24,
                                          margin: const EdgeInsets.only(right: 8),
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: AppColors.white.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Image.network(
                                            seriesLogo,
                                            fit: BoxFit.contain,
                                            errorBuilder: (_, __, ___) => const Icon(Icons.emoji_events, size: 14, color: AppColors.primary),
                                          ),
                                        ),
                                      Expanded(
                                        child: Text(
                                          seriesName.isNotEmpty ? seriesName : (match.tournament ?? ""),
                                          style: text15(fontWeight: FontWeight.w600, color: AppColors.primary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                                const SizedBox(height: 8),
                                Text(
                                  "${match.sport?.toUpperCase()} • ${match.venue ?? 'TBA'}",
                                  style: text12(color: AppColors.white.withOpacity(0.5)),
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

            // Dynamic Ad Banners
            const SliverToBoxAdapter(
              child: AdBannerWidget(
                height: 180,
                padding: EdgeInsets.symmetric(horizontal: 16),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        );
      }),
      ),
    );
  }

  Widget _buildBannerImage(String? url, String? sport) {
    final placeholder = _getSportPlaceholder(sport);

    if (url == null || url.isEmpty) {
      return Image.asset(
        placeholder,
        fit: BoxFit.cover,
      );
    } else {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          placeholder,
          fit: BoxFit.cover,
        ),
      );
    }
  }

  String _getSportPlaceholder(String? sport) {
    if (sport == null) return 'assets/auth/cri.png';
    switch (sport.toLowerCase()) {
      case 'football':
      case 'soccer':
        return 'assets/auth/football.png';
      case 'tennis':
        return 'assets/auth/tennis.jpg';
      case 'basketball':
        return 'assets/auth/basketball.jpg';
      default:
        return 'assets/auth/cri.png';
    }
  }

  Widget _teamLogo(String? url, {double size = 48}) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipOval(
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: url != null && url.isNotEmpty
              ? Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.shield,
                    color: Colors.grey.shade400,
                    size: size * 0.5,
                  ),
                )
              : Icon(
                  Icons.shield,
                  color: Colors.grey.shade400,
                  size: size * 0.5,
                ),
        ),
      ),
    );
  }
}
