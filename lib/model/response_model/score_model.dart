class ScoreModel {
  bool? success;
  ScoreData? data;

  ScoreModel({this.success, this.data});

  ScoreModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? ScoreData.fromJson(json['data']) : null;
  }
}

class ScoreData {
  String? matchId;
  String? title;
  String? sport;
  String? status;
  String? homeTeam;
  String? awayTeam;
  String? homeLogo;
  String? awayLogo;
  String? homeScore;
  String? awayScore;
  String? homeInfo;
  String? awayInfo;
  String? report;
  String? league;
  String? format;
  String? startDate;
  String? country;

  ScoreData(
      {this.matchId,
      this.title,
      this.sport,
      this.status,
      this.homeTeam,
      this.awayTeam,
      this.homeLogo,
      this.awayLogo,
      this.homeScore,
      this.awayScore,
      this.homeInfo,
      this.awayInfo,
      this.report,
      this.league,
      this.format,
      this.startDate,
      this.country});

  ScoreData.fromJson(Map<String, dynamic> json) {
    matchId = json['matchId'];
    title = json['title'];
    sport = json['sport'];
    status = json['status'];
    homeTeam = json['homeTeam'];
    awayTeam = json['awayTeam'];
    homeLogo = json['homeLogo'];
    awayLogo = json['awayLogo'];
    homeScore = json['homeScore'];
    awayScore = json['awayScore'];
    homeInfo = json['homeInfo'];
    awayInfo = json['awayInfo'];
    report = json['report'];
    league = json['league'];
    format = json['format'];
    startDate = json['startDate'];
    country = json['country'];
  }
}
