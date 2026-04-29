import 'package:play_on_app/data/network/api_network_service.dart';
import 'package:play_on_app/res/app_urls.dart';

class ChannelRepository {
  final NetworkApiService _apiServices = NetworkApiService();

  Future<dynamic> getLiveChannels() async {
    try {
      final response = await _apiServices.getApi(AppUrls.liveChannels);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getChannelCategories() async {
    try {
      final response = await _apiServices.getApi(AppUrls.channelCategories);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
