import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/routes/app_routes.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/utils/custom_button.dart';
import 'dart:ui';

import 'package:play_on_app/view_model/after_controller/watchlist_controller.dart';
import 'package:play_on_app/view_model/after_controller/home_contollers/home_controller.dart';
import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';
import 'package:play_on_app/model/response_model/match_model.dart' as model;

class CreateWatchlistScreen extends StatelessWidget {
  CreateWatchlistScreen({super.key});

  final WatchlistController watchlistController = Get.put(WatchlistController());
  final HomeController homeController = Get.find<HomeController>();

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
                "Your Watchlist",
                textAlign: TextAlign.center,
                style: text24(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              // Watchlist Items
              Expanded(
                child: Obx(() {
                  if (watchlistController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (watchlistController.watchlistItems.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    itemCount: watchlistController.watchlistItems.length,
                    itemBuilder: (context, index) {
                      final match = watchlistController.watchlistItems[index];
                      return _buildWatchlistItem(match);
                    },
                  );
                }),
              ),

              const SizedBox(height: 20),

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
                height: 200,
                child: Obx(() {
                  final suggestedMatches = homeController.allMatches.take(5).toList();
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: suggestedMatches.length,
                    itemBuilder: (context, index) {
                      return _buildWatchlistCard(suggestedMatches[index]);
                    },
                  );
                }),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
             Get.toNamed(AppRoutes.myHomePage);
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
        const SizedBox(height: 20),
        const Text(
          "Create your Watchlist Now",
          style: TextStyle(color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildWatchlistItem(model.Match match) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: match.thumbnail != null 
              ? Image.network(match.thumbnail!, width: 80, height: 60, fit: BoxFit.cover)
              : Image.asset("assets/auth/cri.png", width: 80, height: 60, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  match.title ?? "Match",
                  style: text14(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  match.tournament ?? "",
                  style: text12(color: AppColors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () {
              if (match.sId != null) {
                watchlistController.toggleWatchlist(match.sId!, "match");
              }
            },
          ),
          AppButton(
            title: "Watch",
            onTap: () {
               Get.toNamed(AppRoutes.recapMatch, arguments: match);
            },
            height: 30,
            textStyle: text12(),
          ),
        ],
      ),
    );
  }

  Widget _buildWatchlistCard(model.Match match) {
    return Stack(
      children: [
        Container(
          width: 135,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: match.thumbnail != null
                  ? Image.network(match.thumbnail!, height: 100, width: double.infinity, fit: BoxFit.cover)
                  : Image.asset("assets/auth/cri.png", height: 100, width: double.infinity, fit: BoxFit.cover),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  match.title ?? "",
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
                child: AppButton(
                  title: "Watch Now",
                  onTap: () {
                    Get.toNamed(AppRoutes.recapMatch, arguments: match);
                  },
                  height: 25,
                  textStyle: text10(),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 15,
          top: 5,
          child: FutureBuilder<bool>(
            future: watchlistController.isBookmarked("match", match.sId ?? ""),
            builder: (context, snapshot) {
              final inWatchlist = snapshot.data ?? false;
              return GestureDetector(
                onTap: () {
                  if (match.sId != null) {
                    watchlistController.toggleWatchlist(match.sId!, "match");
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: inWatchlist ? AppColors.success : Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    inWatchlist ? Icons.check : Icons.add,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              );
            }
          ),
        ),
      ],
    );
  }
}
