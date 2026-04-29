import 'package:play_on_app/data/network/api_network_service.dart';
import 'package:play_on_app/res/app_urls.dart';
import 'package:play_on_app/utils/hive_service/hive_service.dart';

class PlanRepository {
  final _apiService = NetworkApiService();

  Future<dynamic> getPlans() async {
    try {
      final response = await _apiService.getApi(AppUrls.plans);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> createOrder(String planId, {String? itemId, String? seriesId, String? matchId, String? teamId, String? promoCode}) async {
    try {
      final token = HiveService.getToken();
      if (token != null) {
        _apiService.setToken(token);
      }
      final data = {'planId': planId};
      if (itemId != null) {
        data['itemId'] = itemId;
      }
      if (seriesId != null) {
        data['seriesId'] = seriesId;
      }
      if (matchId != null) {
        data['matchId'] = matchId;
      }
      if (teamId != null) {
        data['teamId'] = teamId;
      }
      if (promoCode != null && promoCode.isNotEmpty) {
        data['promoCode'] = promoCode;
      }
      final response = await _apiService.postApi(
        AppUrls.createOrder,
        data,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> verifyPayment(Map<String, dynamic> data) async {
    try {
      final token = HiveService.getToken();
      if (token != null) {
        _apiService.setToken(token);
      }
      final response = await _apiService.postApi(
        AppUrls.verifyPayment,
        data,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getMySubscription() async {
    try {
      final token = HiveService.getToken();
      if (token != null) {
        _apiService.setToken(token);
      }
      final response = await _apiService.getApi(AppUrls.mySubscription);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getSubscriptionHistory() async {
    try {
      final token = HiveService.getToken();
      if (token != null) {
        _apiService.setToken(token);
      }
      final response = await _apiService.getApi(AppUrls.subscriptionHistory);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> checkAccess() async {
    try {
      final token = HiveService.getToken();
      if (token != null) {
        _apiService.setToken(token);
      }
      final response = await _apiService.getApi(AppUrls.checkAccess);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> cancelSubscription(String id) async {
    try {
      final token = HiveService.getToken();
      if (token != null) {
        _apiService.setToken(token);
      }
      final response = await _apiService.patchApi(AppUrls.cancelSubscription(id), {});
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> deleteSubscription(String id) async {
    try {
      final token = HiveService.getToken();
      if (token != null) {
        _apiService.setToken(token);
      }
      final response = await _apiService.deleteApi(AppUrls.deleteSubscription(id),{});
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getPromoCodes() async {
    try {
      final response = await _apiService.getApi(AppUrls.promoCodes);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
