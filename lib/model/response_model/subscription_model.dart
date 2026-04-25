import 'plan_model.dart';

class MySubscriptionResponse {
  bool? success;
  List<Subscription>? subscriptions;

  MySubscriptionResponse({this.success, this.subscriptions});

  MySubscriptionResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['subscriptions'] != null) {
      subscriptions = <Subscription>[];
      json['subscriptions'].forEach((v) {
        subscriptions!.add(Subscription.fromJson(v));
      });
    } else if (json['subscription'] != null) {
      subscriptions = [Subscription.fromJson(json['subscription'])];
    }
  }
}

class SubscriptionHistoryResponse {
  bool? success;
  int? count;
  List<Subscription>? subscriptions;

  SubscriptionHistoryResponse({this.success, this.count, this.subscriptions});

  SubscriptionHistoryResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    count = json['count'];
    if (json['subscriptions'] != null) {
      subscriptions = <Subscription>[];
      json['subscriptions'].forEach((v) {
        subscriptions!.add(Subscription.fromJson(v));
      });
    }
  }
}

class Subscription {
  String? id;
  String? userId;
  Plan? planId;
  String? status;
  String? startDate;
  String? endDate;
  int? amountPaid;
  String? paymentId;
  bool? autoRenew;
  bool? isDeleted;
  String? deletedAt;
  String? createdAt;
  String? updatedAt;
  String? matchId;
  String? seriesId;
  String? teamId;

  Subscription({
    this.id,
    this.userId,
    this.planId,
    this.status,
    this.startDate,
    this.endDate,
    this.amountPaid,
    this.paymentId,
    this.autoRenew,
    this.isDeleted,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.matchId,
    this.seriesId,
    this.teamId,
  });

  Subscription.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    userId = json['userId'];
    planId = json['planId'] != null ? (json['planId'] is String ? Plan(id: json['planId']) : Plan.fromJson(json['planId'])) : null;
    status = json['status'];
    startDate = json['startDate'];
    endDate = json['endDate'];
    amountPaid = json['amountPaid'];
    paymentId = json['paymentId'];
    autoRenew = json['autoRenew'];
    isDeleted = json['isDeleted'];
    deletedAt = json['deletedAt'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    
    // Handle both String and Object for IDs
    if (json['matchId'] != null) {
      matchId = json['matchId'] is Map ? json['matchId']['_id'] : json['matchId'];
    }
    if (json['seriesId'] != null) {
      seriesId = json['seriesId'] is Map ? json['seriesId']['_id'] : json['seriesId'];
    }
    if (json['teamId'] != null) {
      teamId = json['teamId'] is Map ? json['teamId']['_id'] : json['teamId'];
    }
  }
}

class CheckAccessResponse {
  bool? success;
  bool? hasAccess;

  CheckAccessResponse({this.success, this.hasAccess});

  CheckAccessResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    hasAccess = json['hasAccess'];
  }
}
