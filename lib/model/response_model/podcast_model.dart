class PodcastModel {
  bool? success;
  int? count;
  List<Podcast>? podcasts;

  PodcastModel({this.success, this.count, this.podcasts});

  PodcastModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    count = json['count'];
    if (json['podcasts'] != null) {
      podcasts = <Podcast>[];
      json['podcasts'].forEach((v) {
        podcasts!.add(Podcast.fromJson(v));
      });
    }
  }
}

class Podcast {
  String? sId;
  String? title;
  String? description;
  String? url;
  String? type;
  String? thumbnail;
  String? duration;
  String? category;
  bool? isFeatured;
  bool? isPremium;
  String? status;
  String? createdBy;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Podcast(
      {this.sId,
      this.title,
      this.description,
      this.url,
      this.type,
      this.thumbnail,
      this.duration,
      this.category,
      this.isFeatured,
      this.isPremium,
      this.status,
      this.createdBy,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Podcast.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    description = json['description'];
    url = json['url'];
    type = json['type'];
    thumbnail = json['thumbnail'];
    duration = json['duration'];
    category = json['category'];
    isFeatured = json['isFeatured'];
    isPremium = json['isPremium'];
    status = json['status'];
    createdBy = json['createdBy'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }
}
