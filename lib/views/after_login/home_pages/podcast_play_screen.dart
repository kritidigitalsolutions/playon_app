import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/view_model/after_controller/home_contollers/podcast_play_controller.dart';
import 'package:play_on_app/views/after_login/match_pages/full_video_play_screen.dart';
import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';
import 'package:video_player/video_player.dart';
import '../../../routes/app_routes.dart';
import '../../custom_background.dart/custum_date.dart';

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
                        "Podcast",
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
                          const SizedBox(height: 28),

                          /// COMMENTS HEADER
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Comments",
                                style: text18(fontWeight: FontWeight.bold),
                              ),
                              Obx(() => Text(
                                "${controller.comments.length}",
                                style: text13(color: AppColors.white60),
                              )),
                            ],
                          ),

                          const SizedBox(height: 16),

                          /// ADD COMMENT BOX
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: controller.commentController,
                                    style: text14(),
                                    decoration: InputDecoration(
                                      hintText: "Add a comment...",
                                      hintStyle: text14(
                                        color: AppColors.white.withOpacity(0.4),
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: controller.addComment,
                                  icon: const Icon(
                                    Icons.send_rounded,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 22),

                          /// COMMENTS LIST
                          Obx(() {
                            if (controller.isCommentsLoading.value) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            if (controller.comments.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 25),
                                child: Center(
                                  child: Text(
                                    "No comments yet",
                                    style: text14(color: Colors.white54),
                                  ),
                                ),
                              );
                            }

                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: controller.comments.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 18),
                              itemBuilder: (_, index) {
                                final comment = controller.comments[index];

                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor:
                                      AppColors.primary.withOpacity(0.2),

                                      backgroundImage:
                                      (comment.userImage != null &&
                                          comment.userImage!.isNotEmpty)
                                          ? NetworkImage(comment.userImage!)
                                          : null,

                                      child: (comment.userImage == null ||
                                          comment.userImage!.isEmpty)
                                          ? Text(
                                        comment.userName?[0]
                                            .toUpperCase() ??
                                            "U",
                                        style: text14(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                          : null,
                                    ),

                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.04),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    comment.userName ?? "User",
                                                    style: text14(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),

                                                /// DELETE BUTTON
                                                Obx(() {
                                                  final isDeleting =
                                                      controller.deletingCommentId.value ==
                                                          comment.sId;

                                                  return GestureDetector(
                                                    onTap: isDeleting
                                                        ? null
                                                        : () {
                                                      Get.dialog(
                                                        AlertDialog(
                                                          backgroundColor: Colors.black,
                                                          title: const Text(
                                                            "Delete Comment",
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                          content: const Text(
                                                            "Are you sure you want to delete this comment?",
                                                            style: TextStyle(
                                                              color: Colors.white70,
                                                            ),
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () => Get.back(),
                                                              child: const Text("Cancel"),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                Get.back();

                                                                controller.deleteComment(
                                                                  comment.sId ?? "",
                                                                );
                                                              },
                                                              child: const Text(
                                                                "Delete",
                                                                style: TextStyle(
                                                                  color: Colors.red,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                    child: isDeleting
                                                        ? const SizedBox(
                                                      height: 16,
                                                      width: 16,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                    )
                                                        : const Icon(
                                                      Icons.delete_outline,
                                                      color: Colors.redAccent,
                                                      size: 18,
                                                    ),
                                                  );
                                                }),

                                                const SizedBox(width: 10),

                                                Text(
                                                  controller.formatDate(
                                                    comment.createdAt,
                                                  ),
                                                  style: text10(
                                                    color: Colors.white38,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 6),

                                            Text(
                                              comment.comment ?? "",
                                              style: text13(
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          }),
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
