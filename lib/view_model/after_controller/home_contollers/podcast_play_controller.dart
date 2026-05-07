import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:play_on_app/model/response_model/podcast_model.dart';
import '../../../model/response_model/comment_model.dart';
import '../../../repo/match_repository.dart';
import '../plan_controller.dart';

class PodcastPlayController extends GetxController {
  final podcast = Rxn<Podcast>();
  VideoPlayerController? videoController;
  final planController = Get.find<PlanController>();
  
  var isInitialized = false.obs;
  var isPlaying = false.obs;
  var showControls = true.obs;
  var isLoading = true.obs;
  var isLock = false.obs;
  final comments = <Comment>[].obs;
  final deletingCommentId = ''.obs;
  final isCommentsLoading = false.obs;
  final commentController = TextEditingController();
  final MatchRepository _repository = MatchRepository();



  @override
  void onInit() {
    super.onInit();

    if (Get.arguments is Podcast) {
      podcast.value = Get.arguments;

      /// PLAN LISTENERS
      ever(planController.hasAccess, (_) => checkAccess());
      ever(planController.mySubscription, (_) => checkAccess());
      ever(podcast, (_) => checkAccess());

      checkAccess();

      /// VIDEO INIT
      if (!isLock.value && podcast.value?.url != null) {
        initializeVideo(podcast.value!.url!);
      } else {
        isLoading.value = false;
      }

      /// FETCH COMMENTS
      fetchComments();
    }
  }


  void checkAccess() {
    if (podcast.value == null) return;
    isLock.value = (podcast.value?.isPremium == true) && !planController.canWatchPodcast(podcast.value);
    
    // Stop playback if it becomes locked
    if (isLock.value && videoController != null && videoController!.value.isPlaying) {
      videoController?.pause();
      isPlaying.value = false;
      showControls.value = true;
    }
  }
  void initializeVideo(String url) {
    if (isLock.value) return;
    isLoading.value = true;
    videoController = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        isInitialized.value = true;
        videoController?.play();
        isPlaying.value = true;
        isLoading.value = false;
      }).catchError((error) {
        isLoading.value = false;
      });

    videoController?.addListener(() {
      if (videoController != null) {
        isPlaying.value = videoController!.value.isPlaying;
      }
    });
  }

  void togglePlay() {
    if (videoController == null) return;
    if (videoController!.value.isPlaying) {
      videoController!.pause();
    } else {
      videoController!.play();
    }
  }

  void toggleControls() {
    showControls.value = !showControls.value;
    if (showControls.value) {
      Future.delayed(const Duration(seconds: 3), () {
        if (isPlaying.value) {
          showControls.value = false;
        }
      });
    }
  }

  Future<void> fetchComments() async {
    final itemId = podcast.value?.sId;

    if (itemId == null) return;

    isCommentsLoading.value = true;

    try {
      final res = await _repository.getMatchComments(itemId);

      if (res['success'] == true) {
        final data = CommentModel.fromJson(res);

        comments.assignAll(data.comments ?? []);
      }
    } catch (e) {
      debugPrint("Error fetching comments: $e");
    } finally {
      isCommentsLoading.value = false;
    }
  }

  String formatDate(String? date) {
    if (date == null) return "";

    try {
      return DateFormat(
        'dd MMM yyyy',
      ).format(DateTime.parse(date));
    } catch (e) {
      return "";
    }
  }

  Future<void> addComment() async {
    final itemId = podcast.value?.sId;

    if (itemId == null ||
        commentController.text.trim().isEmpty) {
      return;
    }

    final commentText = commentController.text.trim();

    commentController.clear();

    try {
      final res = await _repository.addComment(
        itemId,
        commentText,
      );

      if (res['success'] == true) {
        fetchComments();
      } else {
        Get.snackbar(
          "Error",
          res['message'] ?? "Failed to add comment",
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to add comment",
      );
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      deletingCommentId.value = commentId;

      final res = await _repository.deleteComment(commentId);

      if (res['success'] == true) {
        comments.removeWhere((e) => e.sId == commentId);

        Get.snackbar(
          "Success",
          "Comment deleted successfully",
        );
      } else {
        Get.snackbar(
          "Error",
          res['message'] ?? "Failed to delete comment",
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to delete comment",
      );
    } finally {
      deletingCommentId.value = '';
    }
  }



  @override
  void onClose() {
    videoController?.dispose();
    super.onClose();
  }
}
