class ChannelModel {
  bool? success;
  int? count;
  List<Channel>? channels;

  ChannelModel({this.success, this.count, this.channels});

  ChannelModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    count = json['count'];
    if (json['channels'] != null) {
      channels = <Channel>[];
      json['channels'].forEach((v) {
        channels!.add(Channel.fromJson(v));
      });
    }
  }
}

class Channel {
  String? sId;
  String? name;
  String? slug;
  String? category;
  String? description;
  String? streamUrl;
  String? backupUrl;
  String? rtmpUrl;
  String? srtUrl;
  String? streamType;
  String? quality;
  String? thumbnail;
  String? logo;
  String? status;
  int? viewerCount;
  bool? featured;
  String? createdAt;
  String? updatedAt;

  Channel(
      {this.sId,
      this.name,
      this.slug,
      this.category,
      this.description,
      this.streamUrl,
      this.backupUrl,
      this.rtmpUrl,
      this.srtUrl,
      this.streamType,
      this.quality,
      this.thumbnail,
      this.logo,
      this.status,
      this.viewerCount,
      this.featured,
      this.createdAt,
      this.updatedAt});

  Channel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    slug = json['slug'];
    category = json['category'];
    description = json['description'];
    streamUrl = json['streamUrl'];
    backupUrl = json['backupUrl'];
    rtmpUrl = json['rtmpUrl'];
    srtUrl = json['srtUrl'];
    streamType = json['streamType'];
    quality = json['quality'];
    thumbnail = json['thumbnail'];
    logo = json['logo'];
    status = json['status'];
    viewerCount = json['viewerCount'];
    featured = json['featured'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }
}
