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

  Future<dynamic> getSports() async {
    try {
      final response = await _apiServices.getApi(AppUrls.sports);
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

  Future<dynamic> watchMatch(String id) async {
    try {
      final response = await _apiServices.getApi(AppUrls.watchMatch(id));
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getMatchDetails(String id) async {
    try {
      // Trying standard GET /matches/:id
      final response = await _apiServices.getApi("${AppUrls.matches}/$id");
      return response;
    } catch (e) {
      // Fallback to watchMatch if standard doesn't work, as it also returns match object
      return await watchMatch(id);
    }
  }

  Future<dynamic> getBannerAds() async {
    try {
      final response = await _apiServices.getApi(AppUrls.bannerAds);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getPlayers() async {
    try {
      final response = await _apiServices.getApi(AppUrls.players);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getStarPlayers() async {
    try {
      final response = await _apiServices.getApi(AppUrls.starPlayers);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getPodcasts() async {
    try {
      final response = await _apiServices.getApi(AppUrls.podcasts);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Future<dynamic> getMatchHighlights(String matchId) async {
  //   try {
  //     final response = await _apiServices.getApi(AppUrls.matchHighlights(matchId));
  //     return response;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  Future<dynamic> getMatchComments(String itemId) async {
    try {
      final response = await _apiServices.getApi(AppUrls.getComments(itemId));
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> addComment(String itemId, String comment) async {
    try {
      final response = await _apiServices.postApi(AppUrls.comments, {
        'itemId': itemId,
        'comment': comment,
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getLiveScore(String matchId) async {
    try {
      final response = await _apiServices.getApi(AppUrls.liveScore(matchId));
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getScoreboard(String matchId) async {
    try {
      final response = await _apiServices.getApi(AppUrls.scoreboard(matchId));
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getMatchPlayers(String matchId) async {
    try {
      final response = await _apiServices.getApi(AppUrls.matchPlayers(matchId));
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getMatchStats(String matchId) async {
    try {
      final response = await _apiServices.getApi(AppUrls.matchStats(matchId));
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getMatchTopPerformers(String matchId) async {
    try {
      final response = await _apiServices.getApi(AppUrls.matchTopPerformers(matchId));
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getMatchEvents(String matchId) async {
    try {
      final response = await _apiServices.getApi(AppUrls.matchEvents(matchId));
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getLiveStreams() async {
    try {
      final response = await _apiServices.getApi(AppUrls.liveStreams);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getHighlights({String? matchId}) async {
    try {
      String url = AppUrls.highlights;
      if (matchId != null) {
        url += "?matchId=$matchId";
      }
      final response = await _apiServices.getApi(url);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
