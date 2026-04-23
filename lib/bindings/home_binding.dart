import 'package:get/get.dart';
import 'package:play_on_app/view_model/after_controller/home_contollers/home_controller.dart';
import 'package:play_on_app/view_model/after_controller/legal_controller.dart';
import 'package:play_on_app/view_model/after_controller/notification_controller.dart';
import 'package:play_on_app/view_model/after_controller/plan_controller.dart';
import 'package:play_on_app/view_model/before_controller/auth_controller.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<LegalController>(() => LegalController());
    Get.lazyPut<PlanController>(() => PlanController());
    Get.lazyPut<NotificationController>(() => NotificationController());
  }
}
