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

  Future<dynamic> getTeams({String? sport, String? country, String? search}) async {
    try {
      String url = AppUrls.teams;
      List<String> queryParams = [];

      if (sport != null && sport.isNotEmpty) {
        queryParams.add("sport=${sport.toLowerCase()}");
      }
      if (country != null && country.isNotEmpty) {
        queryParams.add("country=$country");
      }
      if (search != null && search.isNotEmpty) {
        queryParams.add("name=$search");
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

  Future<dynamic> getSeries() async {
    try {
      final response = await _apiServices.getApi(AppUrls.series);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getFollowedSeries() async {
    try {
      final response = await _apiServices.getApi(AppUrls.followedSeries);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> toggleFollowSeries(String id) async {
    try {
      final response = await _apiServices.patchApi( AppUrls.toggleFollowSeries(id),{});
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
