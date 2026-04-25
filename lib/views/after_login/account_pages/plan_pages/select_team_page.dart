import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/model/response_model/plan_model.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/view_model/after_controller/plan_controller.dart';
import 'package:play_on_app/view_model/after_controller/home_contollers/home_controller.dart';
import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';
import 'package:play_on_app/repo/match_repository.dart';

class SelectTeamPage extends StatefulWidget {
  const SelectTeamPage({super.key});

  @override
  State<SelectTeamPage> createState() => _SelectTeamPageState();
}

class _SelectTeamPageState extends State<SelectTeamPage> {
  final PlanController planController = Get.find<PlanController>();
  final MatchRepository _matchRepo = MatchRepository();
  late Plan? selectedPlan;
  List<dynamic> allTeams = [];
  List<dynamic> filteredTeams = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String selectedFilter = "Sport"; // "Sport" or "Country"

  @override
  void initState() {
    super.initState();
    selectedPlan = Get.arguments as Plan?;
    _fetchTeams();
  }

  void _fetchTeams({String? search}) async {
    setState(() => isLoading = true);
    try {
      final res = await _matchRepo.getTeams(search: search);
      if (res['success'] == true) {
        setState(() {
          allTeams = res['teams'];
          _applyFilters();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _applyFilters() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredTeams = allTeams.where((team) {
        final nameMatches = (team['name'] ?? "").toString().toLowerCase().contains(query);
        final sportMatches = (team['sport'] ?? "").toString().toLowerCase().contains(query);
        final countryMatches = (team['country'] ?? "").toString().toLowerCase().contains(query);
        return nameMatches || sportMatches || countryMatches;
      }).toList();
      
      // If we want to sort or group by selectedFilter, we can do it here
      if (selectedFilter == "Sport") {
        filteredTeams.sort((a, b) => (a['sport'] ?? "").compareTo(b['sport'] ?? ""));
      } else {
        filteredTeams.sort((a, b) => (a['country'] ?? "").compareTo(b['country'] ?? ""));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWithOutImg(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                    Text("Select Your Team", style: text20(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppColors.white.withValues(alpha: 0.2)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => _applyFilters(),
                    style: text14(),
                    decoration: InputDecoration(
                      icon: const Icon(Icons.search, color: AppColors.white70),
                      hintText: "Search Team, Sport or Country",
                      hintStyle: text14(color: AppColors.white70),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ),

              // Filter Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _buildFilterButton("Sport"),
                    const SizedBox(width: 12),
                    _buildFilterButton("Country"),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  "Unlock all matches for your favorite team with this ${selectedPlan?.title ?? 'Pass'}.",
                  style: text12(color: AppColors.white70),
                ),
              ),
              
              const SizedBox(height: 10),
              
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : filteredTeams.isEmpty
                        ? Center(child: Text("No teams found", style: text14(color: AppColors.white70)))
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1.1,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: filteredTeams.length,
                            itemBuilder: (context, index) {
                              final team = filteredTeams[index];
                              return _buildTeamCard(team);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(String label) {
    bool isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
          _applyFilters();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: text14(
            color: isSelected ? Colors.white : AppColors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTeamCard(dynamic team) {
    return Obx(() {
      final isPurchased = planController.hasPurchasedItem(teamId: team['_id']);
      return GestureDetector(
        onTap: () {
          if (isPurchased) {
            Get.snackbar("Already Purchased", "You already have access to ${team['name']}");
          } else if (selectedPlan?.id != null) {
            planController.buyPlan(selectedPlan!.id!, teamId: team['_id']);
          }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: isPurchased ? AppColors.primary.withValues(alpha: 0.2) : AppColors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isPurchased ? AppColors.primary : AppColors.white.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.network(
                        team['logo'] ?? "",
                        height: 50,
                        width: 50,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.shield, color: AppColors.white70, size: 40),
                      ),
                      if (isPurchased)
                        const Positioned(
                          right: -5,
                          top: -5,
                          child: Icon(Icons.check_circle, color: AppColors.success, size: 20),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    team['name'] ?? "",
                    textAlign: TextAlign.center,
                    style: text14(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        (team['sport'] ?? "").toString().capitalizeFirst!,
                        style: text10(color: AppColors.primary),
                      ),
                      const SizedBox(width: 4),
                      Text("|", style: text10(color: AppColors.white24)),
                      const SizedBox(width: 4),
                      Text(
                        team['country'] ?? "",
                        style: text10(color: AppColors.white70),
                      ),
                    ],
                  ),
                  if (isPurchased)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text("(Purchased)", style: text10(color: AppColors.success, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
