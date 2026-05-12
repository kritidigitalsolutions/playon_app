import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:play_on_app/res/app_urls.dart';
import 'package:play_on_app/view_model/after_controller/home_contollers/home_controller.dart';

class AdBannerWidget extends StatelessWidget {
  final double height;
  final EdgeInsetsGeometry? padding;
  final String? position;

  const AdBannerWidget({
    super.key,
    this.height = 160,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
    this.position,
  });

  @override
  Widget build(BuildContext context) {
    // Check if HomeController is registered to avoid crashes on screens without HomeBinding
    if (!Get.isRegistered<HomeController>()) {
      return const SizedBox.shrink();
    }
    final HomeController ctr = Get.find<HomeController>();

    return Obx(() {
      var displayBanners = ctr.bannerList.toList();
      
      if (position != null) {
        displayBanners = displayBanners.where((b) => b.position == position).toList();
      }

      if (ctr.isBannerLoading.value && displayBanners.isEmpty) {
        return SizedBox(
          height: height,
          child: const Center(child: CircularProgressIndicator()),
        );
      }
      
      if (displayBanners.isEmpty) {
        return const SizedBox.shrink();
      }
      
      return CarouselSlider.builder(
        itemCount: displayBanners.length,
        options: CarouselOptions(
          height: height,
          viewportFraction: 1.0,
          autoPlay: displayBanners.length > 1,
          autoPlayInterval: const Duration(seconds: 5),
          enlargeCenterPage: false,
        ),
        itemBuilder: (context, index, realIndex) {
          final banner = displayBanners[index];
          final imageUrl = banner.image ?? "";

          // Handle relative URLs if necessary
          final baseUrl = AppUrls.baseUrl.replaceAll('/api', '');
          final fullImageUrl = imageUrl.startsWith('http')
              ? imageUrl
              : "$baseUrl$imageUrl";

          return Padding(
            padding: padding ?? EdgeInsets.zero,
            child: InkWell(
              onTap: () {
                if (banner.link != null && banner.link!.isNotEmpty) {
                  launchUrl(Uri.parse(banner.link!));
                }
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[900],
                  image: imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(fullImageUrl),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) {
                            debugPrint("Error loading banner image: $exception");
                          },
                        )
                      : null,
                ),
                child: imageUrl.isEmpty
                    ? const Center(
                        child: Icon(Icons.image, color: Colors.white24))
                    : null,
              ),
            ),
          );
        },
      );
    });
  }
}
