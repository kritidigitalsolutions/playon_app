import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/routes/app_routes.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/utils/custom_button.dart';
import 'dart:ui';

import 'package:play_on_app/view_model/after_controller/plan_controller.dart';
import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';

import '../../../../data/api_responce_data.dart';
import '../../../../model/response_model/subscription_model.dart';

class AccessPlansScreen extends StatelessWidget {
  AccessPlansScreen({super.key});

  final PlanController controller = Get.find<PlanController>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: BackgroundWithOutImg(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        "Access & Plans",
                        style: text24(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Choose how you want to watch,\nfull access or just a match",
                            style: text15(color: AppColors.textSecondary),
                          ),
                          GestureDetector(
                            onTap: () => Get.toNamed(AppRoutes.purchasedItems),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.inventory_2_outlined, size: 16, color: AppColors.textPrimary),
                                  const SizedBox(width: 8),
                                  Text("My Passes", style: text12(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                TabBar(
                  indicatorColor: AppColors.primary,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.white70,
                  tabs: const [
                    Tab(text: "Plans"),
                    Tab(text: "My Plan"),
                    Tab(text: "History"),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildPlansTab(),
                      _buildMySubscriptionTab(),
                      _buildHistoryTab(),
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

  Widget _buildPlansTab() {
    return Obx(() {
      if (controller.isPaymentProcessing.value) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text("Processing Payment...", style: TextStyle(color: Colors.white)),
            ],
          ),
        );
      }
      switch (controller.planList.value.status) {
        case Status.loading:
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        case Status.error:
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Error: ${controller.planList.value.message}", style: const TextStyle(color: Colors.white)),
                ElevatedButton(
                  onPressed: () => controller.fetchPlans(),
                  child: const Text("Retry"),
                )
              ],
            ),
          );
        case Status.completed:
          final plans = controller.planList.value.data?.plans ?? [];
          return Column(
            children: [
              _buildPromoCodeField(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: plans.length,
                  itemBuilder: (context, index) {
                    final plan = plans[index];
                    final isActive = controller.isPlanActive(plan.id, slug: plan.slug);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _buildPlanCard(
                        title: plan.title ?? "",
                        price: "${plan.currency == 'INR' ? '₹' : plan.currency}${plan.price} / ${plan.billingType}",
                        features: plan.features ?? [],
                        buttonText: isActive ? "Purchased" : (plan.buttonText ?? "Unlock Now"),
                        isPrimary: index == 0,
                        onTap: isActive
                            ? () {}
                            : () {
                                if (plan.slug == "one-match-pass" || plan.buttonText == "Choose The Match") {
                                  Get.toNamed(AppRoutes.chooseMatch, arguments: plan);
                                } else if (plan.buttonText == "Choose The Team") {
                                  Get.toNamed(AppRoutes.selectTeam, arguments: plan);
                                } else if (plan.buttonText == "Choose The Series") {
                                  Get.toNamed(AppRoutes.selectSeries, arguments: plan);
                                } else {
                                  if (plan.id != null) {
                                    controller.buyPlan(plan.id!, promoCode: controller.isPromoApplied.value ? controller.appliedPromoCode.value : null);
                                  }
                                }
                              },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        default:
          return const SizedBox();
      }
    });
  }

  Widget _buildPromoCodeField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Have a Promo Code?", style: text14(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.promoController,
                  style: text14(),
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: "Enter coupon code ",
                    hintStyle: text14(color: AppColors.white70),
                    filled: true,
                    fillColor: AppColors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.white.withOpacity(0.1)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.white.withOpacity(0.1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Obx(() => controller.isPromoApplied.value
                  ? IconButton(
                      onPressed: controller.removePromoCode,
                      icon: const Icon(Icons.cancel, color: AppColors.error),
                    )
                  : ElevatedButton(
                      onPressed: controller.applyPromoCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: Text("Apply", style: text14(fontWeight: FontWeight.bold)),
                    )),
            ],
          ),
          Obx(() => controller.isPromoApplied.value
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    "Promo code '${controller.appliedPromoCode.value}' applied!",
                    style: text12(color: AppColors.success),
                  ),
                )
              : const SizedBox()),
          
          // Available Promos List
          // Obx(() {
          //   if (controller.availablePromos.isEmpty) return const SizedBox();
          //   return Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       const SizedBox(height: 12),
          //       Text("Available Offers:", style: text12(color: AppColors.white70, fontWeight: FontWeight.bold)),
          //       const SizedBox(height: 8),
          //       SizedBox(
          //         height: 40,
          //         child: ListView.builder(
          //           scrollDirection: Axis.horizontal,
          //           itemCount: controller.availablePromos.length,
          //           itemBuilder: (context, index) {
          //             final promo = controller.availablePromos[index];
          //             final code = promo['code'] ?? "";
          //             return GestureDetector(
          //               onTap: () {
          //                 controller.promoController.text = code;
          //                 controller.applyPromoCode();
          //               },
          //               child: Container(
          //                 margin: const EdgeInsets.only(right: 8),
          //                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          //                 decoration: BoxDecoration(
          //                   color: AppColors.primary.withValues(alpha: 0.1),
          //                   borderRadius: BorderRadius.circular(20),
          //                   border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          //                 ),
          //                 child: Row(
          //                   children: [
          //                     const Icon(Icons.local_offer_outlined, size: 14, color: AppColors.primary),
          //                     const SizedBox(width: 6),
          //                     Text(code, style: text12(color: AppColors.primary, fontWeight: FontWeight.bold)),
          //                   ],
          //                 ),
          //               ),
          //             );
          //           },
          //         ),
          //       ),
          //     ],
          //   );
          // }),
        ],
      ),
    );
  }

  Widget _buildMySubscriptionTab() {
    return Obx(() {
      switch (controller.mySubscription.value.status) {
        case Status.loading:
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        case Status.error:
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Error: ${controller.mySubscription.value.message}", style: const TextStyle(color: Colors.white)),
                ElevatedButton(
                  onPressed: () => controller.fetchMySubscription(),
                  child: const Text("Retry"),
                )
              ],
            ),
          );
        case Status.completed:
          final subs = controller.mySubscription.value.data?.subscriptions ?? [];
          if (subs.isEmpty) {
            return const Center(
              child: Text("No active subscription found", style: TextStyle(color: Colors.white70)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: subs.length,
            itemBuilder: (context, index) {
              final sub = subs[index];
              return Column(
                children: [
                  _buildSubscriptionCard(sub, isActive: true),
                  const SizedBox(height: 12),
                  if (sub.status == 'active')
                    AppButton(
                      height: 40,
                      title: "Cancel Subscription",
                      color: AppColors.error,
                      onTap: () {
                        Get.dialog(
                          AlertDialog(
                            backgroundColor: Colors.grey[900],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: Text("Cancel Subscription", style: text18(fontWeight: FontWeight.bold)),
                            content: Text(
                              "Are you sure you want to cancel this subscription? You will still have access until the end of the current billing period.",
                              style: text14(color: AppColors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: Text("No", style: text14(color: AppColors.white)),
                              ),
                              TextButton(
                                onPressed: () {
                                  Get.back();
                                  if (sub.id != null) {
                                    controller.cancelSubscription(sub.id!);
                                  }
                                },
                                child: Text("Yes, Cancel", style: text14(color: AppColors.error, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 20),
                ],
              );
            },
          );
        default:
          return const SizedBox();
      }
    });
  }

  Widget _buildHistoryTab() {
    return Obx(() {
      switch (controller.subscriptionHistory.value.status) {
        case Status.loading:
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        case Status.error:
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Error: ${controller.subscriptionHistory.value.message}", style: const TextStyle(color: Colors.white)),
                ElevatedButton(
                  onPressed: () => controller.fetchSubscriptionHistory(),
                  child: const Text("Retry"),
                )
              ],
            ),
          );
        case Status.completed:
          final subs = controller.subscriptionHistory.value.data?.subscriptions ?? [];
          if (subs.isEmpty) {
            return const Center(child: Text("No history found", style: TextStyle(color: Colors.white70)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: subs.length,
            itemBuilder: (context, index) {
              final sub = subs[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildSubscriptionCard(sub),
              );
            },
          );
        default:
          return const SizedBox();
      }
    });
  }

  Widget _buildSubscriptionCard(Subscription sub, {bool isActive = false}) {
    final plan = sub.planId;
    String subTitle = plan?.title ?? "Unknown Plan";
    if (sub.seriesId != null) {
      subTitle += " (Series)";
    } else if (sub.matchId != null) {
      subTitle += " (Match)";
    } else if (sub.teamId != null) {
      subTitle += " (Team)";
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: sub.status == 'active' ? AppColors.success.withValues(alpha: 0.5) : AppColors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(subTitle, style: text16(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(sub.status ?? "").withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  sub.status?.toUpperCase() ?? "",
                  style: text12(color: _getStatusColor(sub.status ?? ""), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text("Amount Paid: ${plan?.currency == 'INR' ? '₹' : plan?.currency ?? ''}${sub.amountPaid}", style: text14(color: AppColors.white70)),
          const SizedBox(height: 4),
          Text("Valid until: ${_formatDate(sub.endDate)}", style: text14(color: AppColors.white70)),
          const SizedBox(height: 8),
          if (!isActive && sub.isDeleted == false && sub.status != 'active')
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  if (sub.id != null) {
                    controller.deleteSubscription(sub.id!);
                  }
                },
                child: const Text("Delete from history", style: TextStyle(color: AppColors.error, fontSize: 12)),
              ),
            )
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'cancelled':
        return AppColors.warning;
      case 'expired':
        return AppColors.error;
      default:
        return AppColors.white70;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "N/A";
    try {
      final date = DateTime.parse(dateStr);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required List<String> features,
    required String buttonText,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isPrimary
                ? AppColors.primary.withValues(alpha: 0.4)
                : AppColors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isPrimary
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : AppColors.white.withValues(alpha: 0.18),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: text18(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                price,
                style: text24(
                  color: isPrimary ? AppColors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              ...features.map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(feature, style: text14())),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CustomElevatedIconButton(
                text: buttonText,
                icon: Icons.lock_open_outlined,
                onPressed: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
