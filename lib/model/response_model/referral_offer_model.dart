class ReferralOfferModel {
  bool? success;
  int? count;
  List<ReferralOffer>? offers;

  ReferralOfferModel({this.success, this.count, this.offers});

  ReferralOfferModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    count = json['count'];
    if (json['offers'] != null) {
      offers = <ReferralOffer>[];
      json['offers'].forEach((v) {
        offers!.add(ReferralOffer.fromJson(v));
      });
    }
  }
}

class ReferralOffer {
  String? sId;
  String? title;
  String? discountType;
  int? discountValue;
  int? maxDiscount;
  String? validTill;

  ReferralOffer({
    this.sId,
    this.title,
    this.discountType,
    this.discountValue,
    this.maxDiscount,
    this.validTill,
  });

  ReferralOffer.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    discountType = json['discountType'];
    discountValue = json['discountValue'];
    maxDiscount = json['maxDiscount'];
    validTill = json['validTill'];
  }
}
