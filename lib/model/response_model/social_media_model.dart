class SocialMediaResponse {
  bool? success;
  int? count;
  List<SocialMedia>? social;

  SocialMediaResponse({this.success, this.count, this.social});

  SocialMediaResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    count = json['count'];
    if (json['social'] != null) {
      social = <SocialMedia>[];
      json['social'].forEach((v) {
        social!.add(SocialMedia.fromJson(v));
      });
    }
  }
}

class SocialMedia {
  String? sId;
  String? platform;
  String? url;
  String? createdAt;
  String? updatedAt;
  int? iV;

  SocialMedia(
      {this.sId,
      this.platform,
      this.url,
      this.createdAt,
      this.updatedAt,
      this.iV});

  SocialMedia.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    platform = json['platform'];
    url = json['url'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }
}
