import 'package:get/get.dart';
import 'package:play_on_app/model/response_model/subscription_model.dart';
import 'package:play_on_app/repo/plan_repository.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:play_on_app/utils/custom_snakebar.dart';
import 'package:play_on_app/view_model/before_controller/auth_controller.dart';

import '../../data/api_responce_data.dart';
import '../../model/response_model/plan_model.dart';

class PlanController extends GetxController {
  final _api = PlanRepository();
  late Razorpay _razorpay;

  final planList = ApiResponse<PlanModel>.loading().obs;
  final mySubscription = ApiResponse<MySubscriptionResponse>.loading().obs;
  final subscriptionHistory = ApiResponse<SubscriptionHistoryResponse>.loading().obs;
  final hasAccess = false.obs;

  bool isPlanActive(String? planId, {String? slug}) {
    if (planId == null) return false;
    final subs = mySubscription.value.data?.subscriptions ?? [];
    
    // Check if any active subscription matches this planId
    return subs.any((sub) => 
      sub.status == 'active' && 
      sub.planId?.id == planId &&
      (slug == "unlimited-sports-pass" || slug == "full-access" || (sub.matchId == null && sub.seriesId == null && sub.teamId == null))
    );
  }

  // Check if user has already purchased a specific item
  bool hasPurchasedItem({String? matchId, String? seriesId, String? teamId}) {
    final history = subscriptionHistory.value.data?.subscriptions ?? [];
    final activeSubs = mySubscription.value.data?.subscriptions ?? [];
    
    // Combine both just in case, though mySubscription should have active ones
    final allSubs = [...history, ...activeSubs];

    if (matchId != null) {
      return allSubs.any((sub) => sub.status == 'active' && sub.matchId == matchId);
    }
    if (seriesId != null) {
      return allSubs.any((sub) => sub.status == 'active' && sub.seriesId == seriesId);
    }
    if (teamId != null) {
      return allSubs.any((sub) => sub.status == 'active' && sub.teamId == teamId);
    }
    return false;
  }

  var isPaymentProcessing = false.obs;
  String? _currentPlanId;
  String? _currentMatchId;
  String? _currentSeriesId;
  String? _currentTeamId;

  @override
  void onInit() {
    super.onInit();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    fetchPlans();
    fetchMySubscription();
    fetchSubscriptionHistory();
    checkAccess();
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

  void fetchMySubscription() {
    mySubscription.value = ApiResponse.loading();
    _api.getMySubscription().then((value) {
      mySubscription.value = ApiResponse.completed(MySubscriptionResponse.fromJson(value));
    }).onError((error, stackTrace) {
      mySubscription.value = ApiResponse.error(error.toString());
    });
  }

  void fetchSubscriptionHistory() {
    subscriptionHistory.value = ApiResponse.loading();
    _api.getSubscriptionHistory().then((value) {
      subscriptionHistory.value = ApiResponse.completed(SubscriptionHistoryResponse.fromJson(value));
    }).onError((error, stackTrace) {
      subscriptionHistory.value = ApiResponse.error(error.toString());
    });
  }

  void checkAccess() {
    _api.checkAccess().then((value) {
      final response = CheckAccessResponse.fromJson(value);
      hasAccess.value = response.hasAccess ?? false;
    }).onError((error, stackTrace) {
      hasAccess.value = false;
    });
  }

  Future<void> cancelSubscription(String id) async {
    try {
      final response = await _api.cancelSubscription(id);
      if (response['success'] == true) {
        showCustomSnackbar(title: "Success", message: "Subscription cancelled successfully", type: SnackType.success);
        fetchMySubscription();
        fetchSubscriptionHistory();
      }
    } catch (e) {
      showCustomSnackbar(title: "Error", message: "Failed to cancel subscription: $e", type: SnackType.error);
    }
  }

  Future<void> deleteSubscription(String id) async {
    try {
      final response = await _api.deleteSubscription(id);
      if (response['success'] == true) {
        showCustomSnackbar(title: "Success", message: "Subscription deleted successfully", type: SnackType.success);
        fetchSubscriptionHistory();
      }
    } catch (e) {
      showCustomSnackbar(title: "Error", message: "Failed to delete subscription: $e", type: SnackType.error);
    }
  }

  Future<void> buyPlan(String planId, {String? itemId, String? seriesId, String? matchId, String? teamId}) async {
    isPaymentProcessing.value = true;
    _currentPlanId = planId;
    _currentMatchId = matchId;
    _currentSeriesId = seriesId;
    _currentTeamId = teamId;
    try {
      final response = await _api.createOrder(planId,
          itemId: itemId, seriesId: seriesId, matchId: matchId, teamId: teamId);
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
        "planId": _currentPlanId,
        "matchId": _currentMatchId,
        "seriesId": _currentSeriesId,
        "teamId": _currentTeamId,
      };

      final result = await _api.verifyPayment(verifyData);
      if (result['success'] == true) {
        showCustomSnackbar(title: "Success", message: "Payment verified successfully!", type: SnackType.success);
        Get.find<AuthController>().getUserProfile(); // Refresh user data to show subscription
        fetchMySubscription();
        fetchSubscriptionHistory();
        checkAccess();
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
