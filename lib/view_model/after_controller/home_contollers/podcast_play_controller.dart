import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:play_on_app/model/response_model/podcast_model.dart';
import '../../../model/response_model/comment_model.dart';
import '../../../repo/match_repository.dart';
import 'package:play_on_app/view_model/after_controller/ad_controller.dart';
import '../plan_controller.dart';
import 'package:play_on_app/utils/custom_snakebar.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class PodcastPlayController extends GetxController {
  final podcast = Rxn<Podcast>();
  VideoPlayerController? videoController;
  YoutubePlayerController? youtubeController;
  final planController = Get.find<PlanController>();
  
  var isInitialized = false.obs;
  var isYoutube = false.obs;
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
    if (isLock.value) {
      if (isYoutube.value) {
        youtubeController?.pause();
      } else {
        videoController?.pause();
      }
      isPlaying.value = false;
      showControls.value = true;
    }
  }

  Future<void> initializeVideo(String url) async {
    if (isLock.value) return;

    // Show Interstitial Ad before playing podcast
    if (Get.isRegistered<AdController>()) {
      await Get.find<AdController>().showInterstitialAd();
    }

    isLoading.value = true;
    isInitialized.value = false;
    
    // Dispose old controllers
    videoController?.dispose();
    youtubeController?.dispose();
    videoController = null;
    youtubeController = null;
    isYoutube.value = false;

    // Detect YouTube
    bool isYoutubeUrl = url.contains('youtube.com') || url.contains('youtu.be');

    if (isYoutubeUrl) {
      isYoutube.value = true;
      String? videoId = YoutubePlayer.convertUrlToId(url);
      
      // Better ID extraction for various YouTube URL formats (embed links etc)
      if (videoId == null) {
        final regExp = RegExp(
          r'^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#&?]*).*',
          caseSensitive: false,
          multiLine: false,
        );
        final match = regExp.firstMatch(url);
        if (match != null && match.group(7)!.length == 11) {
          videoId = match.group(7);
        }
      }
      
      // Handle cases where the URL might be just the ID
      if (videoId == null && url.length == 11) {
        videoId = url;
      }

      if (videoId != null) {
        youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: true,
            mute: false,
          ),
        );
        isInitialized.value = true;
        isPlaying.value = true;
        isLoading.value = false;
      } else {
        isLoading.value = false;
        showCustomSnackbar(title: "Error", message: "Invalid YouTube URL", type: SnackType.error);
      }
    } else {
      isYoutube.value = false;
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

    _setupAutoHideControls();
  }

  void _setupAutoHideControls() {
    Future.delayed(const Duration(seconds: 3), () {
      if (isPlaying.value) {
        showControls.value = false;
      }
    });
  }

  void togglePlay() {
    if (isYoutube.value) {
      if (youtubeController == null) return;
      if (youtubeController!.value.isPlaying) {
        youtubeController!.pause();
        isPlaying.value = false;
      } else {
        youtubeController!.play();
        isPlaying.value = true;
      }
    } else {
      if (videoController == null) return;
      if (videoController!.value.isPlaying) {
        videoController!.pause();
        isPlaying.value = false;
      } else {
        videoController!.play();
        isPlaying.value = true;
      }
    }
    showControls.value = true;
  }

  void toggleControls() {
    showControls.value = !showControls.value;
    if (showControls.value) {
      _setupAutoHideControls();
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
        showCustomSnackbar(
          title: "Error",
          message: res['message'] ?? "Failed to add comment",
          type: SnackType.error,
        );
      }
    } catch (e) {
      showCustomSnackbar(
        title: "Error",
        message: "Failed to add comment",
        type: SnackType.error,
      );
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      deletingCommentId.value = commentId;

      final res = await _repository.deleteComment(commentId);

      if (res['success'] == true) {
        comments.removeWhere((e) => e.sId == commentId);
      } else {
        showCustomSnackbar(
          title: "Error",
          message: res['message'] ?? "Failed to delete comment",
          type: SnackType.error,
        );
      }
    } catch (e) {
      showCustomSnackbar(
        title: "Error",
        message: "Failed to delete comment",
        type: SnackType.error,
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
