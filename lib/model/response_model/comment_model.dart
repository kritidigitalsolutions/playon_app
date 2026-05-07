class CommentModel {
  bool? success;
  int? count;
  List<Comment>? comments;

  CommentModel({
    this.success,
    this.count,
    this.comments,
  });

  CommentModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    count = json['count'];

    if (json['comments'] != null) {
      comments = (json['comments'] as List)
          .map((e) => Comment.fromJson(e))
          .toList();
    } else {
      comments = [];
    }
  }
}

class Comment {
  String? sId;
  String? userId;
  String? userName;
  String? userImage;
  String? itemId;
  String? comment;
  String? createdAt;
  bool? isDeleted;

  Comment({
    this.sId,
    this.userId,
    this.userName,
    this.userImage,
    this.itemId,
    this.comment,
    this.createdAt,
    this.isDeleted,
  });

  Comment.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];

    /// HANDLE POPULATED USER
    if (json['userId'] is Map<String, dynamic>) {
      userId = json['userId']['_id'];
      userName = json['userId']['fullName'];
      userImage = json['userId']['profilePic'];
    }

    /// HANDLE NORMAL USER ID
    else {
      userId = json['userId']?.toString();
      userName = json['userName'];
      userImage = json['userImage'];
    }

    itemId = json['itemId']?.toString();
    comment = json['comment'];
    createdAt = json['createdAt'];
    isDeleted = json['isDeleted'];
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'itemId': itemId,
      'comment': comment,
      'createdAt': createdAt,
      'isDeleted': isDeleted,
    };
  }
}
