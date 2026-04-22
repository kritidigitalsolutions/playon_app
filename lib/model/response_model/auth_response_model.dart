class OtpResponseModel {
  bool? success;
  String? message;
  bool? isNewUser;
  String? otp;

  OtpResponseModel({this.success, this.message, this.isNewUser, this.otp});

  OtpResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    isNewUser = json['isNewUser'];
    otp = json['otp'];
  }
}

class VerifyOtpResponseModel {
  bool? success;
  String? message;
  String? token;
  bool? isNewUser;
  UserData? user;

  VerifyOtpResponseModel(
      {this.success, this.message, this.token, this.isNewUser, this.user});

  VerifyOtpResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    token = json['token'];
    isNewUser = json['isNewUser'];
    user = json['user'] != null ? UserData.fromJson(json['user']) : null;
  }
}

class UserData {
  String? id;
  String? fullName;
  List<String>? favoriteSports;
  String? mobile;
  String? email;
  String? profilePic;

  UserData(
      {this.id,
      this.fullName,
      this.favoriteSports,
      this.mobile,
      this.email,
      this.profilePic});

  UserData.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? json['_id'];
    fullName = json['fullName'];
    favoriteSports = json['favoriteSports']?.cast<String>();
    mobile = json['mobile'];
    email = json['email'];
    profilePic = json['profilePic'];
  }
}
