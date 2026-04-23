import 'package:get/get.dart';
import 'package:play_on_app/model/response_model/notification_model.dart';
import 'package:play_on_app/repo/notification_repository.dart';

import '../../data/api_responce_data.dart';

class NotificationController extends GetxController {
  final _api = NotificationRepository();

  final notificationList = ApiResponse<NotificationModel>.loading().obs;
  final unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }

  void refreshData() {
    fetchNotifications();
    fetchReadCount();
  }

  void fetchNotifications() {
    notificationList.value = ApiResponse.loading();
    _api.getNotifications().then((value) {
      final model = NotificationModel.fromJson(value);
      notificationList.value = ApiResponse.completed(model);
      
      // Once notifications are loaded, we have the 'total' count.
      // Call fetchReadCount again to ensure unread calculation is accurate.
      fetchReadCount();
    }).onError((error, stackTrace) {
      notificationList.value = ApiResponse.error(error.toString());
    });
  }

  void fetchReadCount() {
    _api.getReadCount().then((value) {
      if (value['success'] == true) {
        // Based on logs: {success: true, readCount: 0}
        // Notification list response shows 'count' as total (e.g., 13)
        
        int total = value['total'] ?? (notificationList.value.data?.count ?? 0);
        int read = value['readCount'] ?? value['read'] ?? 0;
        
        int calculatedUnread = total - read;
        
        // If the API response contains 'count' and it's not 'total', it might be the unread count
        if (value.containsKey('count') && !value.containsKey('total')) {
          unreadCount.value = value['count'] ?? 0;
        } else {
          unreadCount.value = calculatedUnread > 0 ? calculatedUnread : 0;
        }
        
        print("Unread Count calculated: ${unreadCount.value} (Total: $total, Read: $read)");
      }
    }).onError((error, stackTrace) {
      print("Error fetching read count: $error");
    });
  }

  void markAsRead(String id) {
    _api.markAsRead(id).then((value) {
      if (value['success'] == true) {
        // Refresh local list or update specific item
        fetchNotifications();
        fetchReadCount();
      }
    }).onError((error, stackTrace) {
      print("Error marking notification as read: $error");
    });
  }

  void markAllAsRead() {
    _api.markAllAsRead().then((value) {
      if (value['success'] == true) {
        fetchNotifications();
        fetchReadCount();
      }
    }).onError((error, stackTrace) {
      print("Error marking all notifications as read: $error");
    });
  }

  void deleteNotification(String id) {
    _api.deleteNotification(id).then((value) {
      if (value['success'] == true) {
        fetchNotifications();
        fetchReadCount();
      }
    }).onError((error, stackTrace) {
      print("Error deleting notification: $error");
    });
  }
}
