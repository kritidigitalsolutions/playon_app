import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/view_model/after_controller/player_controller.dart';
import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';
import 'dart:ui';
import 'package:play_on_app/model/response_model/player_model.dart';

class FollowedPlayersScreen extends StatelessWidget {
  const FollowedPlayersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PlayerController _playerController = Get.find<PlayerController>();

    return Scaffold(
      body: BackgroundWithOutImg(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.white),
                      onPressed: () => Get.back(),
                    ),
                    Text(
                      "Followed Players",
                      style: text20(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (_playerController.followedPlayers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.person_add_alt_1_outlined, size: 64, color: Colors.white24),
                          const SizedBox(height: 16),
                          Text("You are not following any players yet", 
                              style: text16(color: Colors.white38)),
                          const SizedBox(height: 8),
                          Text("Keep your eyes on the game", style: text12(color: Colors.white24)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _playerController.followedPlayers.length,
                    itemBuilder: (context, index) {
                      return _buildPlayerCard(context, _playerController.followedPlayers[index], _playerController);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerCard(BuildContext context, Player player, PlayerController controller) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.18),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 1.5),
                ),
                child: ClipOval(
                  child: player.image != null && player.image!.isNotEmpty
                      ? Image.network(
                          player.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white70),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)));
                          },
                        )
                      : const Icon(Icons.person, color: Colors.white70),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name ?? "",
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${player.position} | ${player.team}",
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => controller.toggleFollow(player.id!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white12,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  elevation: 0,
                ),
                child: const Text("Unfollow", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
