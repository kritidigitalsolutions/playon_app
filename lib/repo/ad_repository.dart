import 'package:play_on_app/data/network/api_network_service.dart';
import 'package:play_on_app/res/app_urls.dart';

class AdRepository {
  final _apiService = NetworkApiService();

  Future<dynamic> getBannerAds() async {
    try {
      final response = await _apiService.getApi(AppUrls.bannerAds);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
