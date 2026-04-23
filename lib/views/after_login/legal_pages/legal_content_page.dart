import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/view_model/after_controller/legal_controller.dart';
import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';

import '../../../data/api_responce_data.dart';

class LegalContentPage extends StatelessWidget {
  final String title;
  final Rx<dynamic> apiResponse;
  final VoidCallback fetchData;

  const LegalContentPage({
    super.key,
    required this.title,
    required this.apiResponse,
    required this.fetchData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(title, style: text20(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: BackgroundWithOutImg(
        child: Obx(() {
          switch (apiResponse.value.status) {
            case Status.loading:
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            case Status.error:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Error: ${apiResponse.value.message}", style: text14(color: Colors.red)),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: fetchData,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              );
            case Status.completed:
              final page = apiResponse.value.data!.page;
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 120, 16, 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Text(
                    page?.content ?? "No content available",
                    style: text15(color: Colors.white.withOpacity(0.9)),
                  ),
                ),
              );
            default:
              return const SizedBox();
          }
        }),
      ),
    );
  }
}
