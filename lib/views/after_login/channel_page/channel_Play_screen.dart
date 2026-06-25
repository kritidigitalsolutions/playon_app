import 'dart:ui';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:play_on_app/model/response_model/channel_model.dart' as model;
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/routes/app_routes.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/utils/custom_button.dart';
import 'package:play_on_app/utils/hive_service/hive_service.dart';
import 'package:play_on_app/utils/share_helper.dart';
import 'package:video_player/video_player.dart';
import 'package:get/get.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:play_on_app/utils/custom_snakebar.dart';
import 'package:play_on_app/views/widgets/admob_banner_widget.dart';
import 'package:play_on_app/view_model/after_controller/ad_controller.dart';
import 'package:play_on_app/view_model/after_controller/home_contollers/home_controller.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../custom_background.dart/ad_banner_widget.dart';

class ChannelPlayScreen extends StatefulWidget {
  const ChannelPlayScreen({super.key});

  @override
  State<ChannelPlayScreen> createState() => _ChannelPlayScreenState();
}

class _ChannelPlayScreenState extends State<ChannelPlayScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  YoutubePlayerController? _youtubeController;
  model.Channel? channel;
  final HomeController homeController = Get.find<HomeController>();
  bool _isYoutube = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    if (!HiveService.isLogin()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
        showCustomSnackbar(
          title: "Access Denied",
          message: "Please login to watch live channels",
          type: SnackType.error,
        );
      });
      return;
    }
    channel = Get.arguments as model.Channel?;
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    WakelockPlus.enable();

    // Show Interstitial Ad before playing channel
    if (Get.isRegistered<AdController>()) {
      await Get.find<AdController>().showInterstitialAd();
    }

    final url = channel?.streamUrl ?? "";
    if (url.isEmpty) return;

    // Detect YouTube
    if (url.contains('youtube.com') || url.contains('youtu.be')) {
      _isYoutube = true;
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
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: true,
            mute: false,
            isLive: true,
          ),
        );
        _isInitialized = true;
      }
    } else {
      _isYoutube = false;
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(url),
      );

      try {
        await _videoPlayerController.initialize();

        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          autoPlay: true,
          looping: false,
          showControls: true,
          deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
          deviceOrientationsOnEnterFullScreen: [
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ],
          aspectRatio: _videoPlayerController.value.aspectRatio,
          overlay: (channel?.showLiveLogo == true && channel?.liveLogo != null)
              ? Positioned(
                  top: 10,
                  right: 10,
                  child: Image.network(
                    channel!.liveLogo!,
                    height: 30,
                    fit: BoxFit.contain,
                  ),
                )
              : null,
          materialProgressColors: ChewieProgressColors(
            playedColor: AppColors.error,
            handleColor: AppColors.redAccent,
            backgroundColor: AppColors.grey500,
            bufferedColor: AppColors.white24,
          ),
          placeholder: Container(
            color: AppColors.black87,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.white),
            ),
          ),
          allowedScreenSleep: false,
          allowFullScreen: true,
          fullScreenByDefault: false,
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Text(
                'Error loading video: $errorMessage',
                style: const TextStyle(color: AppColors.white),
              ),
            );
          },
        );
        _isInitialized = true;
      } catch (e) {
        debugPrint("Video initialization error: $e");
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _shareChannel() {
    if (channel == null) return;
    final text =
        "Watch ${channel!.name} live on PlayOn!\nDownload now: https://play.google.com/store/apps/details?id=com.cametech.playon";
    ShareHelper.shareMatchWithImage(
      text: text,
      imageUrl: channel!.thumbnail ?? channel!.logo,
    );
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    if (!_isYoutube) {
      _videoPlayerController.dispose();
      _chewieController?.dispose();
    } else {
      _youtubeController?.dispose();
    }
    WakelockPlus.disable();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isYoutube && _youtubeController != null) {
      return YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _youtubeController!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: AppColors.primary,
          onReady: () {
            setState(() {
              _isInitialized = true;
            });
          },
        ),
        builder: (context, player) => _buildScaffold(youtubePlayer: player),
      );
    }
    return _buildScaffold();
  }

  Widget _buildScaffold({Widget? youtubePlayer}) {
    return Scaffold(
      backgroundColor: AppColors.secPrimary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Video Player at Top
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  Container(
                    color: Colors.black,
                    child: _isInitialized
                        ? (_isYoutube
                            ? (youtubePlayer ?? const SizedBox())
                            : (_chewieController != null
                                ? Chewie(controller: _chewieController!)
                                : const Center(
                                    child: CircularProgressIndicator(
                                        color: Colors.white),
                                  )))
                        : const Center(
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          ),
                  ),

                  // Live Logo
                  if (channel?.showLiveLogo == true && channel?.liveLogo != null)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Image.network(
                        channel!.liveLogo!,
                        height: 30,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const SizedBox(),
                      ),
                    ),

                  // Back Button
                  Positioned(
                    top: 10,
                    left: 10,
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.adaptive.arrow_back,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Channel Info & Actions
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Logo
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: channel?.logo != null && channel!.logo!.isNotEmpty
                                ? Image.network(
                                    channel!.logo!,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.tv, color: Colors.white),
                                  )
                                : const Icon(Icons.tv, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Name & Number
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                channel?.name ?? "Live Stream",
                                style: text18(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              if (channel?.channelNumber != null)
                                Text(
                                  "Channel ${channel!.channelNumber}",
                                  style: text16(color: Colors.white),
                                ),
                            ],
                          ),
                        ),
                        // Share Button
                        IconButton(
                          onPressed: _shareChannel,
                          icon: const Icon(Icons.share, color: AppColors.button),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 3. Details
                    if (channel?.description != null && channel!.description!.isNotEmpty) ...[
                      Text("Description", style: text14(fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 8),
                      Text(channel!.description!, style: text12(color: Colors.white70)),
                      const SizedBox(height: 20),
                    ],

                    // 4. Banner Ad
                    const AdBannerWidget(position: "channel_play_bottom"),
                    const SizedBox(height: 8),
                    const AdMobBannerWidget(position: "channel_play_bottom"),

                    const SizedBox(height: 20),

                    // 5. More Channels (Related)
                    Text("Related Channels", style: text16(fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 12),
                    _buildRelatedChannels(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedChannels() {
    final related = homeController.allChannels
        .where((c) => c.category == channel?.category && c.sId != channel?.sId)
        .toList();

    // Sort related channels by channelNumber
    related.sort((a, b) => (a.channelNumber ?? 0).compareTo(b.channelNumber ?? 0));

    if (related.isEmpty) {
      return const Center(
        child: Text("No related channels", style: TextStyle(color: Colors.white38)),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: related.length,
      itemBuilder: (context, index) {
        final item = related[index];
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.white.withOpacity(0.18),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  // Channel Logo
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: item.logo != null && item.logo!.isNotEmpty
                          ? Image.network(
                              item.logo!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.tv, color: AppColors.white70),
                            )
                          : const Icon(Icons.tv, color: AppColors.white70, size: 28),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Channel Name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name ?? "Unknown Channel",
                          style: text16(fontWeight: FontWeight.w500, color: Colors.white),
                        ),
                        if (item.category != null)
                          Text(
                            item.category!.toUpperCase(),
                            style: text12(color: Colors.white60),
                          ),
                      ],
                    ),
                  ),

                  // Channel Number
                  if (item.channelNumber != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Text(
                        "${item.channelNumber}",
                        style: text24(color: AppColors.white, fontWeight: FontWeight.bold),
                      ),
                    ),

                  // Watch Button
                  AppButton(
                    title: "Watch",
                    onTap: () {
                      Get.offNamed(AppRoutes.channelPlay, arguments: item, preventDuplicates: false);
                    },
                    height: 30,
                    textStyle: text13(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
