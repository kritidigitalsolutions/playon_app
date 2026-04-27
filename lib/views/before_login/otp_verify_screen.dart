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

  final AuthController ctr = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BackgroundWithImg(child: const SizedBox.shrink()),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 100),
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

                    const SizedBox(height: 40),

                    // OTP Fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        6,
                        (index) => Container(
                          width: 45,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.white24,
                              width: 1.2,
                            ),
                          ),
                          child: TextField(
                            onChanged: (value) {
                              if (value.length == 1 && index < 5) {
                                FocusScope.of(context).nextFocus();
                              }
                              if (value.isEmpty && index > 0) {
                                FocusScope.of(context).previousFocus();
                              }
                              // Collect OTP
                              List<String> currentOtp = ctr.otpController.text.split('');
                              if (currentOtp.length <= index) {
                                currentOtp.addAll(List.filled(index - currentOtp.length + 1, ''));
                              }
                              currentOtp[index] = value;
                              ctr.otpController.text = currentOtp.join();
                            },
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
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    Obx(() => AppButton(
                      radius: 8,
                      title: ctr.isLoading.value ? "Verifying..." : "Verify OTP",
                      onTap: () {
                        ctr.verifyOtp();
                      },
                    )),

                    const SizedBox(height: 24),

                    Obx(() => Center(
                      child: GestureDetector(
                        onTap: ctr.resendSeconds.value == 0 ? () => ctr.sendOtp() : null,
                        child: Text(
                          ctr.resendSeconds.value == 0
                              ? "Resend OTP"
                              : "Resend OTP in ${ctr.resendSeconds.value}s",
                          style: text16(
                            fontWeight: FontWeight.w600,
                            color: ctr.resendSeconds.value == 0
                                ? AppColors.primary
                                : Colors.grey,
                          ),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
