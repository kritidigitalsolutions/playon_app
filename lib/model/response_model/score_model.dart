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
  List<Inning>? innings;

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
      this.country,
      this.innings});

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
    if (json['innings'] != null) {
      innings = <Inning>[];
      json['innings'].forEach((v) {
        innings!.add(Inning.fromJson(v));
      });
    }
  }
}

class Inning {
  int? inningNumber;
  String? team;
  String? teamLogo;
  List<Batsman>? batsmen;
  List<Bowler>? bowlers;
  List<FallOfWicket>? fallOfWickets;
  int? extras;
  int? wides;
  int? noBalls;

  Inning(
      {this.inningNumber,
      this.team,
      this.teamLogo,
      this.batsmen,
      this.bowlers,
      this.fallOfWickets,
      this.extras,
      this.wides,
      this.noBalls});

  Inning.fromJson(Map<String, dynamic> json) {
    inningNumber = json['inningNumber'];
    team = json['team'];
    teamLogo = json['teamLogo'];
    if (json['batsmen'] != null) {
      batsmen = <Batsman>[];
      json['batsmen'].forEach((v) {
        batsmen!.add(Batsman.fromJson(v));
      });
    }
    if (json['bowlers'] != null) {
      bowlers = <Bowler>[];
      json['bowlers'].forEach((v) {
        bowlers!.add(Bowler.fromJson(v));
      });
    }
    if (json['fallOfWickets'] != null) {
      fallOfWickets = <FallOfWicket>[];
      json['fallOfWickets'].forEach((v) {
        fallOfWickets!.add(FallOfWicket.fromJson(v));
      });
    }
    extras = json['extras'];
    wides = json['wides'];
    noBalls = json['noBalls'];
  }
}

class Batsman {
  String? name;
  dynamic runs;
  dynamic balls;
  dynamic fours;
  dynamic sixes;
  dynamic strikeRate;
  String? dismissal;

  Batsman(
      {this.name,
      this.runs,
      this.balls,
      this.fours,
      this.sixes,
      this.strikeRate,
      this.dismissal});

  Batsman.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    runs = json['runs'];
    balls = json['balls'];
    fours = json['fours'];
    sixes = json['sixes'];
    strikeRate = json['strikeRate'];
    dismissal = json['dismissal'];
  }
}

class Bowler {
  String? name;
  dynamic overs;
  dynamic wickets;
  dynamic runs;
  dynamic economy;
  dynamic maidens;

  Bowler(
      {this.name,
      this.overs,
      this.wickets,
      this.runs,
      this.economy,
      this.maidens});

  Bowler.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    overs = json['overs'];
    wickets = json['wickets'];
    runs = json['runs'];
    economy = json['economy'];
    maidens = json['maidens'];
  }
}

class FallOfWicket {
  dynamic runs;
  int? order;
  dynamic overs;
  DismissalBatsman? dismissalBatsman;

  FallOfWicket({this.runs, this.order, this.overs, this.dismissalBatsman});

  FallOfWicket.fromJson(Map<String, dynamic> json) {
    runs = json['runs'];
    order = json['order'];
    overs = json['overs'];
    dismissalBatsman = json['dismissalBatsman'] != null
        ? DismissalBatsman.fromJson(json['dismissalBatsman'])
        : null;
  }
}

class DismissalBatsman {
  String? name;

  DismissalBatsman({this.name});

  DismissalBatsman.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }
}
