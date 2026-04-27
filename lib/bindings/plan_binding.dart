import 'package:get/get.dart';
import 'package:play_on_app/view_model/after_controller/plan_controller.dart';
import 'package:play_on_app/view_model/before_controller/auth_controller.dart';

class PlanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<PlanController>(() => PlanController());
  }
}
