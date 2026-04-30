import 'package:play_on_app/data/network/api_network_service.dart';
import 'package:play_on_app/res/app_urls.dart';

class LegalRepository {
  final _apiService = NetworkApiService();

  Future<dynamic> getPrivacyPolicy() async {
    try {
      final response = await _apiService.getApi(AppUrls.privacyPolicy);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getAboutUs() async {
    try {
      final response = await _apiService.getApi(AppUrls.aboutUs);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getRefundPolicy() async {
    try {
      final response = await _apiService.getApi(AppUrls.refundPolicy);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getTermsConditions() async {
    try {
      final response = await _apiService.getApi(AppUrls.termsConditions);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getSocialMedia() async {
    try {
      final response = await _apiService.getApi(AppUrls.socialMedia);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
