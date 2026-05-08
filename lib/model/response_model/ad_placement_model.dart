class AdPlacementModel {
  bool? success;
  List<AdPlacement>? placements;

  AdPlacementModel({this.success, this.placements});

  AdPlacementModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['placements'] != null) {
      placements = <AdPlacement>[];
      json['placements'].forEach((v) {
        placements!.add(AdPlacement.fromJson(v));
      });
    }
  }
}

class AdPlacement {
  String? sId;
  String? title;
  String? position;
  String? adUnitId;
  String? format;
  int? sortOrder;
  bool? isActive;
  String? notes;

  AdPlacement({
    this.sId,
    this.title,
    this.position,
    this.adUnitId,
    this.format,
    this.sortOrder,
    this.isActive,
    this.notes,
  });

  AdPlacement.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    position = json['position'];
    adUnitId = json['adUnitId'];
    format = json['format'];
    sortOrder = json['sortOrder'];
    isActive = json['isActive'];
    notes = json['notes'];
  }
}
