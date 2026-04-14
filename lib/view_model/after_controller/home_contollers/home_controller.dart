import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/routes/app_routes.dart';
import 'package:play_on_app/utils/app_text_style.dart';

class HomeController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changeIndex(int index) {
    currentIndex.value = index;
  }

  var isLogin = false.obs;

  void toggleLogin() {
    isLogin.value = !isLogin.value;
  }

  void handleProtectedAction(VoidCallback onSuccess) {
    if (isLogin.value) {
      print("isLogin true  ${isLogin.value}");
      onSuccess();
    } else {
      print(isLogin.value);
      _showLoginBottomSheet();
    }
  }

  // tab

  final RxInt selectedTabIndex = 0.obs;

  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  final List<String> tabs = [
    "Home",
    "Cricket",
    "Football",
    "Tennis",
    "Sports",
    "Basketball",
    "Hockey",
    "Badminton",
  ];

  void _showLoginBottomSheet() {
    Get.bottomSheet(
      Container(
        width: double.infinity, // Full width
        padding: const EdgeInsets.fromLTRB(
          20,
          40,
          20,
          30,
        ), // More top padding for notch area
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.7),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "You're not logged in",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Please login to continue",
              style: TextStyle(color: AppColors.white70, fontSize: 15),
            ),
            const SizedBox(height: 32),

            // Full width Login Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.toNamed(AppRoutes.login);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Login",
                  style: text16(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: () => Get.back(),
              child: Text("Cancel", style: text15()),
            ),
          ],
        ),
      ),
      // Important settings for full width + top notch
      backgroundColor: Colors.transparent, // Important
      barrierColor: Colors.black.withOpacity(0.7),
      isScrollControlled: false,
      // useSafeArea: false,                    // ← This allows it to go into the notch
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }
}
