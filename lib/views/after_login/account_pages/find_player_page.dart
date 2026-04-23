import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/model/response_model/player_model.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'dart:ui';

import 'package:play_on_app/view_model/after_controller/player_controller.dart';
import 'package:play_on_app/views/after_login/account_pages/followed_players_page.dart';
import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';

class SearchPlayersScreen extends StatefulWidget {
  const SearchPlayersScreen({super.key});

  @override
  State<SearchPlayersScreen> createState() => _SearchPlayersScreenState();
}

class _SearchPlayersScreenState extends State<SearchPlayersScreen> {
  final PlayerController _playerController = Get.find<PlayerController>();
  final TextEditingController _searchController = TextEditingController();

  final RxString selectedSport = "".obs;
  final RxString selectedCountry = "".obs;
  final RxString searchQuery = "".obs;

  void _onFilterChanged() {
    _playerController.fetchPlayers(
      search: searchQuery.value,
      sport: selectedSport.value,
      country: selectedCountry.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWithOutImg(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.white),
                      onPressed: () => Get.back(),
                    ),
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onSubmitted: (val) {
                                  searchQuery.value = val;
                                  _onFilterChanged();
                                },
                                decoration: const InputDecoration(
                                  hintText: "Search Players",
                                  hintStyle: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 16,
                                  ),
                                  border: InputBorder.none,
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                searchQuery.value = _searchController.text;
                                _onFilterChanged();
                              },
                              icon: const Icon(
                                Icons.search,
                                color: Colors.white70,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Dropdowns Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // Sport Dropdown
                    Expanded(
                      child: Obx(() {
                        var sports = _playerController.getAvailableSports();
                        return _buildDropdown(
                          hint: "Select Sport",
                          value: selectedSport.value.isEmpty ? null : selectedSport.value,
                          items: sports,
                          onChanged: (val) {
                            selectedSport.value = val ?? "";
                            selectedCountry.value = ""; // Reset country when sport changes
                            _onFilterChanged();
                          },
                        );
                      }),
                    ),
                    const SizedBox(width: 12),
                    // Country Dropdown
                    Expanded(
                      child: Obx(() {
                        var countries = _playerController.getAvailableCountries(selectedSport.value);
                        return _buildDropdown(
                          hint: "Select Country",
                          value: selectedCountry.value.isEmpty ? null : selectedCountry.value,
                          items: countries,
                          onChanged: (val) {
                            selectedCountry.value = val ?? "";
                            _onFilterChanged();
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.white12, thickness: 1),

              // Followed Players Section & Header
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       GestureDetector(
              //         onTap: () => Get.to(() => const FollowedPlayersScreen()),
              //         child: Text("Followed Players",
              //             style: text14(color: AppColors.primary, fontWeight: FontWeight.w600)),
              //       ),
              //       const SizedBox(height: 4),
              //       Text(
              //         "Keep your eyes on the game",
              //         style: text12(color: Colors.white38),
              //       ),
              //       const SizedBox(height: 20),
              //       Text("Available Players",
              //           style: text16(color: Colors.white, fontWeight: FontWeight.bold)),
              //     ],
              //   ),
              // ),

              // Players List
              Expanded(
                child: Obx(() {
                  if (_playerController.loading.value) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }

                  if (_playerController.playerList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.person_off_outlined, size: 64, color: Colors.white24),
                          const SizedBox(height: 16),
                          Text("No players found", style: text16(color: Colors.white38)),
                          TextButton(
                            onPressed: () {
                              _searchController.clear();
                              searchQuery.value = "";
                              selectedSport.value = "";
                              selectedCountry.value = "";
                              _onFilterChanged();
                            },
                            child: const Text("Clear Filters", style: TextStyle(color: AppColors.primary)),
                          )
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _playerController.playerList.length,
                    itemBuilder: (context, index) {
                      return _buildPlayerCard(_playerController.playerList[index]);
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

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: text12(color: Colors.white60)),
          isExpanded: true,
          dropdownColor: AppColors.secPrimary,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
          style: text14(color: Colors.white),
          items: [
            DropdownMenuItem<String>(
              value: "",
              child: Text("All ${hint.split(' ').last}", style: text14(color: Colors.white70)),
            ),
            ...items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item, style: text14()),
              );
            }),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildPlayerCard(Player player) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.18),
                width: 1.2,
              ),
            ),
            child: ExpansionTile(
              leading: Container(
                width: 50,
                height: 50,
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
                            return const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)));
                          },
                        )
                      : const Icon(Icons.person, color: Colors.white70),
                ),
              ),
              title: Text(
                player.name ?? "",
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "${player.position} | ${player.team}",
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              trailing: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(color: Colors.white12),
                      _detailRow("Sport", player.sport ?? "N/A"),
                      _detailRow("Team", player.team ?? "N/A"),
                      _detailRow("Country", player.country ?? "N/A"),
                      _detailRow("Bio", player.bio ?? "No bio available"),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Obx(() {
                            bool followed = _playerController.isFollowed(player.id);
                            return ElevatedButton(
                              onPressed: () => _playerController.toggleFollow(player.id!),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: followed ? Colors.grey.withOpacity(0.3) : AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                elevation: 0,
                              ),
                              child: Text(
                                followed ? "Unfollow" : "Follow",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text("$label:",
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
