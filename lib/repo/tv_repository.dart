import 'package:play_on_app/data/network/api_network_service.dart';
import 'package:play_on_app/res/app_urls.dart';

class TvRepository {
  final _apiService = NetworkApiService();

  Future<dynamic> generateTvCode() async {
    try {
      final response = await _apiService.postApi(AppUrls.generateTvCode, {});
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
