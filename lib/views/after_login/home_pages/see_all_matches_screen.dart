import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/view_model/after_controller/home_contollers/home_controller.dart';
import 'package:play_on_app/model/response_model/match_model.dart' as model;
import 'package:play_on_app/routes/app_routes.dart';
import '../../../view_model/after_controller/plan_controller.dart';
import '../../custom_background.dart/custom_widget.dart';

class SeeAllMatchesScreen extends StatelessWidget {
  final String title;
  final List<model.Match> matches;

  const SeeAllMatchesScreen({
    super.key,
    required this.title,
    required this.matches,
  });

  @override
  Widget build(BuildContext context) {
    return BackgroundWithOutImg(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          title: Text(
            title,
            style: text20(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: matches.isEmpty
            ? Center(
                child: Text(
                  "No matches found",
                  style: text16(color: AppColors.white70),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: matches.length,
                itemBuilder: (context, index) {
                  return _buildMatchTile(matches[index]);
                },
              ),
      ),
    );
  }

  Widget _buildMatchTile(model.Match match) {
    final HomeController ctr = Get.find();
    final PlanController planCtr = Get.find();

    return Obx(() {
      final canWatch = planCtr.canWatchMatch(match);
      return GestureDetector(
        onTap: () {
          if (canWatch) {
            if (match.status?.toLowerCase() == 'finished' ||
                match.status?.toLowerCase() == 'completed') {
              Get.toNamed(AppRoutes.recapMatch, arguments: match);
            } else {
              Get.toNamed(AppRoutes.matchPlay, arguments: match);
            }
          } else {
            ctr.handleProtectedAction(() {
              if (match.status?.toLowerCase() == 'finished' ||
                  match.status?.toLowerCase() == 'completed') {
                Get.toNamed(AppRoutes.recapMatch, arguments: match);
              } else {
                Get.toNamed(AppRoutes.matchPlay, arguments: match);
              }
            });
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              // Match Banner or Sport Icon
              Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: match.banner != null && match.banner!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(match.banner!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: AppColors.white.withOpacity(0.1),
                    ),
                    child: match.banner == null || match.banner!.isEmpty
                        ? const Icon(Icons.sports_cricket,
                            color: Colors.white38, size: 40)
                        : null,
                  ),
                  if (match.isPremium != false && !canWatch)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock, color: Colors.white, size: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Match Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              if (match.seriesId != null)
                                Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  height: 16,
                                  width: 16,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: ClipOval(
                                    child: Image.network(
                                      ctr.getSeriesLogo(match.seriesId),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Icon(
                                        Icons.emoji_events,
                                        size: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              Expanded(
                                child: Text(
                                  ctr.getSeriesName(match.seriesId) ?? match.tournament ?? match.sport?.toUpperCase() ?? "Match",
                                  style: text12(color: AppColors.primary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (match.isPremium == false)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "FREE",
                              style: text10(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${match.teamA} vs ${match.teamB}",
                      style: text16(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      match.venue ?? "TBA",
                      style: text13(color: AppColors.white70),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Status/Arrow
              const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
            ],
          ),
        ),
      );
    });
  }
}
