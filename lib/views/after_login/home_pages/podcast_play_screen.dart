import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/view_model/after_controller/home_contollers/podcast_play_controller.dart';
import 'package:play_on_app/views/after_login/match_pages/full_video_play_screen.dart';
import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';
import 'package:video_player/video_player.dart';
import '../../../routes/app_routes.dart';

class PodcastPlayScreen extends StatelessWidget {
  const PodcastPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PodcastPlayController());

    return Scaffold(
      body: BackgroundWithOneLight(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button and Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                    Expanded(
                      child: Text(
                        "Podcast Player",
                        style: text18(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Video Player Section
              _buildVideoPlayer(controller),

              // Podcast Info Section
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Obx(() {
                      final podcast = controller.podcast.value;
                      if (podcast == null) return const SizedBox.shrink();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            podcast.title ?? "Untitled Podcast",
                            style: text24(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  podcast.category?.toUpperCase() ?? "PODCAST",
                                  style: text10(fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.access_time, size: 16, color: AppColors.white70),
                              const SizedBox(width: 4),
                              Text(
                                podcast.duration ?? "Podcast",
                                style: text12(color: AppColors.white70),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text("Description", style: text16(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                            podcast.description ?? "No description available for this podcast.",
                            style: text14(color: AppColors.white70),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(PodcastPlayController controller) {
    return GestureDetector(
      onTap: controller.toggleControls,
      child: Container(
        height: 220,
        width: double.infinity,
        color: Colors.black,
        child: Stack(
          children: [
            Obx(() {
              if (controller.isLock.value) {
                return Container(
                  color: Colors.black,
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      size: 80,
                      color: Colors.white38,
                    ),
                  ),
                );
              }

              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }

              if (!controller.isInitialized.value || controller.videoController == null) {
                return const Center(
                  child: Text(
                    "Video unavailable",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              return Center(
                child: AspectRatio(
                  aspectRatio: controller.videoController!.value.aspectRatio,
                  child: VideoPlayer(controller.videoController!),
                ),
              );
            }),

            // Lock Overlay
            Obx(() {
              if (controller.isLock.value) {
                return Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.88),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lock_rounded,
                          size: 75,
                          color: Colors.white70,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Unlock Premium Podcast",
                          style: text20(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Subscribe to a plan to enjoy this podcast",
                          style: text15(color: Colors.white70),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            Get.toNamed(AppRoutes.accessPlan, arguments: controller.podcast.value);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text("Upgrade Now", style: text14(fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox();
            }),

            // Controls Overlay
            Obx(() {
              if (controller.isLock.value || (!controller.showControls.value && controller.isPlaying.value)) {
                return const SizedBox();
              }
              return Stack(
                children: [
                  Container(
                    color: Colors.black.withValues(alpha: 0.3),
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: controller.togglePlay,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          controller.isPlaying.value ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: controller.isInitialized.value
                        ? VideoProgressIndicator(
                            controller.videoController!,
                            allowScrubbing: true,
                            colors: const VideoProgressColors(
                              playedColor: AppColors.primary,
                              backgroundColor: Colors.white24,
                              bufferedColor: Colors.white38,
                            ),
                          )
                        : const SizedBox(),
                  ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: GestureDetector(
                      onTap: () {
                        if (controller.isInitialized.value) {
                          Get.to(() => FullScreenVideoPage(controller: controller.videoController!));
                        }
                      },
                      child: const Icon(Icons.fullscreen, color: Colors.white, size: 28),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
