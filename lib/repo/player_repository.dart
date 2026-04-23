import 'package:play_on_app/data/network/api_network_service.dart';
import 'package:play_on_app/res/app_urls.dart';
import 'package:play_on_app/utils/hive_service/hive_service.dart';

class PlayerRepository {
  final _apiService = NetworkApiService();

  void _prepare() {
    final token = HiveService.getToken();
    if (token != null) {
      _apiService.setToken(token);
    }
  }

  Future<dynamic> getAllPlayers({String? search, String? sport, String? country}) async {
    try {
      _prepare();
      
      Map<String, String> queryParams = {};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (sport != null && sport.isNotEmpty) queryParams['sport'] = sport;
      if (country != null && country.isNotEmpty) queryParams['country'] = country;

      String url = AppUrls.players;
      if (queryParams.isNotEmpty) {
        String queryString = Uri(queryParameters: queryParams).query;
        url = "$url?$queryString";
      }

      final response = await _apiService.getApi(url);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> toggleFollow(String playerId) async {
    try {
      _prepare();
      // Using postApi as requested
      final response = await _apiService.postApi(AppUrls.toggleFollowPlayer(playerId), {});
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getFollowedPlayers() async {
    try {
      _prepare();
      final response = await _apiService.getApi(AppUrls.followedPlayers);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
