import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum SnackType { success, error, warning, info }

void showCustomSnackbar({
  required String title,
  required String message,
  SnackType type = SnackType.info,
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
      bgColor = Colors.blue;
      icon = Icons.info;
  }

  Get.showSnackbar(
    GetSnackBar(
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.transparent,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 400),
      borderRadius: 20,

      messageText: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: bgColor.withOpacity(0.6), width: 1.2),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: bgColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: bgColor, size: 22),
                ),

                const SizedBox(width: 12),

                // Texts
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Close Button
                GestureDetector(
                  onTap: () => Get.closeCurrentSnackbar(),
                  child: const Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
