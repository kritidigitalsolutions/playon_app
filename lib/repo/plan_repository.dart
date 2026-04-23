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

  Future<dynamic> createOrder(String planId) async {
    try {
      final token = HiveService.getToken();
      if (token != null) {
        _apiService.setToken(token);
      }
      final response = await _apiService.postApi(
        AppUrls.createOrder,
        {'planId': planId},
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
}
