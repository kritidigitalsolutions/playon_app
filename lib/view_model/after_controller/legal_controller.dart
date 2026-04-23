import 'package:get/get.dart';
import 'package:play_on_app/model/response_model/legal_response_model.dart';
import 'package:play_on_app/repo/legal_repository.dart';

import '../../data/api_responce_data.dart';

class LegalController extends GetxController {
  final _api = LegalRepository();

  final privacyPolicy = ApiResponse<LegalResponseModel>.loading().obs;
  final aboutUs = ApiResponse<LegalResponseModel>.loading().obs;
  final refundPolicy = ApiResponse<LegalResponseModel>.loading().obs;
  final termsConditions = ApiResponse<LegalResponseModel>.loading().obs;

  void fetchPrivacyPolicy() {
    privacyPolicy.value = ApiResponse.loading();
    _api.getPrivacyPolicy().then((value) {
      privacyPolicy.value = ApiResponse.completed(LegalResponseModel.fromJson(value));
    }).onError((error, stackTrace) {
      privacyPolicy.value = ApiResponse.error(error.toString());
    });
  }

  void fetchAboutUs() {
    aboutUs.value = ApiResponse.loading();
    _api.getAboutUs().then((value) {
      aboutUs.value = ApiResponse.completed(LegalResponseModel.fromJson(value));
    }).onError((error, stackTrace) {
      aboutUs.value = ApiResponse.error(error.toString());
    });
  }

  void fetchRefundPolicy() {
    refundPolicy.value = ApiResponse.loading();
    _api.getRefundPolicy().then((value) {
      refundPolicy.value = ApiResponse.completed(LegalResponseModel.fromJson(value));
    }).onError((error, stackTrace) {
      refundPolicy.value = ApiResponse.error(error.toString());
    });
  }

  void fetchTermsConditions() {
    termsConditions.value = ApiResponse.loading();
    _api.getTermsConditions().then((value) {
      termsConditions.value = ApiResponse.completed(LegalResponseModel.fromJson(value));
    }).onError((error, stackTrace) {
      termsConditions.value = ApiResponse.error(error.toString());
    });
  }
}
