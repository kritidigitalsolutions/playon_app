import 'package:play_on_app/data/network/api_network_service.dart';
import 'package:play_on_app/res/app_urls.dart';

class AuthRepository {
  final _apiService = NetworkApiService();

  Future<dynamic> sendOtp(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.postApi(AppUrls.sendOtp, data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> verifyOtp(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.postApi(AppUrls.verifyOtp, data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> completeProfile(Map<String, dynamic> data, String token) async {
    try {
      final response = await _apiService.putApi(AppUrls.completeProfile, data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> updateProfile(dynamic data, String token) async {
    try {
      final response = await _apiService.patchApi(AppUrls.updateProfile, data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> deleteAccount(Map<String, dynamic> data, String token) async {
    try {
      final response = await _apiService.deleteApi(AppUrls.deleteAccount, data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getUserProfile(String token) async {
    try {
      final response = await _apiService.getApi(AppUrls.userProfile);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> googleLogin(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.postApi(AppUrls.googleLogin, data);
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
