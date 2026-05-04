import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/utils/custom_button.dart';
import 'package:play_on_app/utils/hive_service/hive_service.dart';
import 'package:play_on_app/view_model/after_controller/home_contollers/home_controller.dart';
import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/services.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  Future<void> _openWhatsApp() async {
    final controller = Get.find<HomeController>();
    final referralCode = controller.referralCode.value;

    final text = "Hey! Join me on PlayOn App to watch live sports and matches. "
        "Use my referral code: $referralCode to get an exclusive 50% discount on your first match pass! 🏏⚽\n"
        "Download now: https://playon.com/download?ref=$referralCode";

    final url = Uri.parse(
      "https://wa.me/?text=${Uri.encodeComponent(text)}",
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not open WhatsApp");
    }
  }

  void _shareReferral() {
    final controller = Get.find<HomeController>();
    final referralCode = controller.referralCode.value;

    final text = "Hey! Join me on PlayOn App to watch live sports and matches. "
        "Use my referral code: $referralCode to get an exclusive 50% discount on your first match pass! 🏏⚽\n"
        "Download now: https://playon.com/download?ref=$referralCode";

    Share.share(text, subject: 'Join PlayOn and watch Live Sports!');
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    return Scaffold(
      body: BackgroundWithOutImg(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Icon
                Image.asset("assets/images/next.png", fit: BoxFit.cover),

                const SizedBox(height: 40),

                // Main Title
                Text(
                  "Earn Rewards\nfor Every Friend\nYou Invite",

                  style: text30(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                // Subtitle
                Text(
                  "Share the game with your friends and\nget exciting rewards when they join",

                  style: text16(color: AppColors.white70),
                ),

                const SizedBox(height: 50),

                // Referral Code Display
                Obx(() {
                  if (controller.isReferralLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.referralCode.value.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Your Referral Code",
                              style: text12(color: AppColors.white70),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              controller.referralCode.value,
                              style: text20(
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, color: AppColors.white),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: controller.referralCode.value));
                            Get.snackbar(
                              "Copied",
                              "Referral code copied to clipboard",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.green.withValues(alpha: 0.8),
                              colorText: Colors.white,
                              margin: const EdgeInsets.all(16),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }),

                // Reward 1 - Amazon Voucher
                _buildRewardCard(
                  icon: Text(
                    "a",
                    style: text30(
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  backgroundColor: AppColors.white.withValues(alpha: 0.12),
                  title: "Get an Amazon voucher worth up to",
                  amount: "₹100",
                  subtitle: "for every successful referral",
                ),

                const SizedBox(height: 16),

                // Reward 2 - 50% Discount
                _buildRewardCard(
                  icon: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE11D48), // Red
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        "P",
                        style: text20(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  backgroundColor: AppColors.white.withValues(alpha: 0.12),
                  title: "Your friends enjoy an exclusive",
                  amount: "50%",
                  subtitle: "discount on their first match pass",
                ),

                const SizedBox(height: 60),

                // Invite Button
                SizedBox(
                  width: double.infinity,
                  child: CustomElevatedIconButton(
                    borderRadius: 8,
                    text: "Invite via WhatsApp",
                    icon: Icons.chat,
                    onPressed: () {
                      _openWhatsApp();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRewardCard({
    required Widget icon,
    required Color backgroundColor,
    required String title,
    required String amount,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Icon Circle
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: icon),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 15, color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 15, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
