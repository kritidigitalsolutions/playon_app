import 'package:get/get.dart';
import 'package:play_on_app/view_model/after_controller/home_contollers/home_controller.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
