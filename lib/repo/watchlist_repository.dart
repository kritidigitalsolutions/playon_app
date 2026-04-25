import 'package:play_on_app/res/app_urls.dart';
import '../data/network/api_network_service.dart';
import '../data/network/base_api_service.dart';

class WatchlistRepository {
  final BaseApiService _apiServices = NetworkApiService();

  Future<dynamic> getWatchlist() async {
    try {
      dynamic response = await _apiServices.getApi(AppUrls.watchlist);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> toggleWatchlist(Map<String, dynamic> data) async {
    try {
      dynamic response = await _apiServices.postApi(AppUrls.toggleWatchlist, data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> checkWatchlistStatus(String type, String id) async {
    try {
      dynamic response = await _apiServices.getApi(AppUrls.checkWatchlist(type, id));
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
