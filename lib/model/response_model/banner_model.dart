class BannerModel {
  bool? success;
  List<Banners>? banners;

  BannerModel({this.success, this.banners});

  BannerModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['banners'] != null) {
      banners = <Banners>[];
      json['banners'].forEach((v) {
        banners!.add(Banners.fromJson(v));
      });
    }
  }

  Map<String, dynamic> json() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (banners != null) {
      data['banners'] = banners!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Banners {
  String? sId;
  String? title;
  String? image;
  String? link;
  String? position;
  bool? isActive;
  int? sortOrder;
  int? clicks;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Banners(
      {this.sId,
      this.title,
      this.image,
      this.link,
      this.position,
      this.isActive,
      this.sortOrder,
      this.clicks,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Banners.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    image = json['image'];
    link = json['link'];
    position = json['position'];
    isActive = json['isActive'];
    sortOrder = json['sortOrder'];
    clicks = json['clicks'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['title'] = title;
    data['image'] = image;
    data['link'] = link;
    data['position'] = position;
    data['isActive'] = isActive;
    data['sortOrder'] = sortOrder;
    data['clicks'] = clicks;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}
