import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:play_on_app/view_model/after_controller/home_contollers/home_controller.dart';

class AdBannerWidget extends StatelessWidget {
  final double height;
  final EdgeInsetsGeometry? padding;

  const AdBannerWidget({
    super.key,
    this.height = 160,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
  });

  @override
  Widget build(BuildContext context) {
    final HomeController ctr = Get.find<HomeController>();

    return Obx(() {
      if (ctr.isBannerLoading.value && ctr.bannerList.isEmpty) {
        return SizedBox(
          height: height,
          child: const Center(child: CircularProgressIndicator()),
        );
      }
      if (ctr.bannerList.isEmpty) {
        return const SizedBox.shrink();
      }
      return CarouselSlider.builder(
        itemCount: ctr.bannerList.length,
        options: CarouselOptions(
          height: height,
          viewportFraction: 1.0,
          autoPlay: ctr.bannerList.length > 1,
          autoPlayInterval: const Duration(seconds: 5),
          enlargeCenterPage: false,
        ),
        itemBuilder: (context, index, realIndex) {
          final banner = ctr.bannerList[index];
          final imageUrl = banner.image ?? "";

          // Handle relative URLs if necessary
          final fullImageUrl = imageUrl.startsWith('http')
              ? imageUrl
              : "baseUrl$imageUrl"; // Replace baseUrl with your actual base URL if needed

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
                            debugPrint("Error loading banner image: \$exception");
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
