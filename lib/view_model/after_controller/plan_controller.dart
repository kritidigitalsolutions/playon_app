import 'package:flutter/cupertino.dart';
import 'package:play_on_app/model/response_model/match_model.dart' as model;
import 'package:get/get.dart';
import 'package:play_on_app/model/response_model/subscription_model.dart';
import 'package:play_on_app/repo/plan_repository.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:play_on_app/view_model/before_controller/auth_controller.dart';

import '../../data/api_responce_data.dart';
import '../../model/response_model/plan_model.dart';
import '../../utils/custom_snakebar.dart';

class PlanController extends GetxController {
  final _api = PlanRepository();
  late Razorpay _razorpay;

  final planList = ApiResponse<PlanModel>.loading().obs;
  final mySubscription = ApiResponse<MySubscriptionResponse>.loading().obs;
  final subscriptionHistory = ApiResponse<SubscriptionHistoryResponse>.loading().obs;
  final hasAccess = false.obs;
  final isAdFree = false.obs;

  final promoController = TextEditingController();
  final isPromoApplied = false.obs;
  final appliedPromoCode = "".obs;
  final availablePromos = <dynamic>[].obs;
  final isLoadingPromos = false.obs;

  bool isPlanActive(String? planId, {String? slug}) {
    if (planId == null) return false;
    
    // If it's a plan that requires choosing an item, it shouldn't show as "Purchased" globally
    // because the user can buy it for another item.
    if (slug == "one-match-pass" || slug == "series-pass" || slug == "team-pass" || 
        slug?.contains("match") == true || slug?.contains("series") == true || slug?.contains("team") == true) {
      return false;
    }

    final subs = mySubscription.value.data?.subscriptions ?? [];
    
    // Check if any active subscription matches this planId
    return subs.any((sub) => 
      sub.status == 'active' && 
      sub.planId?.id == planId &&
      (slug == "unlimited-sports-pass" || slug == "full-access" || (sub.matchId == null && sub.seriesId == null && sub.teamId == null))
    );
  }

  // Comprehensive check if user can watch a specific match
  bool canWatchMatch(model.Match? match) {
    if (match == null) return false;
    if (hasAccess.value) return true; // Global full access

    final activeSubs = mySubscription.value.data?.subscriptions ?? [];
    final allSubs = activeSubs.where((sub) => sub.status == 'active').toList();

    // 1. Check if specific match is purchased
    if (allSubs.any((sub) => sub.matchId == match.sId)) return true;

    // 2. Check if the series (tournament) this match belongs to is purchased
    // Using tournament name or ID if available
    if (allSubs.any((sub) => sub.seriesId != null && 
        (sub.seriesId == match.tournament || sub.seriesId == match.sId))) return true;

    // 3. Check if any of the teams in this match are purchased
    if (allSubs.any((sub) => sub.teamId != null && 
        (sub.teamId == match.teamA || sub.teamId == match.teamB))) return true;

    return false;
  }

  // Check if user has already purchased a specific item
  bool hasPurchasedItem({String? matchId, String? seriesId, String? teamId}) {
    if (hasAccess.value) return true; // Global access grants everything

    final history = subscriptionHistory.value.data?.subscriptions ?? [];
    final activeSubs = mySubscription.value.data?.subscriptions ?? [];
    final allSubs = [...history, ...activeSubs].where((sub) => sub.status == 'active').toList();

    if (matchId != null) {
      return allSubs.any((sub) => sub.matchId == matchId);
    }
    if (seriesId != null) {
      return allSubs.any((sub) => sub.seriesId == seriesId);
    }
    if (teamId != null) {
      return allSubs.any((sub) => sub.teamId == teamId);
    }
    return false;
  }

  final isPaymentProcessing = false.obs;
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
    fetchPromos();
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }


  void fetchPlans() {
    _api.getPlans().then((value) {
      planList.value = ApiResponse.completed(PlanModel.fromJson(value));
    }).onError((error, stackTrace) {
      planList.value = ApiResponse.error(error.toString());
    });
  }

  void fetchMySubscription() {
    _api.getMySubscription().then((value) {
      mySubscription.value = ApiResponse.completed(MySubscriptionResponse.fromJson(value));
      checkAccess();
    }).onError((error, stackTrace) {
      mySubscription.value = ApiResponse.error(error.toString());
    });
  }

  void fetchSubscriptionHistory() {
    _api.getSubscriptionHistory().then((value) {
      subscriptionHistory.value = ApiResponse.completed(SubscriptionHistoryResponse.fromJson(value));
    }).onError((error, stackTrace) {
      subscriptionHistory.value = ApiResponse.error(error.toString());
    });
  }

  void checkAccess() {
    final subs = mySubscription.value.data?.subscriptions ?? [];
    
    // Check for any plan that gives full access (no specific itemId)
    final hasGlobalAccess = subs.any((sub) => 
      sub.status == 'active' && 
      (sub.planId?.slug == 'full-access' || sub.planId?.slug == 'unlimited-sports-pass' || 
       (sub.matchId == null && sub.seriesId == null && sub.teamId == null))
    );
    
    hasAccess.value = hasGlobalAccess;
    
    // Check for ad-free status: Only the "Go Ad-Free" plan removes ads
    // Every other plan (Match Pass, Unlimited Sports, etc.) should still show ads
    isAdFree.value = subs.any((sub) => 
      sub.status == 'active' && 
      (sub.planId?.buttonText == 'Go Ad-Free' || sub.planId?.slug == 'ad-free-pass')
    );
  }

  Future<void> cancelSubscription(String id) async {
    try {
      final response = await _api.cancelSubscription(id);
      if (response['success'] == true) {
        showCustomSnackbar(title: 'Success', message: 'Subscription cancelled successfully', type: SnackType.success);
        fetchMySubscription();
      }
    } catch (e) {
      showCustomSnackbar(title: 'Error', message: e.toString(), type: SnackType.error);
    }
  }

  Future<void> deleteSubscription(String id) async {
    try {
      final response = await _api.deleteSubscription(id);
      if (response['success'] == true) {
        showCustomSnackbar(title: 'Success', message: 'Subscription deleted successfully', type: SnackType.success);
        fetchSubscriptionHistory();
      }
    } catch (e) {
      showCustomSnackbar(title: 'Error', message: e.toString(), type: SnackType.error);
    }
  }

  Future<void> buyPlan(String planId, {String? itemId, String? seriesId, String? matchId, String? teamId, String? promoCode}) async {
    isPaymentProcessing.value = true;
    _currentPlanId = planId;
    _currentMatchId = matchId;
    _currentSeriesId = seriesId;
    _currentTeamId = teamId;

    try {
      final response = await _api.createOrder(planId, itemId: itemId, seriesId: seriesId, matchId: matchId, teamId: teamId, promoCode: promoCode);
      
      if (response['success'] == true) {
        final orderData = response['order'];
        final auth = Get.find<AuthController>();
        final key = response['key'] ?? 'rzp_test_YourKeyHere';
        
        var options = {
          'key': key,
          'amount': orderData['amount'], // Backend usually returns amount in paise for Razorpay
          'name': 'PlayOn',
          'order_id': orderData['id'],
          'description': response['plan']?['title'] ?? 'Subscription Payment',
          'prefill': {
            'contact': auth.userData.value?.mobile ?? '',
            'email': auth.userData.value?.email ?? ''
          },
          'external': {
            'wallets': ['paytm']
          }
        };

        _razorpay.open(options);
      }
    } catch (e) {
      isPaymentProcessing.value = false;
      showCustomSnackbar(title: 'Error', message: e.toString(), type: SnackType.error);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    final Map<String, dynamic> verifyData = {
      'razorpay_payment_id': response.paymentId!,
      'razorpay_order_id': response.orderId!,
      'razorpay_signature': response.signature!,
      'planId': _currentPlanId!,
    };

    if (_currentMatchId != null) verifyData['matchId'] = _currentMatchId;
    if (_currentSeriesId != null) verifyData['seriesId'] = _currentSeriesId;
    if (_currentTeamId != null) verifyData['teamId'] = _currentTeamId;

    _api.verifyPayment(verifyData).then((value) {
      isPaymentProcessing.value = false;
      showCustomSnackbar(title: 'Success', message: 'Payment successful', type: SnackType.success);
      fetchMySubscription();
      fetchSubscriptionHistory();
      
      // Navigate back if on plan selection page
      if (Get.currentRoute.contains('Select')) {
        Get.back();
      }
    }).catchError((error) {
      isPaymentProcessing.value = false;
      showCustomSnackbar(title: 'Error', message: 'Payment verification failed', type: SnackType.error);
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    isPaymentProcessing.value = false;
    showCustomSnackbar(title: 'Error', message: response.message ?? 'Payment failed', type: SnackType.error);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    isPaymentProcessing.value = false;
  }

  void removePromoCode() {
    isPromoApplied.value = false;
    appliedPromoCode.value = "";
    promoController.clear();
  }

  void fetchPromos() {
    isLoadingPromos.value = true;
    _api.getPromoCodes().then((value) {
      if (value['success'] == true) {
        availablePromos.value = value['promos'] ?? [];
      }
      isLoadingPromos.value = false;
    }).catchError((error) {
      isLoadingPromos.value = false;
    });
  }

  void applyPromoCode() {
    final code = promoController.text.trim();
    if (code.isEmpty) {
      showCustomSnackbar(title: 'Error', message: 'Please enter a promo code', type: SnackType.error);
      return;
    }

    // Check against available promos from API
    final promo = availablePromos.firstWhere(
      (p) => p['code'].toString().toUpperCase() == code.toUpperCase(),
      orElse: () => null,
    );

    if (promo != null) {
      // Validate expiry
      if (promo['validTill'] != null) {
        final expiry = DateTime.parse(promo['validTill']);
        if (expiry.isBefore(DateTime.now())) {
          showCustomSnackbar(title: 'Error', message: 'This promo code has expired', type: SnackType.error);
          return;
        }
      }
      
      isPromoApplied.value = true;
      appliedPromoCode.value = code.toUpperCase();
      showCustomSnackbar(title: 'Success', message: 'Promo code "${code.toUpperCase()}" applied!', type: SnackType.success);
    } else {
      showCustomSnackbar(title: 'Error', message: 'Invalid promo code', type: SnackType.error);
    }
  }
}
