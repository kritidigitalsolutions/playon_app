import 'package:flutter/material.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/utils/custom_button.dart';
import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';

class ActivateTvScreen extends StatelessWidget {
  const ActivateTvScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWithOutImg(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
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
                  child: Image.asset("assets/images/tv.png", fit: BoxFit.cover),
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
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CodeDigit("1"),
                      CodeDigit("5"),
                      CodeDigit("6"),
                      CodeDigit("8"),
                    ],
                  ),
                ),

                SizedBox(height: 25),

                /// Button
                AppButton(radius: 8, title: "Activate Now", onTap: () {}),
              ],
            ),
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
