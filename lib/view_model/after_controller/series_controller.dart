import 'package:get/get.dart';
import 'package:play_on_app/model/response_model/series_model.dart';
import 'package:play_on_app/repo/match_repository.dart';

class SeriesController extends GetxController {
  final MatchRepository _matchRepository = MatchRepository();

  var isLoading = false.obs;
  var allSeries = <Series>[].obs;
  var followedSeriesList = <Series>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchSeries();
    fetchFollowedSeries();
  }

  Future<void> fetchSeries() async {
    isLoading.value = true;
    try {
      final res = await _matchRepository.getSeries();
      if (res['success'] == true) {
        final data = SeriesModel.fromJson(res);
        allSeries.value = data.series ?? [];
      }
    } catch (e) {
      print("Error fetching series: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchFollowedSeries() async {
    try {
      final res = await _matchRepository.getFollowedSeries();
      if (res['success'] == true) {
        final data = SeriesModel.fromJson(res);
        followedSeriesList.value = data.series ?? [];
      }
    } catch (e) {
      print("Error fetching followed series: $e");
    }
  }

  Future<void> toggleFollowSeries(String id) async {
    try {
      final res = await _matchRepository.toggleFollowSeries(id);
      if (res['success'] == true) {
        await fetchFollowedSeries(); // Refresh the followed list
        fetchSeries(); // Also refresh all series to update status if needed
      }
    } catch (e) {
      print("Error toggling follow series: $e");
    }
  }

  bool isSeriesFollowed(String id) {
    return followedSeriesList.any((s) => s.sId == id);
  }
}
