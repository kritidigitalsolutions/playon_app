import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/routes/app_routes.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/utils/custom_button.dart';
import 'dart:ui';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:play_on_app/utils/custom_snakebar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:play_on_app/view_model/before_controller/auth_controller.dart';
import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthController _authController = Get.find<AuthController>();
  String? _profileImagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _authController.getUserProfile();
  }

  // Load saved image path from SharedPreferences
  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImagePath = prefs.getString('profile_image_path');
    });
  }

  // Save image path to SharedPreferences
  Future<void> _saveProfileImage(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_path', path);
  }

  // Pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImagePath = pickedFile.path;
        });
        await _saveProfileImage(pickedFile.path);

        showCustomSnackbar(
          title: "Success",
          message: "Profile picture updated!",
          type: SnackType.success,
        );
      }
    } catch (e) {
      showCustomSnackbar(
        title: "Error",
        message: "Failed to pick image: $e",
        type: SnackType.error,
      );
    }
  }

  // Show image picker options
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.secPrimary.withOpacity(0.95),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Update Profile Picture",
                  style: text18(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _imagePickerOption(
                  icon: Icons.camera_alt,
                  title: "Take Photo",
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 12),
                _imagePickerOption(
                  icon: Icons.photo_library,
                  title: "Choose from Gallery",
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (_profileImagePath != null) ...[
                  const SizedBox(height: 12),
                  _imagePickerOption(
                    icon: Icons.delete_outline,
                    title: "Remove Picture",
                    iconColor: Colors.red,
                    onTap: () async {
                      Navigator.pop(context);
                      setState(() {
                        _profileImagePath = null;
                      });
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('profile_image_path');

                      showCustomSnackbar(
                        title: "Removed",
                        message: "Profile picture removed",
                        type: SnackType.info,
                      );
                    },
                  ),
                ],
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _imagePickerOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Text(title, style: text16(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWithOutImg(
        child: SafeArea(
          child: Obx(() {
            if (_authController.isLoading.value &&
                _authController.userData.value == null) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      _glassInfoTile(
                        text:
                            _authController.userData.value?.email ??
                            "No email provided",
                        onEdit: () => _showEditDialog(
                          "Email",
                          _authController.userData.value?.email ?? "",
                        ),
                      ),
                      const SizedBox(height: 10),
                      _glassInfoTile(
                        text:
                            _authController.userData.value?.mobile ??
                            "No phone number",
                        onEdit: () => _showEditDialog(
                          "Phone Number",
                          _authController.userData.value?.mobile ?? "",
                        ),
                      ),
                      const SizedBox(height: 24),
                      _sectionTitle("Tours & Series", () {
                        Get.toNamed(AppRoutes.selectTour);
                      }),
                      const SizedBox(height: 10),
                      _glassToursList(),
                      const SizedBox(height: 24),
                      _sectionTitle("Follow Players", () {
                        Get.toNamed(AppRoutes.findPlayer);
                      }),
                      const SizedBox(height: 10),
                      _glassPlayersList(),
                      const SizedBox(height: 24),
                      _glassMenuList(),
                      const SizedBox(height: 30),
                      _glassLogoutButton(context),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // 🔹 Header with Image Picker
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hello", style: text14(color: AppColors.white70)),
                SizedBox(height: 4),
                Text(
                  _authController.userData.value?.fullName ?? "User",
                  style: text20(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _showImagePickerOptions,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.white,
                    backgroundImage: _profileImagePath != null
                        ? FileImage(File(_profileImagePath!))
                        : const AssetImage("assets/user.png") as ImageProvider,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.secPrimary, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Glass Info Tile with Edit Dialog
  Widget _glassInfoTile({required String text, required VoidCallback onEdit}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.18),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Expanded(child: Text(text, style: text14())),
              InkWell(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.8),
                    ),
                  ),
                  child: Text(
                    "Edit",
                    style: text13(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show Edit Dialog
  void _showEditDialog(String title, String currentValue) {
    final TextEditingController controller = TextEditingController(
      text: currentValue,
    );

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.secPrimary.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Edit $title",
                    style: text20(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: controller,
                    style: text16(),
                    decoration: InputDecoration(
                      hintText: "Enter $title",
                      hintStyle: text14(color: AppColors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Cancel",
                            style: text16(color: AppColors.white70),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Save the edited value
                            Navigator.pop(context);
                            Get.snackbar(
                              "Updated",
                              "$title updated successfully",
                              backgroundColor: AppColors.primary.withOpacity(
                                0.9,
                              ),
                              colorText: Colors.white,
                              snackPosition: SnackPosition.TOP,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Save",
                            style: text16(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 Section Title
  Widget _sectionTitle(String title, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () {
            Get.toNamed(AppRoutes.followedPage);
          },
          child: Text("$title >", style: text16(fontWeight: FontWeight.bold)),
        ),
        TextButton(
          onPressed: onTap,
          child: Text("+Add more", style: text13(color: AppColors.primary)),
        ),
      ],
    );
  }

  // 🔹 Glass Tours List
  Widget _glassToursList() {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        itemBuilder: (_, i) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                width: 92,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundImage: AssetImage("assets/images/cup.png"),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "India Tour of Australia 2026",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: text10(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 🔹 Glass Players List
  Widget _glassPlayersList() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (_, i) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                margin: const EdgeInsets.only(right: 14),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.07),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage("assets/images/virat.png"),
                    ),
                    SizedBox(height: 6),
                    Text("Virat Kohli", style: text11()),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 🔹 Glass Menu List
  Widget _glassMenuList() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.085),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1.2,
            ),
          ),
          child: Column(
            children: [
              _glassMenuItem(
                "Manage Subscription",
                Icons.workspace_premium,
                onTap: () {
                  Get.toNamed(AppRoutes.accessPlan);
                },
              ),
              _glassMenuItem(
                "Activate TV",
                Icons.tv,
                onTap: () {
                  Get.toNamed(AppRoutes.activateTV);
                },
              ),
              _glassMenuItem(
                "Refer and earn",
                Icons.card_giftcard,
                onTap: () {
                  Get.toNamed(AppRoutes.referScreen);
                },
              ),
              _glassMenuItem(
                "Notification",
                Icons.notifications_none,
                onTap: () {
                  Get.toNamed(AppRoutes.notification);
                },
              ),
              _glassMenuItem(
                "Account Delete",
                Icons.delete_forever,
                onTap: () {
                  Get.toNamed(AppRoutes.accountDelete);
                },
              ),
              _glassMenuItem("Refund Policy", Icons.attach_money, onTap: () {}),
              _glassMenuItem("Privacy Policy", Icons.security, onTap: () {}),
              _glassMenuItem(
                "Terms and conditions",
                Icons.description_outlined,
                onTap: () {},
              ),
              _glassMenuItem("About Us", Icons.info, onTap: () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassMenuItem(String text, IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Icon(icon, size: 20, color: AppColors.textSecondary),
        title: Text(text, style: text14()),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 15,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  // 🔹 Glass Logout Button
  Widget _glassLogoutButton(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: AppButton(
          title: "Log Out",
          onTap: () => _showModernLogoutDialog(context),
          radius: 12,
          color: AppColors.secButton,
        ),
      ),
    );
  }
}

// Modern Logout Confirmation Dialog
void _showModernLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.secPrimary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.white.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.3),
              blurRadius: 30,
              spreadRadius: -10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout_rounded,
                size: 48,
                color: AppColors.error,
              ),
            ),

            const SizedBox(height: 20),

            Text("Log Out?", style: text24(fontWeight: FontWeight.bold)),

            const SizedBox(height: 8),

            Text(
              "Are you sure you want to log out?\nYou'll need to sign in again to continue.",
              textAlign: TextAlign.center,
              style: text15(color: AppColors.white70),
            ),

            const SizedBox(height: 28),

            // Action Buttons
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Cancel",
                      style: text16(
                        fontWeight: FontWeight.w600,
                        color: AppColors.white70,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Logout Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Get.find<AuthController>().logout();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "Yes, Log Out",
                      style: text16(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
