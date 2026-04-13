// ==================== OTP VERIFICATION SCREEN ====================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/routes/app_routes.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/utils/custom_button.dart';
import 'package:play_on_app/view_model/before_controller/auth_controller.dart';
import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';

class OtpVerifyScreen extends StatelessWidget {
  OtpVerifyScreen({super.key});

  final VerifyOtpController ctr = Get.put(VerifyOtpController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BackgroundWithImg(child: SizedBox.shrink()),
          Positioned(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  

                  // Enhanced Header Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // App Logo or Icon
                      // Container(
                      //   height: 60,
                      //   width: 60,
                      //   decoration: BoxDecoration(
                      //     color: AppColors.primary.withValues(alpha: 0.3),
                      //     borderRadius: BorderRadius.circular(16),
                      //   ),
                      //   child: Icon(
                      //     Icons.sports_cricket,
                      //     size: 32,
                      //     color: AppColors.primary,
                      //   ),
                      // ),

                      const SizedBox(height: 32),

                      // Main Heading
                      Text(
                        "Verify Your Number",
                        style: text24(
                          fontWeight: FontWeight.bold,
                        ).copyWith(fontSize: 32, height: 1.2),
                      ),

                      const SizedBox(height: 12),

                      // Subheading
                      Text(
                        "Enter the 6-digit code sent to your phone",
                        style: text24(fontWeight: FontWeight.normal).copyWith(
                          fontSize: 16,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // OTP Fields
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      6,
                      (index) => Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.white24,
                            width: 1.2,
                          ),
                        ),
                        child: KeyboardListener(
                          focusNode: FocusNode(), // required
                          onKeyEvent: (event) {
                            // Only handle key down events
                            if (event is KeyDownEvent) {
                              if (event.logicalKey ==
                                  LogicalKeyboardKey.backspace) {
                                final text = ctr.otpCtrls[index].text;
                                if (text.isNotEmpty) {
                                  ctr.otpCtrls[index].clear();
                                } else if (index > 0) {
                                  ctr.focusNodes[index - 1].requestFocus();
                                  ctr.otpCtrls[index - 1].clear();
                                }
                              }
                            }
                          },
                          child: TextField(
                            controller: ctr.otpCtrls[index],
                            focusNode: ctr.focusNodes[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            style: text18(),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              counterText: "",
                              border: InputBorder.none,
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                // Keep only last character
                                ctr.otpCtrls[index].text =
                                    value[value.length - 1];
                                ctr.otpCtrls[index].selection =
                                    TextSelection.fromPosition(
                                      TextPosition(
                                        offset: ctr.otpCtrls[index].text.length,
                                      ),
                                    );

                                // Move to next empty field
                                for (
                                  int i = index + 1;
                                  i < ctr.otpCtrls.length;
                                  i++
                                ) {
                                  if (ctr.otpCtrls[i].text.isEmpty) {
                                    ctr.focusNodes[i].requestFocus();
                                    break;
                                  }
                                }
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  AppButton(
                    radius: 8,
                    title: "Verify OTP",
                    onTap: () {
                      final isValidate = ctr.validateOtp();

                      if (!isValidate) {
                        return;
                      }
                      Get.toNamed(AppRoutes.fullnameEnter);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
