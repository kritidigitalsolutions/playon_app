import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/routes/app_routes.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/utils/custom_button.dart';
import 'package:play_on_app/views/custom_background.dart/custom_widget.dart'; // Your color file

class SportsInterestScreen extends StatefulWidget {
  const SportsInterestScreen({super.key});

  @override
  State<SportsInterestScreen> createState() => _SportsInterestScreenState();
}

class _SportsInterestScreenState extends State<SportsInterestScreen> {
  final List<SportItem> sports = [
    SportItem(name: "Cricket", image: "assets/auth/cri.png", isSelected: false),
    SportItem(
      name: "Football",
      image: "assets/auth/football.png",
      isSelected: false,
    ),
    SportItem(
      name: "Basketball",
      image: "assets/auth/basketball.jpg",
      isSelected: false,
    ),
    SportItem(
      name: "Tennis",
      image: "assets/auth/tennis.jpg",
      isSelected: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWithImg(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "What Do You\nLove Watching?",
                  textAlign: TextAlign.center,
                  style: text24(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Choose your favorite sports to\npersonalize your feed",
                  textAlign: TextAlign.center,
                  style: text16(),
                ),
                const SizedBox(height: 40),

                // Sports Grid
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.05,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: sports.length,
                    itemBuilder: (context, index) {
                      return SportCard(
                        sport: sports[index],
                        onTap: () {
                          setState(() {
                            sports[index].isSelected =
                                !sports[index].isSelected;
                          });
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Save & Continue Button
                AppButton(
                  title: "Save & Continue",
                  onTap: () {
                    // TODO: Save selected sports and navigate
                    final selected = sports.where((s) => s.isSelected).toList();
                    print("Selected Sports: ${selected.map((e) => e.name)}");
                    Get.offAllNamed(AppRoutes.myHomePage);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Sport Model
class SportItem {
  final String name;
  final String image;
  bool isSelected;

  SportItem({required this.name, required this.image, this.isSelected = false});
}

// Beautiful Sport Card
class SportCard extends StatelessWidget {
  final SportItem sport;
  final VoidCallback onTap;

  const SportCard({super.key, required this.sport, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: sport.isSelected
              ? Border.all(color: AppColors.primary, width: 3)
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Sport Image
              Image.asset(
                sport.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.error_outline,
                      color: AppColors.white24,
                      size: 40,
                    ),
                  );
                },
              ),

              // Dark Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.75),
                    ],
                  ),
                ),
              ),

              // Sport Name at Bottom
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Text(
                  sport.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Selection Checkmark
              if (sport.isSelected)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
