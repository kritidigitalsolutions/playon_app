class PlanModel {
  bool? success;
  int? count;
  List<Plan>? plans;

  PlanModel({this.success, this.count, this.plans});

  PlanModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    count = json['count'];
    if (json['plans'] != null) {
      plans = <Plan>[];
      json['plans'].forEach((v) {
        plans!.add(Plan.fromJson(v));
      });
    }
  }
}

class Plan {
  String? id;
  String? title;
  String? slug;
  int? price;
  String? currency;
  String? billingType;
  int? durationDays;
  List<String>? features;
  String? buttonText;
  String? description;
  String? badge;
  bool? isActive;
  int? sortOrder;

  Plan({
    this.id,
    this.title,
    this.slug,
    this.price,
    this.currency,
    this.billingType,
    this.durationDays,
    this.features,
    this.buttonText,
    this.description,
    this.badge,
    this.isActive,
    this.sortOrder,
  });

  Plan.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    title = json['title'];
    slug = json['slug'];
    price = json['price'];
    currency = json['currency'];
    billingType = json['billingType'];
    durationDays = json['durationDays'];
    features = json['features']?.cast<String>();
    buttonText = json['buttonText'];
    description = json['description'];
    badge = json['badge'];
    isActive = json['isActive'];
    sortOrder = json['sortOrder'];
  }
}
