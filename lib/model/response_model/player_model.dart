class PlayerModel {
  bool? success;
  int? count;
  List<Player>? players;

  PlayerModel({this.success, this.count, this.players});

  PlayerModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    count = json['count'];
    if (json['players'] != null) {
      players = <Player>[];
      json['players'].forEach((v) {
        players!.add(Player.fromJson(v));
      });
    }
  }
}

class Player {
  String? id;
  String? name;
  String? slug;
  String? sport;
  String? team;
  String? position;
  String? country;
  String? image;
  String? bio;
  bool? featured;
  String? status;
  String? createdAt;
  String? updatedAt;

  Player(
      {this.id,
      this.name,
      this.slug,
      this.sport,
      this.team,
      this.position,
      this.country,
      this.image,
      this.bio,
      this.featured,
      this.status,
      this.createdAt,
      this.updatedAt});

  Player.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];
    slug = json['slug'];
    sport = json['sport'];
    team = json['team'];
    position = json['position'];
    country = json['country'];
    image = json['image'];
    bio = json['bio'];
    featured = json['featured'];
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }
}
