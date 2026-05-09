import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/res/app_colors.dart';

enum SnackType { success, error, warning, info }

void showCustomSnackbar({
  required String title,
  required String message,
  SnackType type = SnackType.info,
  Widget? action,
}) {
  Color bgColor;
  IconData icon;

  switch (type) {
    case SnackType.success:
      bgColor = Colors.green;
      icon = Icons.check_circle;
      break;
    case SnackType.error:
      bgColor = Colors.red;
      icon = Icons.error;
      break;
    case SnackType.warning:
      bgColor = Colors.orange;
      icon = Icons.warning;
      break;
    default:
      bgColor = AppColors.primary;
      icon = Icons.info;
  }

  Get.showSnackbar(
    GetSnackBar(
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.transparent,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 4),
      animationDuration: const Duration(milliseconds: 500),
      borderRadius: 20,

      messageText: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: bgColor.withOpacity(0.4), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: bgColor.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: bgColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: bgColor, size: 20),
                ),

                const SizedBox(width: 14),

                // Texts
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        message,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                if (action != null) ...[
                  const SizedBox(width: 12),
                  action,
                ],

                // Close Button if no action
                if (action == null)
                GestureDetector(
                  onTap: () => Get.closeCurrentSnackbar(),
                  child: Icon(Icons.close, color: Colors.white.withOpacity(0.5), size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
