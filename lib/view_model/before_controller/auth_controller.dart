import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final TextEditingController phoneCtr = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey();
}

class VerifyOtpController extends GetxController {
  final List<TextEditingController> otpCtrls = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  final RxString errorText = ''.obs;

  @override
  void onInit() {
    super.onInit();

    /// Autofocus first box
    Future.delayed(const Duration(milliseconds: 300), () {
      focusNodes.first.requestFocus();
    });
  }

  var otp = '';

  bool validateOtp() {
    final otp = otpCtrls.map((e) => e.text).join();

    if (otp.length != 6) {
      errorText.value = "Enter valid 6-digit code";
      return false;
    }
    this.otp = otp;

    errorText.value = '';
    return true;
  }

  //------------------------------------
  // api
  // ------------------------------------------

  // final _repo = AuthRepo();

  // RxBool isLoading = false.obs;

  // Future<void> verifyOtp(String phone) async {
  //   isLoading.value = true;
  //   try {
  //     final res = await _repo.verifyOtp(phone, otp);

  //     if (res.isNewUser == false) {
  //       await LocalStorage.saveUser(res);

  //       String token = LocalStorage.getToken() ?? '';

  //       SocketService().connect(token);

  //       Get.offAllNamed(AppRoutes.homePage);

  //       showSuccessSnackbar(
  //         title: "Success",
  //         message: "This number is already registered.",
  //       );
  //     } else {
  //       Get.toNamed(AppRoutes.userImage, arguments: phone);

  //       showSuccessSnackbar(
  //         title: "Success",
  //         message: "OTP verified successfully",
  //       );
  //     }
  //   } catch (e) {
  //     showErrorSnackbar(
  //       title: "Error",
  //       message: "Invalid OTP. Please try again.",
  //     );
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }
}
