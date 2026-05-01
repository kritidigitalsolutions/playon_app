class StarPlayerModel {
  bool? success;
  int? count;
  List<StarPlayer>? highlights;

  StarPlayerModel({this.success, this.count, this.highlights});

  StarPlayerModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    count = json['count'];
    if (json['highlights'] != null) {
      highlights = <StarPlayer>[];
      json['highlights'].forEach((v) {
        highlights!.add(StarPlayer.fromJson(v));
      });
    }
  }
}

class StarPlayer {
  String? sId;
  PlayerId? playerId; // Changed from String? to PlayerId?
  SportId? sportId;
  String? playerName;
  String? team;
  String? title;
  String? thumbnail;
  String? videoUrl;
  String? type;
  String? duration;
  bool? isFeatured;
  bool? isPremium;
  String? createdAt;
  String? updatedAt;

  StarPlayer(
      {this.sId,
      this.playerId,
      this.sportId,
      this.playerName,
      this.team,
      this.title,
      this.thumbnail,
      this.videoUrl,
      this.type,
      this.duration,
      this.isFeatured,
      this.isPremium,
      this.createdAt,
      this.updatedAt});

  StarPlayer.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    playerId = json['playerId'] != null ? PlayerId.fromJson(json['playerId']) : null;
    sportId = json['sportId'] != null ? SportId.fromJson(json['sportId']) : null;
    playerName = json['playerName'];
    team = json['team'];
    title = json['title'];
    thumbnail = json['thumbnail'];
    videoUrl = json['videoUrl'];
    type = json['type'];
    duration = json['duration'];
    isFeatured = json['isFeatured'];
    isPremium = json['isPremium'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }
}

class PlayerId {
  String? sId;
  String? name;
  String? team;
  String? country;
  String? image;

  PlayerId({this.sId, this.name, this.team, this.country, this.image});

  PlayerId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    team = json['team'];
    country = json['country'];
    image = json['image'];
  }
}

class SportId {
  String? sId;
  String? name;
  String? slug;

  SportId({this.sId, this.name, this.slug});

  SportId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    slug = json['slug'];
  }
}
