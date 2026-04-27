import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/utils/custom_button.dart';
import 'package:play_on_app/view_model/after_controller/tv_controller.dart';
import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';

class ActivateTvScreen extends StatelessWidget {
  ActivateTvScreen({super.key});

  final TvController controller = Get.put(TvController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWithOutImg(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Obx(() => Column(
                  children: [
                    const SizedBox(height: 10),

                    /// Title
                    Text(
                      "Activate on TV",
                      style: text24(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "Stream on Your Big Screen",
                      style: text14(color: AppColors.white70),
                    ),

                    const SizedBox(height: 24),

                    /// Image Card
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Image.asset("assets/images/tv.png", fit: BoxFit.cover, height: 150),
                    ),

                    const SizedBox(height: 20),

                    /// Description
                    Text(
                      "Enjoy every match on your TV with a\nquick and easy setup",
                      textAlign: TextAlign.center,
                      style: text13(color: AppColors.white70),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      "Open the app on your TV and enter\nthe code shown to connect",
                      textAlign: TextAlign.center,
                      style: text13(color: AppColors.white),
                    ),

                    const SizedBox(height: 20),

                    /// Code Box
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: controller.isLoading.value
                          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: controller.tvCode.value.isEmpty
                                  ? [const Text("No Code", style: TextStyle(color: Colors.white70))]
                                  : controller.tvCode.value.split('').map((digit) => CodeDigit(digit)).toList(),
                            ),
                    ),

                    const SizedBox(height: 12),
                    if (controller.expiresIn.value > 0)
                      Text(
                        "Code expires in: ${controller.expiresIn.value}s",
                        style: text12(color: AppColors.error),
                      ),

                    const SizedBox(height: 25),

                    /// Button
                    AppButton(
                      radius: 8,
                      title: controller.isLoading.value ? "Generating..." : "Generate New Code",
                      onTap: () => controller.generateTvCode(),
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }
}

class CodeDigit extends StatelessWidget {
  final String digit;
  const CodeDigit(this.digit, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      digit,
      style: const TextStyle(
        fontSize: 18,
        color: Colors.white,
        letterSpacing: 2,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
