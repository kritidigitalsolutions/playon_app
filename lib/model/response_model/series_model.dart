import 'package:play_on_app/model/response_model/match_model.dart';

class SeriesModel {
  bool? success;
  int? count;
  List<Series>? series;

  SeriesModel({this.success, this.count, this.series});

  SeriesModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    count = json['count'];
    if (json['series'] != null) {
      series = <Series>[];
      json['series'].forEach((v) {
        series!.add(Series.fromJson(v));
      });
    }
  }
}

class Series {
  String? sId;
  String? title;
  String? sport;
  String? slug;
  String? banner;
  String? tournamentLogo;
  String? description;
  String? teamA;
  String? teamB;
  List<String>? teamAPlayers;
  List<String>? teamBPlayers;
  String? tourCountry;
  String? startDate;
  String? endDate;
  String? status;
  bool? isFeatured;
  bool? isPremium;
  String? createdBy;
  String? createdAt;
  String? updatedAt;
  int? iV;
  bool? isHomeScreen;
  List<SeriesMatch>? matches;
  List<Match>? fullMatches;
  int? totalMatches;
  String? matchScheduledDate;
  String? matchStatus;

  Series(
      {this.sId,
      this.title,
      this.sport,
      this.slug,
      this.banner,
      this.tournamentLogo,
      this.description,
      this.teamA,
      this.teamB,
      this.teamAPlayers,
      this.teamBPlayers,
      this.tourCountry,
      this.startDate,
      this.endDate,
      this.status,
      this.isFeatured,
      this.isPremium,
      this.createdBy,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.isHomeScreen,
      this.matches,
      this.fullMatches,
      this.totalMatches,
      this.matchScheduledDate,
      this.matchStatus});

  Series.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    sport = json['sport'];
    slug = json['slug'];
    banner = json['banner'];
    tournamentLogo = json['tournamentLogo'];
    description = json['description'];
    teamA = json['teamA'];
    teamB = json['teamB'];
    teamAPlayers = json['teamAPlayers'] != null ? List<String>.from(json['teamAPlayers']) : [];
    teamBPlayers = json['teamBPlayers'] != null ? List<String>.from(json['teamBPlayers']) : [];
    tourCountry = json['tourCountry'];
    startDate = json['startDate'];
    endDate = json['endDate'];
    status = json['status'];
    isFeatured = json['isFeatured'];
    isPremium = json['isPremium'];
    createdBy = json['createdBy'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    isHomeScreen = json['isHomeScreen'];
    if (json['matches'] != null) {
      matches = <SeriesMatch>[];
      json['matches'].forEach((v) {
        matches!.add(SeriesMatch.fromJson(v));
      });
    }
    totalMatches = json['totalMatches'];
    matchScheduledDate = json['matchScheduledDate'];
    matchStatus = json['matchStatus'];
  }
}

class SeriesMatch {
  String? sId;
  String? matchName;
  String? date;
  String? status;

  SeriesMatch({this.sId, this.matchName, this.date, this.status});

  SeriesMatch.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    matchName = json['matchName'];
    date = json['date'];
    status = json['status'];
  }
}
