import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/routes/app_routes.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/utils/custom_button.dart';
import 'dart:ui';

import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:play_on_app/model/response_model/channel_model.dart' as model;
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/routes/app_routes.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/utils/custom_button.dart';
import 'package:play_on_app/view_model/after_controller/home_contollers/home_controller.dart';
import 'dart:ui';

import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';

class SportChannelList extends StatefulWidget {
  const SportChannelList({super.key});

  @override
  State<SportChannelList> createState() => _SportChannelListState();
}

class _SportChannelListState extends State<SportChannelList> {
  final HomeController ctr = Get.find();
  final RxInt selectedChannelTabIndex = 0.obs;
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = "".obs;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWithOutImg(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Live TV\nChannels",
                      style: text24(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white24.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.25),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search,
                                color: AppColors.white70,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: searchController,
                                  onChanged: (value) {
                                    ctr.searchQuery.value = value;
                                  },
                                  style: text13(color: AppColors.white),
                                  decoration: InputDecoration(
                                    hintText: "Search",
                                    hintStyle:
                                        text13(color: AppColors.textSecondary),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Category Tabs
            Obx(
              () => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        selectedChannelTabIndex.value = 0;
                      },
                      child: _buildCategoryTab(
                        "All",
                        selectedChannelTabIndex.value == 0,
                      ),
                    ),
                    ...List.generate(
                      ctr.channelCategories.length,
                      (index) => GestureDetector(
                        onTap: () {
                          selectedChannelTabIndex.value = index + 1;
                        },
                        child: _buildCategoryTab(
                          ctr.channelCategories[index].name ?? "",
                          selectedChannelTabIndex.value == index + 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Channels List
            Expanded(
              child: Obx(() {
                if (ctr.isChannelLoading.value || ctr.isCategoryLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                var displayChannels = selectedChannelTabIndex.value == 0
                    ? ctr.filteredChannels
                    : ctr.filteredChannels
                        .where((c) =>
                            c.category?.toLowerCase() ==
                            ctr.channelCategories[selectedChannelTabIndex.value - 1].name?.toLowerCase())
                        .toList();

                if (displayChannels.isEmpty) {
                  return const Center(
                    child: Text(
                      "No channels found for this category",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ctr.fetchChannels();
                  },
                  child: AnimationLimiter(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: displayChannels.length,
                      itemBuilder: (BuildContext context, int index) {
                        final channel = displayChannels[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: _buildChannelItem(channel),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Category Tab
  Widget _buildCategoryTab(String text, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.white.withValues(alpha: 0.15)
            : AppColors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? AppColors.white.withValues(alpha: 0.4)
              : AppColors.transparent,
        ),
      ),
      child: Text(
        text,
        style: text14(
          color: isSelected ? AppColors.white : AppColors.white70,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }

  // Channel Item with Glass Effect
  Widget _buildChannelItem(model.Channel channel) {
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
                  child: channel.logo != null && channel.logo!.isNotEmpty
                      ? Image.network(
                          channel.logo!,
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
                      channel.name ?? "Unknown Channel",
                      style: text16(fontWeight: FontWeight.w500),
                    ),
                    if (channel.category != null)
                      Text(
                        channel.category!.toUpperCase(),
                        style: text12(color: AppColors.white60),
                      ),
                  ],
                ),
              ),

              // Watch Button
              AppButton(
                title: "Watch",
                onTap: () {
                  Get.toNamed(AppRoutes.channelPlay, arguments: channel);
                },
                height: 30,
                textStyle: text13(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
