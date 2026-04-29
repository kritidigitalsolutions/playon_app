class HighlightModel {
  bool? success;
  HighlightData? data;

  HighlightModel({this.success, this.data});

  HighlightModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? HighlightData.fromJson(json['data']) : null;
  }
}

class HighlightData {
  String? matchId;
  List<HighlightItem>? highlights;

  HighlightData({this.matchId, this.highlights});

  HighlightData.fromJson(Map<String, dynamic> json) {
    matchId = json['matchId'];
    if (json['highlights'] != null) {
      highlights = <HighlightItem>[];
      json['highlights'].forEach((v) {
        highlights!.add(HighlightItem.fromJson(v));
      });
    }
  }
}

class HighlightItem {
  String? title;
  String? thumbnail;
  String? videoUrl;
  String? duration;

  HighlightItem({this.title, this.thumbnail, this.videoUrl, this.duration});

  HighlightItem.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    thumbnail = json['thumbnail'];
    videoUrl = json['videoUrl'];
    duration = json['duration'];
  }
}
