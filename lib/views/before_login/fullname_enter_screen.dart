import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/routes/app_routes.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/utils/custom_button.dart';
import 'package:play_on_app/utils/custom_snakebar.dart';
import 'package:play_on_app/utils/custom_text_fields.dart';
import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';

class FullNameScreen extends StatefulWidget {
  const FullNameScreen({super.key});

  @override
  State<FullNameScreen> createState() => _FullNameScreenState();
}

class _FullNameScreenState extends State<FullNameScreen> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool get isValid => _nameController.text.trim().length >= 3;

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (isValid) {
      String fullName = _nameController.text.trim();

      showCustomSnackbar(
        title: "Welcome!",
        message: "Hi, $fullName 👋",
        type: SnackType.success,
      );

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
              // Top Header Section with Glass Effect
              // Container(
              //   padding: const EdgeInsets.symmetric(
              //     horizontal: 24,
              //     vertical: 20,
              //   ),
              //   decoration: BoxDecoration(
              //     gradient: LinearGradient(
              //       begin: Alignment.topCenter,
              //       end: Alignment.bottomCenter,
              //       colors: [Colors.black.withOpacity(0.3), Colors.transparent],
              //     ),
              //   ),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       // Progress Indicator
              //       Row(
              //         children: [
              //           Expanded(
              //             child: Container(
              //               height: 4,
              //               decoration: BoxDecoration(
              //                 borderRadius: BorderRadius.circular(2),
              //                 gradient: LinearGradient(
              //                   colors: [
              //                     AppColors.primary,
              //                     AppColors.primary.withOpacity(0.5),
              //                   ],
              //                 ),
              //               ),
              //             ),
              //           ),
              //           const SizedBox(width: 8),
              //           Expanded(
              //             child: Container(
              //               height: 4,
              //               decoration: BoxDecoration(
              //                 borderRadius: BorderRadius.circular(2),
              //                 color: Colors.white.withOpacity(0.2),
              //               ),
              //             ),
              //           ),
              //           const SizedBox(width: 8),
              //           Expanded(
              //             child: Container(
              //               height: 4,
              //               decoration: BoxDecoration(
              //                 borderRadius: BorderRadius.circular(2),
              //                 color: Colors.white.withOpacity(0.2),
              //               ),
              //             ),
              //           ),
              //         ],
              //       ),
              //       const SizedBox(height: 24),

              //       // Step Counter
              //       Container(
              //         padding: const EdgeInsets.symmetric(
              //           horizontal: 12,
              //           vertical: 6,
              //         ),
              //         decoration: BoxDecoration(
              //           color: AppColors.primary.withOpacity(0.2),
              //           borderRadius: BorderRadius.circular(20),
              //           border: Border.all(
              //             color: AppColors.primary.withOpacity(0.3),
              //             width: 1,
              //           ),
              //         ),
              //         child: Text(
              //           "Step 1 of 3",
              //           style: text14(
              //             color: AppColors.primary,
              //             fontWeight: FontWeight.w600,
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),

                      // Icon with Glass Effect
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

                      // Title with Gradient
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [Colors.white, Colors.white.withOpacity(0.9)],
                        ).createShader(bounds),
                        child: Text(
                          "What's your full name?",
                          style: text24(
                            fontWeight: FontWeight.bold,
                          ).copyWith(fontSize: 32),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        "This will be displayed on your profile",
                        style: text16(color: AppColors.white70),
                      ),

                      const SizedBox(height: 50),

                      // Input Label
                      Text(
                        "Full Name",
                        style: text14(
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Modern Glass Input Field
                      AppTextField(
                        radius: 8,
                        controller: _nameController,
                        hintText: "Enter your full name",
                      ),

                      const SizedBox(height: 16),

                      // Helper Text
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

                      // Continue Button
                      AppButton(title: "Next", onTap: _onContinue),

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
