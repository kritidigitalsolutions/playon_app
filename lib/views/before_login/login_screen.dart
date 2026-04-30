import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/routes/app_routes.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/utils/custom_button.dart';
import 'package:play_on_app/utils/custom_text_fields.dart';
import 'package:play_on_app/view_model/before_controller/auth_controller.dart';
import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final AuthController ctr = Get.put(AuthController());

  Widget _socialLoginButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: color,
          border: color == Colors.white ? Border.all(color: Colors.grey.shade300) : null,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(icon, color: Colors.red, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: text14(fontWeight: FontWeight.bold).copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWithImg(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Form(
              key: ctr.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Main Heading
                  Text(
                    "Get Started",
                    style: text24(
                      fontWeight: FontWeight.bold,
                    ).copyWith(fontSize: 32, height: 1.2),
                  ),

                  const SizedBox(height: 12),

                  // Subheading
                  Text(
                    "Enter your mobile number to continue",
                    style: text24(fontWeight: FontWeight.normal).copyWith(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Mobile Number Input
                  NumberTextField(
                    radius: 8,
                    maxLength: 10,
                    controller: ctr.mobileController,
                    hintText: "Enter Your Mobile Number",
                  ),

                  const SizedBox(height: 20),

                  // Continue Button
                  Obx(() => AppButton(
                    radius: 8,
                    title: ctr.isSendingOtp.value ? "Please wait..." : "Continue",
                    onTap: () {
                      ctr.sendOtp();
                    },
                  )),

                  const SizedBox(height: 30),

                  // Divider for Social Login
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[400])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text("OR", style: text14(color: Colors.grey)),
                      ),
                      Expanded(child: Divider(color: Colors.grey[400])),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Social Login Button
                  Obx(() => _socialLoginButton(
                    icon: FontAwesomeIcons.google,
                    label: ctr.isLoading.value ? "Signing in..." : "Sign in with Google",
                    color: Colors.white,
                    textColor: Colors.black87,
                    onTap: ctr.isLoading.value ? () {} : () => ctr.loginWithGoogle(),
                  )),

                  const SizedBox(height: 30),

                  // Tappable Terms and Privacy
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          Text(
                            "By continuing, you agree to our ",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Get.toNamed(AppRoutes.termsConditions),
                            child: Text(
                              "Terms",
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          Text(
                            " & ",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Get.toNamed(AppRoutes.privacyPolicy),
                            child: Text(
                              "Privacy Policy",
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
