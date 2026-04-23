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

class AccessPlansScreen extends StatelessWidget {
  AccessPlansScreen({super.key});

  final PlanController controller = Get.put(PlanController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    Text(
                      "Choose how you want to watch,\nfull access or just a match",
                      style: text15(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Obx(() {
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
                            Text("Error: ${controller.planList.value.message}"),
                            ElevatedButton(
                              onPressed: () => controller.fetchPlans(),
                              child: const Text("Retry"),
                            )
                          ],
                        ),
                      );
                    case Status.completed:
                      final plans = controller.planList.value.data?.plans ?? [];
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: plans.length,
                        itemBuilder: (context, index) {
                          final plan = plans[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: _buildPlanCard(
                              title: plan.title ?? "",
                              price:
                                  "${plan.currency == 'INR' ? '₹' : plan.currency}${plan.price} / ${plan.billingType}",
                              features: plan.features ?? [],
                              buttonText: plan.buttonText ?? "Unlock Now",
                              isPrimary: index == 0,
                              onTap: () {
                                if (plan.buttonText == "Choose the Match") {
                                  Get.toNamed(AppRoutes.chooseMatch);
                                } else {
                                  if (plan.id != null) {
                                    controller.buyPlan(plan.id!);
                                  }
                                }
                              },
                            ),
                          );
                        },
                      );
                    default:
                      return const SizedBox();
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
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
