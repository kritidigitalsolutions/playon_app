import 'match_model.dart';

class HighlightModel {
  bool? success;
  List<HighlightItem>? highlights;
  HighlightItem? highlight; // For single highlight response

  HighlightModel({this.success, this.highlights, this.highlight});

  HighlightModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['highlights'] != null) {
      highlights = <HighlightItem>[];
      json['highlights'].forEach((v) {
        highlights!.add(HighlightItem.fromJson(v));
      });
    }
    if (json['highlight'] != null) {
      highlight = HighlightItem.fromJson(json['highlight']);
    }
  }
}

class HighlightItem {
  String? sId;
  MatchId? matchId;
  String? title;
  String? description;
  String? category;
  String? sourceType;
  String? videoUrl;
  String? thumbnail;
  String? duration;
  List<String>? tags;
  bool? isPremium;
  int? order;
  String? createdAt;
  String? updatedAt;

  HighlightItem(
      {this.sId,
      this.matchId,
      this.title,
      this.description,
      this.category,
      this.sourceType,
      this.videoUrl,
      this.thumbnail,
      this.duration,
      this.tags,
      this.isPremium,
      this.order,
      this.createdAt,
      this.updatedAt});

  HighlightItem.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    matchId = json['matchId'] != null ? MatchId.fromJson(json['matchId']) : null;
    title = json['title'];
    description = json['description'];
    category = json['category'];
    sourceType = json['sourceType'];
    videoUrl = json['videoUrl'];
    thumbnail = json['thumbnail'];
    duration = json['duration'];
    tags = json['tags']?.cast<String>();
    isPremium = json['isPremium'];
    order = json['order'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }
}

class MatchId {
  String? sId;
  String? title;
  String? sport;
  String? teamA;
  String? teamB;
  String? tournament;
  String? status;

  MatchId(
      {this.sId,
      this.title,
      this.sport,
      this.teamA,
      this.teamB,
      this.tournament,
      this.status});

  MatchId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    sport = json['sport'];
    teamA = json['teamA'];
    teamB = json['teamB'];
    tournament = json['tournament'];
    status = json['status'];
  }
}
