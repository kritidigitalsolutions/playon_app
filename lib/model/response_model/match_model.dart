class MatchModel {
  bool? success;
  int? total;
  int? page;
  int? limit;
  List<Match>? matches;

  MatchModel({this.success, this.total, this.page, this.limit, this.matches});

  MatchModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    total = json['total'];
    page = json['page'];
    limit = json['limit'];
    if (json['matches'] != null) {
      matches = <Match>[];
      json['matches'].forEach((v) {
        matches!.add(Match.fromJson(v));
      });
    }
  }
}

class Match {
  String? sId;
  String? title;
  String? sport;
  String? teamA;
  String? teamB;
  String? teamALogo;
  String? teamBLogo;
  String? tournament;
  String? venue;
  String? matchDate;
  String? status;
  String? thumbnail;
  String? banner;
  String? score;
  String? description;
  bool? isFeatured;
  bool? isTrending;
  bool? isPremium;
  bool? isSeriesPremium; // Added to track parent series premium status
  String? liveStartedAt;
  String? liveEndedAt;
  String? seriesId;
  String? createdAt;
  String? updatedAt;

  Match(
      {this.sId,
      this.title,
      this.sport,
      this.teamA,
      this.teamB,
      this.teamALogo,
      this.teamBLogo,
      this.tournament,
      this.venue,
      this.matchDate,
      this.status,
      this.thumbnail,
      this.banner,
      this.score,
      this.description,
      this.isFeatured,
      this.isTrending,
      this.isPremium,
      this.isSeriesPremium,
      this.liveStartedAt,
      this.liveEndedAt,
      this.seriesId,
      this.createdAt,
      this.updatedAt});

  Match.fromJson(Map<String, dynamic> json) {
    sId = json['_id'] ?? json['id'];
    title = json['title'];
    sport = json['sport'];
    teamA = json['teamA'];
    teamB = json['teamB'];
    teamALogo = json['teamALogo'];
    teamBLogo = json['teamBLogo'];
    tournament = json['tournament'];
    venue = json['venue'];
    matchDate = json['matchDate'];
    status = json['status'];
    thumbnail = json['thumbnail'];
    banner = json['banner'];
    score = json['score'];
    description = json['description'];
    isFeatured = json['isFeatured'];
    isTrending = json['isTrending'];
    isPremium = json['isPremium'];
    isSeriesPremium = json['isSeriesPremium'];
    liveStartedAt = json['liveStartedAt'];
    liveEndedAt = json['liveEndedAt'];
    seriesId = json['seriesId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }
}

class WatchMatchResponse {
  bool? success;
  String? message;
  MatchStream? stream;
  Match? match;

  WatchMatchResponse({this.success, this.message, this.stream, this.match});

  WatchMatchResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    stream = json['stream'] != null ? MatchStream.fromJson(json['stream']) : null;
    match = json['match'] != null ? Match.fromJson(json['match']) : null;
  }
}

class MatchStream {
  String? streamUrl;
  String? streamType;

  MatchStream({this.streamUrl, this.streamType});

  MatchStream.fromJson(Map<String, dynamic> json) {
    streamUrl = json['streamUrl'];
    streamType = json['streamType'];
  }
}
