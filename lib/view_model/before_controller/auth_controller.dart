import 'dart:async';
import 'package:dio/dio.dart' as dio;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:play_on_app/model/response_model/auth_response_model.dart';
import 'package:play_on_app/model/response_model/social_media_model.dart';
import 'package:play_on_app/repo/auth_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:play_on_app/routes/app_routes.dart';
import 'package:play_on_app/utils/custom_snakebar.dart';
import 'package:play_on_app/utils/hive_service/hive_service.dart';
import 'package:play_on_app/view_model/after_controller/home_contollers/home_controller.dart';
import 'package:play_on_app/data/network/notification_service.dart';

import '../../utils/hive_service/userdetail.dart';

class AuthController extends GetxController {
  final AuthRepository _repository = AuthRepository();
  final formKey = GlobalKey<FormState>();

  var isLoading = false.obs;
  var isVerifyingOtp = false.obs;
  var isSendingOtp = false.obs;
  var mobileController = TextEditingController();
  var otpController = TextEditingController();
  var nameController = TextEditingController();
  
  var sentOtp = "".obs;
  var isNewUser = false.obs;

  var userData = Rxn<UserData>();

  // Resend OTP Timer
  var resendSeconds = 0.obs;
  Timer? _resendTimer;

  void startResendTimer() {
    resendSeconds.value = 30;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds.value > 0) {
        resendSeconds.value--;
      } else {
        _resendTimer?.cancel();
      }
    });
  }

  @override
  void onInit() {
    super.onInit();
    getSocialMediaLinks();
    if (HiveService.getToken() != null) {
      getUserProfile();
    }
  }

  RxList<SocialMedia> socialMediaLinks = <SocialMedia>[].obs;

  Future<void> getSocialMediaLinks() async {
    try {
      final response = await _repository.getSocialMedia();
      final data = SocialMediaResponse.fromJson(response);
      if (data.success == true && data.social != null) {
        socialMediaLinks.assignAll(data.social!);
      }
    } catch (e) {
      print("Error fetching social media: $e");
    }
  }

  Future<void> launchSocialUrl(String url) async {
    String launchUrlStr = url;
    // Check if it's an email address without mailto: scheme
    if (url.contains('@') && !url.startsWith('mailto:') && !url.startsWith('http')) {
      launchUrlStr = 'mailto:$url';
    }
    
    final Uri uri = Uri.parse(launchUrlStr);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback for mailto if canLaunchUrl fails
        if (launchUrlStr.startsWith('mailto:')) {
          await launchUrl(uri);
        } else {
          print("Could not launch $launchUrlStr");
        }
      }
    } catch (e) {
      print("Error launching social URL: $e");
    }
  }

  Future<void> getUserProfile() async {
    isLoading.value = true;
    try {
      final token = HiveService.getToken();
      if (token == null) return;
      
      final response = await _repository.getUserProfile(token);
      if (response['success'] == true) {
        userData.value = UserData.fromJson(response['user']);
        
        // Update Hive local storage with fresh data
        final user = HiveService.getUser();
        if (user != null) {
          user.name = userData.value?.fullName;
          user.phone = userData.value?.mobile;
          user.favoriteSports = userData.value?.favoriteSports;
          await HiveService.saveUser(user);
        }
      }
    } catch (e) {
      print("Error fetching profile: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendOtp() async {
    if (mobileController.text.isEmpty) {
      showCustomSnackbar(title: "Error", message: "Enter mobile number", type: SnackType.error);
      return;
    }
    isSendingOtp.value = true;
    try {
      final response = await _repository.sendOtp({"mobile": mobileController.text});
      final data = OtpResponseModel.fromJson(response);
      if (data.success == true) {
        sentOtp.value = data.otp ?? "";
        isNewUser.value = data.isNewUser ?? false;
        showCustomSnackbar(
          title: "Success",
          message: "${data.message ?? "OTP Sent"}: ${data.otp}",
          type: SnackType.success,
        );
        startResendTimer();
        if (Get.currentRoute != AppRoutes.otpVerify) {
          Get.toNamed(AppRoutes.otpVerify);
        }
      }
    } catch (e) {
      showCustomSnackbar(title: "Error", message: e.toString(), type: SnackType.error);
    } finally {
      isSendingOtp.value = false;
    }
  }

  Future<void> loginWithGoogle() async {
    isLoading.value = true;
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email'],
        serverClientId: "257271466858-7c4qa7ttf0entmjckpcghvvso0f81pb0.apps.googleusercontent.com",
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        isLoading.value = false;
        return;
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final String? idToken = googleAuth.idToken;

      final response = await _repository.googleLogin({
        "idToken": idToken,
      });

      print("Google Token Sent: $idToken");

      final data = VerifyOtpResponseModel.fromJson(response);
      if (data.success == true) {
        final userDetail = UserDetails(
          token: data.token,
          email: data.user?.email,
          phone: data.user?.mobile,
          isNewUser: data.isNewUser,
          name: data.user?.fullName,
          image: data.user?.profilePic ?? data.user?.profileImage,
        );
        await HiveService.saveUser(userDetail);
        userData.value = data.user;
        
        // Pre-fill name from Google if available for background sync
        if (data.user?.fullName != null && data.user!.fullName!.isNotEmpty) {
          nameController.text = data.user!.fullName!;
        } else if (googleUser.displayName != null) {
          nameController.text = googleUser.displayName!;
        }

        // Sync FCM token after successful login
        NotificationService.syncTokenToServer();

        if (Get.isRegistered<HomeController>()) {
          final homeCtr = Get.find<HomeController>();
          homeCtr.isLogin.value = true;
          homeCtr.userName.value = nameController.text;
          homeCtr.fetchMatches();
        }

        if (data.isNewUser == true) {
          // Directly go to Sport Interest instead of Full Name screen
          Get.offAllNamed(AppRoutes.sportInterrestScreen);
        } else {
          Get.offAllNamed(AppRoutes.myHomePage);
        }
      } else {
        showCustomSnackbar(
          title: "Error",
          message: data.message ?? "Google login failed",
          type: SnackType.error,
        );
      }
    } catch (e) {
      print("Google Login Error: $e");
      showCustomSnackbar(
        title: "Error",
        message: "Google login failed. Please try again.",
        type: SnackType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }



  Future<void> verifyOtp() async {
    if (otpController.text.isEmpty) {
      showCustomSnackbar(title: "Error", message: "Enter OTP", type: SnackType.error);
      return;
    }
    isVerifyingOtp.value = true;
    try {
      final response = await _repository.verifyOtp({
        "mobile": mobileController.text,
        "otp": otpController.text
      });
      final data = VerifyOtpResponseModel.fromJson(response);
      if (data.success == true) {
        final userDetail = UserDetails(
          token: data.token,
          phone: mobileController.text,
          isNewUser: data.isNewUser,
          name: data.user?.fullName,
        );
        await HiveService.saveUser(userDetail);

        // Pre-fill name if available
        if (data.user?.fullName != null) {
          nameController.text = data.user!.fullName!;
        }

        // Sync FCM token after successful login
        NotificationService.syncTokenToServer();

        if (Get.isRegistered<HomeController>()) {
          final homeCtr = Get.find<HomeController>();
          homeCtr.isLogin.value = true;
          homeCtr.userName.value = nameController.text;
        }

        if (data.isNewUser == true) {
          Get.offAllNamed(AppRoutes.sportInterrestScreen);
        } else {
          Get.offAllNamed(AppRoutes.myHomePage);
        }
      }
    } catch (e) {
      showCustomSnackbar(title: "Error", message: e.toString(), type: SnackType.error);
    } finally {
      isVerifyingOtp.value = false;
    }
  }

  Future<void> completeProfile(List<String> favoriteSports) async {
    if (nameController.text.trim().isEmpty) {
      showCustomSnackbar(title: "Error", message: "Enter full name", type: SnackType.error);
      return;
    }
    if (favoriteSports.isEmpty) {
      showCustomSnackbar(title: "Error", message: "Select at least one sport", type: SnackType.error);
      return;
    }
    isLoading.value = true;
    try {
      final token = HiveService.getToken();
      final response = await _repository.completeProfile({
        "fullName": nameController.text,
        "favoriteSports": favoriteSports
      }, token ?? "");
      
      if (response['success'] == true) {
        final user = HiveService.getUser();
        if (user != null) {
          user.name = nameController.text;
          user.favoriteSports = favoriteSports;
          user.isNewUser = false;
          await HiveService.saveUser(user);
        }
        if (Get.isRegistered<HomeController>()) {
          final homeCtr = Get.find<HomeController>();
          homeCtr.isLogin.value = true;
          homeCtr.userName.value = nameController.text;
        }
        Get.offAllNamed(AppRoutes.myHomePage);
      }
    } catch (e) {
      showCustomSnackbar(title: "Error", message: e.toString(), type: SnackType.error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile({String? fullName, String? email, String? profileImagePath}) async {
    isLoading.value = true;
    try {
      final token = HiveService.getToken();
      if (token == null) return;

      Map<String, dynamic> dataMap = {};
      if (fullName != null) dataMap["fullName"] = fullName;
      if (email != null) dataMap["email"] = email;
      
      dynamic requestData;

      if (profileImagePath != null) {
        if (profileImagePath.isEmpty) {
          // Removal case
          dataMap["profileImage"] = ""; 
          dataMap["profilePic"] = ""; 
          
          // Force clear local data immediately for better UI response
          if (userData.value != null) {
            userData.value!.profileImage = "";
            userData.value!.profilePic = "";
            userData.refresh();
          }
          
          // Use a plain map (JSON) for removal to allow empty strings/nulls to be processed correctly
          requestData = dataMap;
        } else {
          // Upload case
          dataMap["profileImage"] = await dio.MultipartFile.fromFile(
            profileImagePath,
            filename: profileImagePath.split('/').last,
          );
          // Use FormData for multi-part file upload
          requestData = dio.FormData.fromMap(dataMap);
        }
      } else {
        // Just text update, use plain map (JSON)
        requestData = dataMap;
      }

      // If the repository expects only FormData, we'd need to convert, but patchApi handles dynamic
      final response = await _repository.updateProfile(requestData, token);
      
      if (response['success'] == true) {
        userData.value = UserData.fromJson(response['user']);
        
        // Update Hive local storage
        final user = HiveService.getUser();
        if (user != null) {
          user.name = userData.value?.fullName;
          user.phone = userData.value?.mobile;
          user.email = userData.value?.email;
          user.image = userData.value?.profileImage;
          await HiveService.saveUser(user);
        }
        
        showCustomSnackbar(
          title: "Success",
          message: response['message'] ?? "Profile updated successfully",
          type: SnackType.success,
        );
      }
    } catch (e) {
      showCustomSnackbar(title: "Error", message: e.toString(), type: SnackType.error);
    } finally {
      isLoading.value = false;
    }
  }

  void logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
    } catch (e) {
      print("Error during social logout: $e");
    }
    await HiveService.logout();
    if (Get.isRegistered<HomeController>()) {
      final homeCtr = Get.find<HomeController>();
      homeCtr.isLogin.value = false;
      homeCtr.userName.value = "";
    }
    Get.offAllNamed(AppRoutes.login);
  }

  Future<void> deleteAccount(String reason) async {
    isLoading.value = true;
    try {
      final token = HiveService.getToken();
      final response = await _repository.deleteAccount({
        "reason": reason
      }, token ?? "");

      if (response['success'] == true) {
        await HiveService.logout();
        if (Get.isRegistered<HomeController>()) {
          final homeCtr = Get.find<HomeController>();
          homeCtr.isLogin.value = false;
          homeCtr.userName.value = "";
        }
        showCustomSnackbar(
          title: "Account Deleted",
          message: response['message'] ?? "Your account has been permanently deleted",
          type: SnackType.success,
        );
        Get.offAllNamed(AppRoutes.login);
      } else {
        showCustomSnackbar(
          title: "Error",
          message: response['message'] ?? "Failed to delete account",
          type: SnackType.error,
        );
      }
    } catch (e) {
      showCustomSnackbar(title: "Error", message: e.toString(), type: SnackType.error);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    super.onClose();
  }
}
