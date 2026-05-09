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
import 'package:intl/intl.dart';

import 'package:flutter/services.dart';
import 'package:play_on_app/utils/custom_snakebar.dart';

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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            labelStyle: text16(fontWeight: FontWeight.bold),
            unselectedLabelStyle: text16(),
            tabs: const [
              Tab(text: "Refer and Earn"),
              Tab(text: "Your Referral"),
            ],
          ),
        ),
        body: BackgroundWithOutImg(
          child: TabBarView(
            children: [
              _buildReferAndEarn(controller),
              _buildYourReferral(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReferAndEarn(HomeController controller) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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

            // Reward Card
            Obx(() {
              if (controller.isOfferLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final offer = controller.referralOffer.value;
              if (offer == null) return const SizedBox.shrink();

              return _buildRewardCard(
                icon: Text(
                  offer.title?[0] ?? "R",
                  style: text24(
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                backgroundColor: AppColors.white.withValues(alpha: 0.12),
                title: offer.title ?? "Get a reward worth up to",
                amount: offer.discountType == 'percent'
                    ? "${offer.discountValue}% Off"
                    : "₹${offer.discountValue} Off",
                subtitle: "for every successful referral",
              );
            }),

            const SizedBox(height: 30),

            // Referral Code Box
            Obx(() {
              final code = controller.referralCode.value;
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Your Referral Code", style: text12(color: Colors.white60)),
                        const SizedBox(height: 4),
                        Text(code, style: text20(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.copy, color: Colors.white70),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: code));
                        showCustomSnackbar(
                          title: "Copied",
                          message: "Referral code copied to clipboard",
                          type: SnackType.success,
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white70),
                      onPressed: _shareReferral,
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 40),

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
    );
  }

  Widget _buildYourReferral(HomeController controller) {
    return Obx(() {
      if (controller.isVoucherLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.referralVouchers.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.card_giftcard, size: 80, color: Colors.white.withValues(alpha: 0.2)),
              const SizedBox(height: 16),
              Text("No referral vouchers yet", style: text16(color: Colors.white70)),
              const SizedBox(height: 8),
              Text("Invite friends to earn rewards", style: text14(color: Colors.white38)),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.referralVouchers.length,
        itemBuilder: (context, index) {
          final voucher = controller.referralVouchers[index];
          return _buildVoucherCard(voucher);
        },
      );
    });
  }

  Widget _buildVoucherCard(dynamic voucher) {
    final expiryDate = voucher.validTill != null 
        ? DateFormat("d MMM yyyy").format(DateTime.parse(voucher.validTill))
        : "N/A";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  voucher.title ?? "Referral Reward",
                  style: text16(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  voucher.discountType == 'percent' 
                      ? "${voucher.discountValue}% OFF" 
                      : "₹${voucher.discountValue} OFF",
                  style: text12(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Voucher Code", style: text10(color: Colors.white60)),
                  const SizedBox(height: 4),
                  Text(
                    voucher.code ?? "N/A",
                    style: text18(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: voucher.code ?? ""));
                  showCustomSnackbar(
                    title: "Copied",
                    message: "Voucher code copied!",
                    type: SnackType.success,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: Text("COPY", style: text12(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Divider(height: 24, color: Colors.white10),
          Row(
            children: [
              Icon(Icons.info_outline, size: 14, color: Colors.white38),
              const SizedBox(width: 4),
              Text(
                "Valid until: $expiryDate",
                style: text12(color: Colors.white38),
              ),
              const Spacer(),
              Text(
                voucher.usedCount >= voucher.usageLimit ? "USED" : "AVAILABLE",
                style: text12(
                  fontWeight: FontWeight.bold,
                  color: voucher.usedCount >= voucher.usageLimit ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
        ],
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

  // Widget _buildRewardCard({
  //   required Widget icon,
  //   required Color backgroundColor,
  //   required String title,
  //   required String amount,
  //   required String subtitle,
  // }) {
  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: backgroundColor,
  //       borderRadius: BorderRadius.circular(16),
  //     ),
  //     child: Row(
  //       children: [
  //         // Icon Circle
  //         Container(
  //           width: 48,
  //           height: 48,
  //           decoration: BoxDecoration(
  //             color: Colors.white,
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //           child: Center(child: icon),
  //         ),
  //         const SizedBox(width: 16),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 title,
  //                 style: const TextStyle(fontSize: 15, color: Colors.white70),
  //               ),
  //               const SizedBox(height: 4),
  //               Text(
  //                 amount,
  //                 style: const TextStyle(
  //                   fontSize: 22,
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.white,
  //                 ),
  //               ),
  //               const SizedBox(height: 4),
  //               Text(
  //                 subtitle,
  //                 style: const TextStyle(fontSize: 15, color: Colors.white70),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
