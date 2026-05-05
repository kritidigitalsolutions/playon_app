class CommentModel {
  bool? success;
  int? count;
  List<Comment>? comments;

  CommentModel({this.success, this.count, this.comments});

  CommentModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    count = json['count'];
    if (json['comments'] != null) {
      comments = <Comment>[];
      json['comments'].forEach((v) {
        comments!.add(Comment.fromJson(v));
      });
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

  Comment({
    this.sId,
    this.userId,
    this.userName,
    this.userImage,
    this.itemId,
    this.comment,
    this.createdAt,
  });

  Comment.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    if (json['userId'] is Map) {
      userId = json['userId']['_id'];
      userName = json['userId']['fullName'];
      userImage = json['userId']['profilePic'];
    } else {
      userId = json['userId'];
      userName = json['userName'];
      userImage = json['userImage'];
    }
    itemId = json['itemId'];
    comment = json['comment'];
    createdAt = json['createdAt'];
  }
}
