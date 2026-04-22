import 'package:play_on_app/data/network/api_network_service.dart';

import 'package:play_on_app/data/network/api_network_service.dart';
import 'package:play_on_app/res/app_urls.dart';

class MatchRepository {
  final NetworkApiService _apiServices = NetworkApiService();

  Future<dynamic> getAllMatches({String? sport, String? date}) async {
    try {
      String url = AppUrls.matches;
      List<String> queryParams = [];

      if (sport != null && sport.toLowerCase() != "home") {
        queryParams.add("sport=${sport.toLowerCase()}");
      }

      if (date != null) {
        queryParams.add("date=$date");
      }

      if (queryParams.isNotEmpty) {
        url += "?${queryParams.join("&")}";
      }

      final response = await _apiServices.getApi(url);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getLiveMatches() async {
    try {
      final response = await _apiServices.getApi(AppUrls.liveMatches);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
