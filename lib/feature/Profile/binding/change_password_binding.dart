import 'package:chatter_bee/feature/Profile/controller/change_password_controller.dart';
import 'package:get/get.dart';

class ChangePasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChangePasswordController> (() => ChangePasswordController(),);
  }

}
