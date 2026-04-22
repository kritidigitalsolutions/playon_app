class LegalResponseModel {
  bool? success;
  LegalPage? page;

  LegalResponseModel({this.success, this.page});

  LegalResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    page = json['page'] != null ? LegalPage.fromJson(json['page']) : null;
  }
}

class LegalPage {
  String? id;
  String? type;
  String? content;
  String? title;
  bool? isActive;

  LegalPage({this.id, this.type, this.content, this.title, this.isActive});

  LegalPage.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    type = json['type'];
    content = json['content'];
    title = json['title'];
    isActive = json['isActive'];
  }
}
