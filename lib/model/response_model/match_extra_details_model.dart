class MatchPlayersModel {
  bool? success;
  MatchPlayersData? data;

  MatchPlayersModel({this.success, this.data});

  MatchPlayersModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? MatchPlayersData.fromJson(json['data']) : null;
  }
}

class MatchPlayersData {
  String? matchId;
  String? homeTeam;
  String? awayTeam;
  List<Squad>? squad;

  MatchPlayersData({this.matchId, this.homeTeam, this.awayTeam, this.squad});

  MatchPlayersData.fromJson(Map<String, dynamic> json) {
    matchId = json['matchId'];
    homeTeam = json['homeTeam'];
    awayTeam = json['awayTeam'];
    if (json['squad'] != null) {
      squad = <Squad>[];
      json['squad'].forEach((v) {
        squad!.add(Squad.fromJson(v));
      });
    }
  }
}

class Squad {
  String? team;
  String? teamLogo;
  List<MatchPlayer>? players;

  Squad({this.team, this.teamLogo, this.players});

  Squad.fromJson(Map<String, dynamic> json) {
    team = json['team'];
    teamLogo = json['teamLogo'];
    if (json['players'] != null) {
      players = <MatchPlayer>[];
      json['players'].forEach((v) {
        players!.add(MatchPlayer.fromJson(v));
      });
    }
  }
}

class MatchPlayer {
  String? name;
  List<String>? roles;
  String? battingStyle;
  String? bowlingStyle;

  MatchPlayer({this.name, this.roles, this.battingStyle, this.bowlingStyle});

  MatchPlayer.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    roles = json['roles']?.cast<String>();
    battingStyle = json['battingStyle'];
    bowlingStyle = json['bowlingStyle'];
  }
}

class MatchStatsModel {
  bool? success;
  MatchStatsData? data;

  MatchStatsModel({this.success, this.data});

  MatchStatsModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? MatchStatsData.fromJson(json['data']) : null;
  }
}

class MatchStatsData {
  String? matchId;
  String? format;
  List<InningStat>? stats;

  MatchStatsData({this.matchId, this.format, this.stats});

  MatchStatsData.fromJson(Map<String, dynamic> json) {
    matchId = json['matchId'];
    format = json['format'];
    if (json['stats'] != null) {
      stats = <InningStat>[];
      json['stats'].forEach((v) {
        stats!.add(InningStat.fromJson(v));
      });
    }
  }
}

class InningStat {
  int? inningNumber;
  String? team;
  int? totalRuns;
  int? totalFours;
  int? totalSixes;
  int? totalWickets;
  int? extras;
  int? wides;
  int? noBalls;

  InningStat(
      {this.inningNumber,
      this.team,
      this.totalRuns,
      this.totalFours,
      this.totalSixes,
      this.totalWickets,
      this.extras,
      this.wides,
      this.noBalls});

  InningStat.fromJson(Map<String, dynamic> json) {
    inningNumber = json['inningNumber'];
    team = json['team'];
    totalRuns = json['totalRuns'];
    totalFours = json['totalFours'];
    totalSixes = json['totalSixes'];
    totalWickets = json['totalWickets'];
    extras = json['extras'];
    wides = json['wides'];
    noBalls = json['noBalls'];
  }
}

class TopPerformersModel {
  bool? success;
  TopPerformersData? data;

  TopPerformersModel({this.success, this.data});

  TopPerformersModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? TopPerformersData.fromJson(json['data']) : null;
  }
}

class TopPerformersData {
  String? matchId;
  TopPerformers? topPerformers;

  TopPerformersData({this.matchId, this.topPerformers});

  TopPerformersData.fromJson(Map<String, dynamic> json) {
    matchId = json['matchId'];
    topPerformers = json['topPerformers'] != null
        ? TopPerformers.fromJson(json['topPerformers'])
        : null;
  }
}

class TopPerformers {
  List<TopBatsman>? batsmen;
  List<TopBowler>? bowlers;

  TopPerformers({this.batsmen, this.bowlers});

  TopPerformers.fromJson(Map<String, dynamic> json) {
    if (json['batsmen'] != null) {
      batsmen = <TopBatsman>[];
      json['batsmen'].forEach((v) {
        batsmen!.add(TopBatsman.fromJson(v));
      });
    }
    if (json['bowlers'] != null) {
      bowlers = <TopBowler>[];
      json['bowlers'].forEach((v) {
        bowlers!.add(TopBowler.fromJson(v));
      });
    }
  }
}

class TopBatsman {
  String? name;
  String? team;
  String? teamLogo;
  List<String>? roles;
  int? runs;
  double? average;
  double? strikeRate;
  int? innings;

  TopBatsman(
      {this.name,
      this.team,
      this.teamLogo,
      this.roles,
      this.runs,
      this.average,
      this.strikeRate,
      this.innings});

  TopBatsman.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    team = json['team'];
    teamLogo = json['teamLogo'];
    roles = json['roles']?.cast<String>();
    runs = json['runs'];
    average = json['average']?.toDouble();
    strikeRate = json['strikeRate']?.toDouble();
    innings = json['innings'];
  }
}

class TopBowler {
  String? name;
  String? team;
  String? teamLogo;
  List<String>? roles;
  int? wickets;
  double? economy;
  double? average;
  int? innings;

  TopBowler(
      {this.name,
      this.team,
      this.teamLogo,
      this.roles,
      this.wickets,
      this.economy,
      this.average,
      this.innings});

  TopBowler.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    team = json['team'];
    teamLogo = json['teamLogo'];
    roles = json['roles']?.cast<String>();
    wickets = json['wickets'];
    economy = json['economy']?.toDouble();
    average = json['average']?.toDouble();
    innings = json['innings'];
  }
}

class MatchEventsModel {
  bool? success;
  MatchEventsData? data;

  MatchEventsModel({this.success, this.data});

  MatchEventsModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? MatchEventsData.fromJson(json['data']) : null;
  }
}

class MatchEventsData {
  String? matchId;
  List<MatchEvent>? events;

  MatchEventsData({this.matchId, this.events});

  MatchEventsData.fromJson(Map<String, dynamic> json) {
    matchId = json['matchId'];
    if (json['events'] != null) {
      events = <MatchEvent>[];
      json['events'].forEach((v) {
        events!.add(MatchEvent.fromJson(v));
      });
    }
  }
}

class MatchEvent {
  String? type;
  int? inning;
  int? runs;
  double? overs;
  String? batsman;
  String? text;

  MatchEvent(
      {this.type, this.inning, this.runs, this.overs, this.batsman, this.text});

  MatchEvent.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    inning = json['inning'];
    runs = json['runs'];
    overs = json['overs']?.toDouble();
    batsman = json['batsman'];
    text = json['text'];
  }
}
