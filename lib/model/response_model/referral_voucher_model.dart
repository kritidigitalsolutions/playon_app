class ReferralVoucherModel {
  bool? success;
  int? count;
  List<Voucher>? vouchers;

  ReferralVoucherModel({this.success, this.count, this.vouchers});

  ReferralVoucherModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    count = json['count'];
    if (json['vouchers'] != null) {
      vouchers = <Voucher>[];
      json['vouchers'].forEach((v) {
        vouchers!.add(Voucher.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['count'] = count;
    if (vouchers != null) {
      data['vouchers'] = vouchers!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Voucher {
  String? sId;
  String? code;
  String? title;
  String? discountType;
  int? discountValue;
  int? maxDiscount;
  int? usageLimit;
  int? usedCount;
  String? validFrom;
  String? validTill;

  Voucher(
      {this.sId,
      this.code,
      this.title,
      this.discountType,
      this.discountValue,
      this.maxDiscount,
      this.usageLimit,
      this.usedCount,
      this.validFrom,
      this.validTill});

  Voucher.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    code = json['code'];
    title = json['title'];
    discountType = json['discountType'];
    discountValue = json['discountValue'];
    maxDiscount = json['maxDiscount'];
    usageLimit = json['usageLimit'];
    usedCount = json['usedCount'];
    validFrom = json['validFrom'];
    validTill = json['validTill'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['code'] = code;
    data['title'] = title;
    data['discountType'] = discountType;
    data['discountValue'] = discountValue;
    data['maxDiscount'] = maxDiscount;
    data['usageLimit'] = usageLimit;
    data['usedCount'] = usedCount;
    data['validFrom'] = validFrom;
    data['validTill'] = validTill;
    return data;
  }
}
