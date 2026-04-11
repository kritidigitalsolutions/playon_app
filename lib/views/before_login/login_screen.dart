import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/routes/app_routes.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/utils/custom_button.dart';
import 'package:play_on_app/utils/custom_text_fields.dart';
import 'package:play_on_app/view_model/before_controller/auth_controller.dart';
import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final LoginController ctr = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWithImg(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Form(
            key: ctr.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Get Started", style: text24(fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),

                // Mobile Number Input
                NumberTextField(
                  radius: 8,
                  maxLength: 10,
                  controller: ctr.phoneCtr,
                  hintText: "Enter Your Mobile Number",
                ),

                const SizedBox(height: 20),
                Text("OR", style: text16(color: AppColors.textSecondary)),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(color: AppColors.white24),
                      ),
                    ),
                    SizedBox(width: 5),
                    Text(
                      "Continue with",
                      style: text13(color: AppColors.textSecondary),
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(color: AppColors.white24),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Google & Apple Sign in
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _socialButton("assets/auth/google.png"),
                    const SizedBox(width: 20),
                    _socialButton("assets/auth/fb.png"),
                  ],
                ),

                const SizedBox(height: 20),

                // Continue Button
                AppButton(
                  radius: 8,
                  title: "Continue",
                  onTap: () {
                    if (ctr.formKey.currentState!.validate()) {
                      Get.toNamed(AppRoutes.otpVerify);
                    }
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialButton(String asset) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(shape: BoxShape.circle),
      child: Image.asset(
        asset,
        width: 30,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(Icons.error_outline, color: AppColors.white12),
          );
        },
      ),
    );
  }
}
