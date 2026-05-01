import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/routes/app_routes.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/utils/custom_button.dart';
import 'package:play_on_app/view_model/after_controller/plan_controller.dart';
import 'package:play_on_app/view_model/after_controller/watchlist_controller.dart';
import 'package:play_on_app/view_model/after_controller/home_contollers/home_controller.dart';
import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';
import 'package:play_on_app/model/response_model/match_model.dart' as model;

class CreateWatchlistScreen extends StatelessWidget {
  CreateWatchlistScreen({super.key});

  final WatchlistController watchlistController = Get.put(WatchlistController());
  final HomeController homeController = Get.find<HomeController>();

  // ✅ Date Format
  String formatDate(String? date, String? time) {
    if (date == null || date.isEmpty) return "";
    try {
      DateTime parsedDate = DateTime.parse(date).toLocal();
      String formattedDate = DateFormat('dd MMM yyyy').format(parsedDate);
      if (time != null && time.isNotEmpty) {
        DateTime parsedTime = DateTime.parse(time).toLocal();
        String formattedTime = DateFormat('hh:mm a').format(parsedTime);
        return "$formattedDate | $formattedTime";
      }
      return formattedDate;
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWithOutImg(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              const SizedBox(height: 20),

              Text(
                "Your Watchlist",
                style: text20(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: Obx(() {
                  if (watchlistController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  /// 🔴 EMPTY STATE
                  if (watchlistController.watchlistItems.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.bookmark_border, size: 60, color: Colors.white30),
                        const SizedBox(height: 10),
                        const Text("No Watchlist Yet", style: TextStyle(color: Colors.white70)),

                        const SizedBox(height: 20),

                        /// 🔥 Suggestions ONLY when empty
                        SizedBox(
                          height: 180,
                          child: Obx(() {
                            final suggested = homeController.allMatches.take(6).toList();

                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: suggested.length,
                              itemBuilder: (context, index) {
                                final match = suggested[index];

                                return Obx(() {
                                  final canWatch = Get.find<PlanController>().canWatchMatch(match);
                                  return GestureDetector(
                                    onTap: () {
                                      if (canWatch) {
                                        Get.toNamed(AppRoutes.recapMatch, arguments: match);
                                      } else {
                                        homeController.handleProtectedAction(() {
                                          Get.toNamed(AppRoutes.recapMatch, arguments: match);
                                        });
                                      }
                                    },
                                    child: Container(
                                      width: 130,
                                      margin: const EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: AppColors.white.withOpacity(0.05),
                                      ),
                                      child: Column(
                                        children: [
                                          ClipRRect(
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                            child: Stack(
                                              children: [
                                                Image.network(
                                                  match.thumbnail ?? "",
                                                  height: 90,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) =>
                                                      Image.asset("assets/auth/cri.png", height: 90),
                                                ),
                                                if (match.isPremium != false && !canWatch)
                                                  Positioned(
                                                    top: 4,
                                                    right: 4,
                                                    child: const Icon(Icons.lock, color: Colors.white, size: 14),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 6),
                                            child: Text(
                                              "${match.teamA} vs ${match.teamB}",
                                              textAlign: TextAlign.center,
                                              style: text10(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                });
                              },
                            );
                          }),
                        ),
                      ],
                    );
                  }

                  /// ✅ WATCHLIST GRID
                  return GridView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.58,
                    ),
                    itemCount: watchlistController.watchlistItems.length,
                    itemBuilder: (context, index) {
                      final match = watchlistController.watchlistItems[index];
                      return _buildCard(match);
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

  // ✅ CARD UI
  Widget _buildCard(model.Match match) {
    final isLive = match.status?.toLowerCase() == "live";

    return Obx(() {
      final canWatch = Get.find<PlanController>().canWatchMatch(match);
      return Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.white.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                /// 🎥 IMAGE + LIVE
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                      child: Image.network(
                        match.thumbnail ?? "",
                        height: 70,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (isLive)
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Text("LIVE", style: TextStyle(fontSize: 8)),
                        ),
                      ),
                    if (match.isPremium != false && !canWatch)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: const Icon(Icons.lock, color: Colors.white, size: 14),
                      ),
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  "${match.teamA} vs ${match.teamB}",
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text10(fontWeight: FontWeight.w600),
                ),

                Text(
                  formatDate(match.matchDate, match.liveStartedAt),
                  style: text11(color: AppColors.white70),
                ),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.all(4),
                  child: AppButton(
                    height: 20,
                    radius: 6,
                    title: canWatch ? (isLive ? "Watch" : "Details") : "Watch",
                    onTap: () {
                      if (canWatch) {
                        Get.toNamed(AppRoutes.matchPlay, arguments: match);
                      } else {
                        homeController.handleProtectedAction(() {
                          Get.toNamed(AppRoutes.matchPlay, arguments: match);
                        });
                      }
                    },
                    textStyle: text11(),
                  ),
                ),
              ],
            ),
          ),

          /// ❌ REMOVE BUTTON
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () async {
                await watchlistController.toggleWatchlist(match.sId!, "match");

                Get.snackbar(
                  "Removed",
                  "Removed from watchlist",
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}