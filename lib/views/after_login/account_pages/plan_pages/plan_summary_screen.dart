import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/model/response_model/plan_model.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/utils/custom_button.dart';
import 'package:play_on_app/view_model/after_controller/plan_controller.dart';
import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';

class PlanSummaryScreen extends StatelessWidget {
  PlanSummaryScreen({super.key});

  final PlanController controller = Get.find<PlanController>();
  final Plan plan = Get.arguments as Plan;

  @override
  Widget build(BuildContext context) {
    String displayTitle = plan.title ?? "Subscription Plan";
    String displayPrice = "${plan.currency == 'INR' ? '₹' : plan.currency ?? '₹'}${plan.price}";
    
    // Check for Apple localized price if available
    if (plan.slug != null) {
      final appleId = PlanController.slugToAppleIdMap[plan.slug] ?? plan.slug!;
      if (controller.iapProducts.containsKey(appleId)) {
        displayPrice = controller.iapProducts[appleId]!.price;
      }
    }

    return Scaffold(
      body: BackgroundWithOutImg(
        child: SafeArea(
          child: Column(
            children: [
              // Custom Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                        onPressed: () => Get.back(),
                      ),
                    ),
                    Text(
                      "Plan Summary",
                      style: text20(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      
                      // Plan Detail Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A1227).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Ticket Icon Container
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF0055FF), Color(0xFF0033AA)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.confirmation_num_outlined, color: Colors.white, size: 28),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        displayTitle,
                                        style: text18(fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            displayPrice,
                                            style: text20(fontWeight: FontWeight.bold, color: Colors.white),
                                          ),
                                          if (plan.billingType != null && plan.billingType != "null")
                                            Text(
                                              " / ${plan.billingType!.toLowerCase()}",
                                              style: text14(color: Colors.white70),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Divider(color: Colors.white.withOpacity(0.1)),
                            const SizedBox(height: 20),
                            Text(
                              "What's included:",
                              style: text16(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            ...?plan.features?.map((feature) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 22),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          feature,
                                          style: text14(color: Colors.white.withOpacity(0.9)),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Billing Section
                      Text(
                        "Billing",
                        style: text16(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A1227).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.apple, color: Colors.white, size: 32),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("App Store Billing", style: text15(fontWeight: FontWeight.w600, color: Colors.white)),
                                  Text("Charged to your Apple ID", style: text13(color: Colors.white60)),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Subscribe Button
                      Obx(() => SubscribeAppleButton(
                            isLoading: controller.isPaymentProcessing.value,
                            onPressed: () {
                              if (plan.id != null) {
                                controller.buyPlan(plan.id!);
                              }
                            },
                          )),
                      
                      const SizedBox(height: 20),
                      
                      // Legal Disclaimer
                      Text(
                        "Payment will be charged to your Apple ID at confirmation of purchase. Subscription renews automatically unless canceled at least 24 hours before the end of the current period. Manage or cancel in Settings.",
                        textAlign: TextAlign.center,
                        style: text12(color: Colors.white54).copyWith(height: 1.4),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Footer Links
                      Center(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () => controller.restorePurchases(),
                              child: Text("Restore Purchases", style: text14(color: const Color(0xFF0084FF), fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () => Get.toNamed("/termsConditions"),
                                  child: Text("Terms of Use", style: text13(color: const Color(0xFF0084FF))),
                                ),
                                Text("  •  ", style: text13(color: Colors.white38)),
                                GestureDetector(
                                  onTap: () => Get.toNamed("/privacyPolicy"),
                                  child: Text("Privacy Policy", style: text13(color: const Color(0xFF0084FF))),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
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
