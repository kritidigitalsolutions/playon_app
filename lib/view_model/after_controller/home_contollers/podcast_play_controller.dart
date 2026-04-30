import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:play_on_app/model/response_model/podcast_model.dart';

class PodcastPlayController extends GetxController {
  final podcast = Rxn<Podcast>();
  VideoPlayerController? videoController;
  
  var isInitialized = false.obs;
  var isPlaying = false.obs;
  var showControls = true.obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is Podcast) {
      podcast.value = Get.arguments;
      if (podcast.value?.url != null) {
        initializeVideo(podcast.value!.url!);
      } else {
        isLoading.value = false;
      }
    }
  }

  void initializeVideo(String url) {
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
