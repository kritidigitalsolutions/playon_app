import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/view_model/after_controller/home_contollers/home_controller.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../routes/app_routes.dart';
import '../../../view_model/after_controller/plan_controller.dart';

class PodcastListScreen extends StatelessWidget {
  const PodcastListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          "Latest Podcasts",
          style: text20(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isPodcastLoading.value && controller.podcastList.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (controller.podcastList.isEmpty) {
          return Center(
            child: Text(
              "No podcasts available",
              style: text16(color: AppColors.white70),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.podcastList.length,
          itemBuilder: (context, index) {
            final podcast = controller.podcastList[index];
            return Obx(() {
              final planCtr = Get.find<PlanController>();
              final canWatch = planCtr.canWatchPodcast(podcast);
              
              return GestureDetector(
                onTap: () {
                  if (canWatch) {
                    Get.toNamed(AppRoutes.podcastPlay, arguments: podcast);
                  } else {
                    controller.handleProtectedAction(() {
                      Get.toNamed(AppRoutes.podcastPlay, arguments: podcast);
                    });
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.white),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: podcast.thumbnail != null && podcast.thumbnail!.isNotEmpty
                                ? Image.network(
                                    podcast.thumbnail!,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Image.asset(
                                      'assets/auth/cri.png',
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Image.asset(
                                    'assets/auth/cri.png',
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.8),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                canWatch ? Icons.play_arrow : Icons.lock_outline,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                          if (podcast.isPremium != false && !canWatch)
                            Positioned(
                              top: 12,
                              left: 12,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.lock, color: Colors.white, size: 20),
                              ),
                            ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              podcast.title ?? "Untitled Podcast",
                              style: text18(fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              podcast.description ?? "",
                              style: text14(color: AppColors.white70),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.headset, size: 16, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Text(
                                  podcast.category?.toUpperCase() ?? "SPORTS",
                                  style: text12(color: AppColors.primary, fontWeight: FontWeight.w600),
                                ),
                                const Spacer(),
                                const Icon(Icons.access_time, size: 16, color: AppColors.white70),
                                const SizedBox(width: 4),
                                Text(
                                  podcast.duration?.isNotEmpty == true ? podcast.duration! : "Podcast",
                                  style: text12(color: AppColors.white70),
                                ),
                              ],
                            ),
                          ],
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
    );
  }
}
