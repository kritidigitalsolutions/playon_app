import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:play_on_app/model/response_model/podcast_model.dart';
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

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is Podcast) {
      podcast.value = Get.arguments;
      
      // Re-check access whenever plan status or data changes
      ever(planController.hasAccess, (_) => checkAccess());
      ever(planController.mySubscription, (_) => checkAccess());
      ever(podcast, (_) => checkAccess());
      
      checkAccess();

      if (!isLock.value && podcast.value?.url != null) {
        initializeVideo(podcast.value!.url!);
      } else {
        isLoading.value = false;
      }
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

  @override
  void onClose() {
    videoController?.dispose();
    super.onClose();
  }
}
