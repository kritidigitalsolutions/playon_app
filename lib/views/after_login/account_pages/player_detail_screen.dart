import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/model/response_model/player_model.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/view_model/after_controller/player_controller.dart';
import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';

class PlayerDetailScreen extends StatelessWidget {
  const PlayerDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Player player = Get.arguments as Player;
    final PlayerController playerController = Get.find<PlayerController>();

    return Scaffold(
      body: BackgroundWithOutImg(
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  children: [
                    _buildPlayerHeader(player),
                    const SizedBox(height: 30),
                    _buildInfoSection(playerController, player),
                    const SizedBox(height: 30),
                    _buildBioSection(player),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => Get.back(),
          ),
          Text(
            "Player Profile",
            style: text20(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerHeader(Player player) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 2),
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white10,
                backgroundImage: player.image != null
                    ? NetworkImage(player.image!)
                    : const AssetImage("assets/images/virat.png") as ImageProvider,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          player.name ?? "N/A",
          style: text24(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          "${player.position} | ${player.team}",
          style: text14(color: AppColors.white70),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Text(
            player.sport?.toUpperCase() ?? "SPORTS",
            style: text12(color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(PlayerController controller, Player player) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Column(
            children: [
              _infoRow(Icons.flag_outlined, "Country", player.country ?? "N/A"),
              const Divider(color: Colors.white12, height: 24),
              _infoRow(Icons.sports_cricket_outlined, "Sport", player.sport ?? "N/A"),
              const Divider(color: Colors.white12, height: 24),
              _infoRow(Icons.group_outlined, "Team", player.team ?? "N/A"),
              const Divider(color: Colors.white12, height: 24),
              _infoRow(Icons.work_outline, "Position", player.position ?? "N/A"),
              const SizedBox(height: 20),
              Obx(() {
                bool followed = controller.isFollowed(player.id);
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => controller.toggleFollow(player.id!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: followed ? Colors.white12 : AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(
                      followed ? "Unfollow Player" : "Follow Player",
                      style: text16(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: text12(color: AppColors.white70)),
            Text(value, style: text15(fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _buildBioSection(Player player) {
    if (player.bio == null || player.bio!.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Biography", style: text18(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Text(
                player.bio!,
                style: text14(color: AppColors.white70).copyWith(height: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
