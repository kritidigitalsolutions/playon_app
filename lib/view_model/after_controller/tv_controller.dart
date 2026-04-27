import 'package:get/get.dart';
import 'package:play_on_app/repo/tv_repository.dart';
import 'package:play_on_app/utils/custom_snakebar.dart';

class TvController extends GetxController {
  final TvRepository _repository = TvRepository();

  var isLoading = false.obs;
  var tvCode = "".obs;
  var expiresIn = 0.obs;

  @override
  void onInit() {
    super.onInit();
    generateTvCode();
  }

  Future<void> generateTvCode() async {
    isLoading.value = true;
    try {
      final response = await _repository.generateTvCode();
      if (response['success'] == true) {
        tvCode.value = response['code']?.toString() ?? "";
        expiresIn.value = response['expiresIn'] ?? 0;
      } else {
        showCustomSnackbar(
          title: "Error",
          message: response['message'] ?? "Failed to generate code",
          type: SnackType.error,
        );
      }
    } catch (e) {
      showCustomSnackbar(
        title: "Error",
        message: e.toString(),
        type: SnackType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
