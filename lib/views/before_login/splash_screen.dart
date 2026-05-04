import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/res/app_image.dart';
import 'package:play_on_app/routes/app_routes.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';

import 'package:play_on_app/utils/hive_service/hive_service.dart';

// ==================== SPLASH / ONBOARDING SCREEN ====================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  // Navigate after 3 seconds
  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // If the current route is no longer the splash screen, it means 
    // a deep link or another navigation has already occurred.
    if (Get.currentRoute != AppRoutes.splashScreen) {
      return;
    }

    // Go to Home Screen by default without requiring login
    Get.offAllNamed(AppRoutes.myHomePage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWithImg(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(AppImage.logo),

              Text(
                "Live matches, real-time action, and everything sports ",
                style: text16(),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                "all in one place ",
                style: text18(color: AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
