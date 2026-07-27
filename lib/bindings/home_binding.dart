import 'package:get/get.dart';
import 'package:play_on_app/view_model/after_controller/ad_controller.dart';
import 'package:play_on_app/view_model/after_controller/home_contollers/home_controller.dart';
import 'package:play_on_app/view_model/after_controller/legal_controller.dart';
import 'package:play_on_app/view_model/after_controller/notification_controller.dart';
import 'package:play_on_app/view_model/after_controller/plan_controller.dart';
import 'package:play_on_app/view_model/after_controller/player_controller.dart';
import 'package:play_on_app/view_model/after_controller/series_controller.dart';
import 'package:play_on_app/view_model/before_controller/auth_controller.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<HomeController>(HomeController());
    Get.put<AdController>(AdController());
    Get.put<AuthController>(AuthController());
    Get.put<LegalController>(LegalController());
    Get.put<PlanController>(PlanController(), permanent: true);
    Get.put<NotificationController>(NotificationController());
    Get.put<PlayerController>(PlayerController());
    Get.put<SeriesController>(SeriesController());
  }
}
