import 'package:get/get.dart';
import 'package:play_on_app/model/response_model/plan_model.dart';
import 'package:play_on_app/repo/plan_repository.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:play_on_app/utils/custom_snakebar.dart';
import 'package:play_on_app/view_model/before_controller/auth_controller.dart';

import '../../data/api_responce_data.dart';

class PlanController extends GetxController {
  final _api = PlanRepository();
  late Razorpay _razorpay;

  final planList = ApiResponse<PlanModel>.loading().obs;
  var isPaymentProcessing = false.obs;
  String? _currentPlanId;

  @override
  void onInit() {
    super.onInit();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    fetchPlans();
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }

  void fetchPlans() {
    planList.value = ApiResponse.loading();
    _api.getPlans().then((value) {
      planList.value = ApiResponse.completed(PlanModel.fromJson(value));
    }).onError((error, stackTrace) {
      planList.value = ApiResponse.error(error.toString());
    });
  }

  Future<void> buyPlan(String planId) async {
    isPaymentProcessing.value = true;
    _currentPlanId = planId;
    try {
      final response = await _api.createOrder(planId);
      if (response['success'] == true) {
        final order = response['order'];
        final key = response['key'];
        final authController = Get.find<AuthController>();
        final userData = authController.userData.value;

        var options = {
          'key': key,
          'amount': order['amount'] * 100, // Amount in paise
          'name': 'PlayOn',
          'order_id': order['id'],
          'description': response['plan']['title'],
          'prefill': {
            'contact': userData?.mobile ?? '',
            'email': userData?.email ?? '',
            'name': userData?.fullName ?? ''
          },
          'external': {
            'wallets': ['paytm']
          }
        };
        _razorpay.open(options);
      }
    } catch (e) {
      showCustomSnackbar(title: "Error", message: "Failed to initiate payment: $e", type: SnackType.error);
    } finally {
      isPaymentProcessing.value = false;
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    isPaymentProcessing.value = true;
    try {
      final verifyData = {
        "razorpay_order_id": response.orderId,
        "razorpay_payment_id": response.paymentId,
        "razorpay_signature": response.signature,
        "planId": _currentPlanId
      };

      final result = await _api.verifyPayment(verifyData);
      if (result['success'] == true) {
        showCustomSnackbar(title: "Success", message: "Payment verified successfully!", type: SnackType.success);
        Get.find<AuthController>().getUserProfile(); // Refresh user data to show subscription
        Get.back();
      } else {
        showCustomSnackbar(title: "Error", message: "Payment verification failed", type: SnackType.error);
      }
    } catch (e) {
      showCustomSnackbar(title: "Error", message: "Verification error: $e", type: SnackType.error);
    } finally {
      isPaymentProcessing.value = false;
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    showCustomSnackbar(
        title: "Payment Failed",
        message: "Code: ${response.code}\nMessage: ${response.message}",
        type: SnackType.error);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    showCustomSnackbar(title: "External Wallet", message: response.walletName ?? "", type: SnackType.info);
  }
}
