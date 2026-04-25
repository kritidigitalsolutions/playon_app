import 'package:get/get.dart';
import 'package:play_on_app/repo/watchlist_repository.dart';
import 'package:play_on_app/repo/match_repository.dart';
import 'package:play_on_app/model/response_model/match_model.dart';

class WatchlistController extends GetxController {
  final WatchlistRepository _repository = WatchlistRepository();
  final MatchRepository _matchRepository = MatchRepository();

  var watchlistItems = <Match>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWatchlist();
  }

  Future<void> fetchWatchlist() async {
    isLoading.value = true;
    try {
      final response = await _repository.getWatchlist();
      if (response['success'] == true && response['items'] != null) {
        List<Match> matches = [];

        // Watchlist API se sirf IDs mil rahi hain, isliye har ID ke liye Match details API call karni hogi
        for (var item in response['items']) {
          // Case 1: Agar backend ne poora object bheja ho (itemId: { ... })
          if (item['itemId'] != null && item['itemId'] is Map) {
            matches.add(Match.fromJson(item['itemId']));
          } 
          // Case 2: Agar backend se sirf String ID mili ho (itemId: "69e6...")
          else if (item['itemId'] != null && item['itemId'] is String) {
            final String id = item['itemId'];
            try {
              // API call to get full match details
              final matchRes = await _matchRepository.getMatchDetails(id);
              if (matchRes['success'] == true && matchRes['match'] != null) {
                matches.add(Match.fromJson(matchRes['match']));
              }
            } catch (e) {
              print("Error fetching details for match $id from API: $e");
            }
          }
        }
        watchlistItems.assignAll(matches);
      }
    } catch (e) {
      print("Error fetching watchlist: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> toggleWatchlist(String itemId, String itemType) async {
    try {
      final response = await _repository.toggleWatchlist({
        "itemId": itemId,
        "itemType": itemType,
      });
      if (response['success'] == true) {
        await fetchWatchlist(); // API se refresh karega data
        return true;
      }
      return false;
    } catch (e) {
      print("Error toggling watchlist: $e");
      return false;
    }
  }

  Future<bool> isBookmarked(String type, String id) async {
    try {
      final response = await _repository.checkWatchlistStatus(type, id);
      return response['inWatchlist'] ?? false;
    } catch (e) {
      return false;
    }
  }
}
