import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/view_model/before_controller/auth_controller.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/routes/app_routes.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/utils/custom_button.dart';
import 'package:play_on_app/utils/custom_snakebar.dart';
import 'package:play_on_app/utils/custom_text_fields.dart';
import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';

class FullNameScreen extends StatelessWidget {
  FullNameScreen({super.key});

  final AuthController ctr = Get.find<AuthController>();

  bool get isValid => ctr.nameController.text.trim().length >= 3;
  bool isLoading = false;

  void _onContinue() {
    if (isValid) {
      Get.toNamed(AppRoutes.sportInterrestScreen);
    } else {
      showCustomSnackbar(
        title: "Invalid Name",
        message: "Please enter your full name (at least 3 characters)",
        type: SnackType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWithImg(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary.withOpacity(0.3),
                              AppColors.primary.withOpacity(0.1),
                            ],
                          ),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Icon(
                              Icons.person_outline_rounded,
                              color: AppColors.primary,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        "What's your full name?",
                        style: text24(
                          fontWeight: FontWeight.bold,
                        ).copyWith(fontSize: 32),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "This will be displayed on your profile",
                        style: text16(color: AppColors.white70),
                      ),
                      const SizedBox(height: 50),
                      Text(
                        "Full Name",
                        style: text14(
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        radius: 8,
                        controller: ctr.nameController,
                        hintText: "Enter your full name",
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: AppColors.white70,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Minimum 3 characters required",
                            style: text12(color: AppColors.white70),
                          ),
                        ],
                      ),
                      const SizedBox(height: 50),
                      AppButton(
                        title: "Next",
                        isLoading: isLoading,
                        onTap: _onContinue,
                      ),
                      const SizedBox(height: 40),
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
