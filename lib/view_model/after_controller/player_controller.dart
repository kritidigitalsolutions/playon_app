import 'package:get/get.dart';
import 'package:play_on_app/model/response_model/player_model.dart';
import 'package:play_on_app/routes/app_routes.dart';

import '../../repo/player_repository.dart';


class PlayerController extends GetxController {
  final _api = PlayerRepository();

  final RxBool loading = false.obs;
  final RxList<Player> playerList = <Player>[].obs;
  final RxList<Player> allAvailablePlayers = <Player>[].obs; // For dropdown data
  final RxList<Player> followedPlayers = <Player>[].obs;
  
  // Home screen specific lists
  final RxList<Player> cricketPlayers = <Player>[].obs;
  final RxList<Player> indiaPlayers = <Player>[].obs;

  @override
  void onInit() {
    super.onInit();
    initialFetch();
    fetchFollowedPlayers();
  }

  // Gets all players once to populate dropdown options and home lists
  Future<void> initialFetch() async {
    try {
      final response = await _api.getAllPlayers();
      PlayerModel playerModel = PlayerModel.fromJson(response);
      if (playerModel.success == true && playerModel.players != null) {
        allAvailablePlayers.value = playerModel.players!;
        playerList.value = playerModel.players!;
        
        // Populate home screen lists
        cricketPlayers.value = playerList.where((p) => p.sport?.toLowerCase() == 'cricket').toList();
        indiaPlayers.value = playerList.where((p) => p.team?.toLowerCase() == 'india').toList();

        // Enrich followed players if they were already fetched
        _enrichFollowedPlayers();
      }
    } catch (e) {
      print("Error in initial fetch: $e");
    }
  }

  void _enrichFollowedPlayers() {
    if (allAvailablePlayers.isEmpty || followedPlayers.isEmpty) return;
    
    // Create a map for faster lookup
    final Map<String, Player> allPlayersMap = {
      for (var p in allAvailablePlayers) if (p.id != null) p.id!: p
    };

    final enriched = followedPlayers.map((fp) {
      if (fp.id != null && allPlayersMap.containsKey(fp.id)) {
        return allPlayersMap[fp.id]!;
      }
      return fp;
    }).toList();

    followedPlayers.value = enriched;
  }

  // Fetch with API-side filtering
  Future<void> fetchPlayers({String? search, String? sport, String? country}) async {
    loading.value = true;
    try {
      final response = await _api.getAllPlayers(search: search, sport: sport, country: country);
      PlayerModel playerModel = PlayerModel.fromJson(response);
      if (playerModel.success == true && playerModel.players != null) {
        playerList.value = playerModel.players!;
      }
    } catch (e) {
      print("Error fetching players: $e");
      // snackBar("Error", "Failed to search players");
    } finally {
      loading.value = false;
    }
  }

  Future<void> fetchFollowedPlayers() async {
    try {
      final response = await _api.getFollowedPlayers();
      PlayerModel playerModel = PlayerModel.fromJson(response);
      if (playerModel.success == true && playerModel.players != null) {
        followedPlayers.value = playerModel.players!;
        // Enrich data from allAvailablePlayers
        _enrichFollowedPlayers();
      }
    } catch (e) {
      print("Error fetching followed players: $e");
    }
  }

  Future<void> toggleFollow(String playerId) async {
    try {
      final response = await _api.toggleFollow(playerId);
      if (response['success'] == true) {
        // Toggle locally to reflect UI changes instantly
        int index = followedPlayers.indexWhere((p) => p.id == playerId);
        if (index != -1) {
          followedPlayers.removeAt(index);
          // Utils.snackBar("Success", "Unfollowed successfully");
        } else {
          // Find player object to add to followed list
          var player = playerList.firstWhereOrNull((p) => p.id == playerId) ?? 
                       allAvailablePlayers.firstWhereOrNull((p) => p.id == playerId);
          if (player != null) {
            followedPlayers.add(player);
            // Utils.snackBar("Success", "Followed successfully");
          } else {
            fetchFollowedPlayers(); // Fallback to API if not found locally
          }
        }
        followedPlayers.refresh();
      } else {
        // Utils.snackBar("Error", response['message'] ?? "Action failed");
      }
    } catch (e) {
      // Utils.snackBar("Error", e.toString());
    }
  }

  bool isFollowed(String? playerId) {
    if (playerId == null) return false;
    return followedPlayers.any((p) => p.id == playerId);
  }

  List<String> getAvailableSports() {
    return allAvailablePlayers.map((p) => p.sport ?? "Unknown").toSet().toList()..sort();
  }

  List<String> getAvailableCountries(String? selectedSport) {
    if (selectedSport == null || selectedSport.isEmpty) {
      return allAvailablePlayers.map((p) => p.country ?? "Unknown").toSet().toList()..sort();
    }
    return allAvailablePlayers
        .where((p) => p.sport == selectedSport)
        .map((p) => p.country ?? "Unknown")
        .toSet()
        .toList()
      ..sort();
  }

  Future<void> navigateToPlayerDetail(String playerId) async {
    loading.value = true;
    try {
      // Check if we have the player in our local list first
      var player = allAvailablePlayers.firstWhereOrNull((p) => p.id == playerId);
      
      if (player == null) {
        // If not found, fetch all players again or fetch specific player if API exists
        await initialFetch();
        player = allAvailablePlayers.firstWhereOrNull((p) => p.id == playerId);
      }

      if (player != null) {
        Get.toNamed(AppRoutes.playerDetail, arguments: player);
      } else {
        // Try to create a minimal player object if still not found to allow navigation
        // This handles cases where star player might reference a player not in the main list
        Get.toNamed(AppRoutes.playerDetail, arguments: Player(id: playerId));
      }
    } catch (e) {
      print("Error navigating to player detail: $e");
    } finally {
      loading.value = false;
    }
  }
}
