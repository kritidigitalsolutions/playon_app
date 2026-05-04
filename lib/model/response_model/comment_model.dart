class CommentModel {
  bool? success;
  List<Comment>? data;

  CommentModel({this.success, this.data});

  CommentModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Comment>[];
      json['data'].forEach((v) {
        data!.add(Comment.fromJson(v));
      });
    }
  }
}

class Comment {
  String? sId;
  String? userId;
  String? userName;
  String? userImage;
  String? matchId;
  String? comment;
  String? createdAt;

  Comment({
    this.sId,
    this.userId,
    this.userName,
    this.userImage,
    this.matchId,
    this.comment,
    this.createdAt,
  });

  Comment.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    userName = json['userName'];
    userImage = json['userImage'];
    matchId = json['matchId'];
    comment = json['comment'];
    createdAt = json['createdAt'];
  }
}
