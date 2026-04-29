class ChannelCategoryModel {
  bool? success;
  int? count;
  List<ChannelCategory>? categories;

  ChannelCategoryModel({this.success, this.count, this.categories});

  ChannelCategoryModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    count = json['count'];
    if (json['categories'] != null) {
      categories = <ChannelCategory>[];
      json['categories'].forEach((v) {
        categories!.add(ChannelCategory.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['count'] = count;
    if (categories != null) {
      data['categories'] = categories!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ChannelCategory {
  String? sId;
  String? name;
  String? slug;
  bool? isActive;
  String? createdAt;
  String? updatedAt;
  int? iV;

  ChannelCategory(
      {this.sId,
      this.name,
      this.slug,
      this.isActive,
      this.createdAt,
      this.updatedAt,
      this.iV});

  ChannelCategory.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    slug = json['slug'];
    isActive = json['isActive'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['slug'] = slug;
    data['isActive'] = isActive;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}
