import 'package:play_on_app/data/network/api_network_service.dart';
import 'package:play_on_app/res/app_urls.dart';
import 'package:play_on_app/utils/hive_service/hive_service.dart';

class NotificationRepository {
  final _apiService = NetworkApiService();

  void _prepare() {
    final token = HiveService.getToken();
    if (token != null) {
      _apiService.setToken(token);
    }
  }

  Future<dynamic> getNotifications() async {
    try {
      _prepare();
      final response = await _apiService.getApi(AppUrls.notifications);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> markAsRead(String id) async {
    try {
      _prepare();
      final response = await _apiService.patchApi(AppUrls.readNotification(id),{});
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> markAllAsRead() async {
    try {
      _prepare();
      final response = await _apiService.patchApi(AppUrls.readAllNotifications, {});
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> deleteNotification(String id) async {
    try {
      _prepare();
      final response = await _apiService.deleteApi(AppUrls.deleteNotification(id), {});
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getReadCount() async {
    try {
      _prepare();
      final response = await _apiService.getApi(AppUrls.notificationReadCount);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> updateFcmToken(String token) async {
    try {
      _prepare();
      final response = await _apiService.putApi(AppUrls.fcmToken, {
        "token": token
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
