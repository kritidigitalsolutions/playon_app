import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/model/response_model/auth_response_model.dart';
import 'package:play_on_app/repo/auth_repository.dart';
import 'package:play_on_app/routes/app_routes.dart';
import 'package:play_on_app/utils/custom_snakebar.dart';
import 'package:play_on_app/utils/hive_service/hive_service.dart';
import 'package:play_on_app/view_model/after_controller/home_contollers/home_controller.dart';

import '../../utils/hive_service/userdetail.dart';

class AuthController extends GetxController {
  final AuthRepository _repository = AuthRepository();
  final formKey = GlobalKey<FormState>();

  var isLoading = false.obs;
  var mobileController = TextEditingController();
  var otpController = TextEditingController();
  var nameController = TextEditingController();
  
  var sentOtp = "".obs;
  var isNewUser = false.obs;

  var userData = Rxn<UserData>();

  @override
  void onInit() {
    super.onInit();
    if (HiveService.getToken() != null) {
      getUserProfile();
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
    isLoading.value = true;
    try {
      final response = await _repository.sendOtp({"mobile": mobileController.text});
      final data = OtpResponseModel.fromJson(response);
      if (data.success == true) {
        sentOtp.value = data.otp ?? "";
        isNewUser.value = data.isNewUser ?? false;
        showCustomSnackbar(title: "Success", message: data.message ?? "OTP Sent", type: SnackType.success);
        Get.toNamed(AppRoutes.otpVerify);
      }
    } catch (e) {
      showCustomSnackbar(title: "Error", message: e.toString(), type: SnackType.error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp() async {
    if (otpController.text.isEmpty) {
      showCustomSnackbar(title: "Error", message: "Enter OTP", type: SnackType.error);
      return;
    }
    isLoading.value = true;
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
        
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().isLogin.value = true;
        }

        if (data.isNewUser == true) {
          Get.offAllNamed(AppRoutes.fullnameEnter);
        } else {
          Get.offAllNamed(AppRoutes.myHomePage);
        }
      }
    } catch (e) {
      showCustomSnackbar(title: "Error", message: e.toString(), type: SnackType.error);
    } finally {
      isLoading.value = false;
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
          Get.find<HomeController>().isLogin.value = true;
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
      
      if (profileImagePath != null) {
        dataMap["profileImage"] = await dio.MultipartFile.fromFile(
          profileImagePath,
          filename: profileImagePath.split('/').last,
        );
      }

      final formData = dio.FormData.fromMap(dataMap);
      
      final response = await _repository.updateProfile(formData, token);
      
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
    await HiveService.logout();
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().isLogin.value = false;
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
          Get.find<HomeController>().isLogin.value = false;
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
}
