class NotificationModel {
  bool? success;
  int? count;
  List<NotificationData>? notifications;

  NotificationModel({this.success, this.count, this.notifications});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    count = json['count'];
    if (json['notifications'] != null) {
      notifications = <NotificationData>[];
      json['notifications'].forEach((v) {
        notifications!.add(NotificationData.fromJson(v));
      });
    }
  }
}

class NotificationData {
  String? id;
  String? title;
  String? message;
  String? type;
  Metadata? metadata;
  bool? isRead;
  String? sentAt;
  String? createdAt;
  String? image;

  NotificationData({
    this.id,
    this.title,
    this.message,
    this.type,
    this.metadata,
    this.isRead,
    this.sentAt,
    this.createdAt,
    this.image,
  });

  NotificationData.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    title = json['title'];
    message = json['message'];
    type = json['type'];
    metadata = json['metadata'] != null ? Metadata.fromJson(json['metadata']) : null;
    isRead = json['isRead'];
    sentAt = json['sentAt'];
    createdAt = json['createdAt'];
    image = json['image'];
  }
}

class Metadata {
  String? matchId;
  String? streamId;
  String? channelId;
  String? image;

  Metadata({this.matchId, this.streamId, this.channelId, this.image});

  Metadata.fromJson(Map<String, dynamic> json) {
    matchId = json['matchId'];
    streamId = json['streamId'];
    channelId = json['channelId'];
    image = json['image'];
  }
}
