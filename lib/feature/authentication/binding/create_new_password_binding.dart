import 'package:chatter_bee/feature/authentication/controller/create_new_password_controller.dart';
import 'package:get/get.dart';

class CreateNewPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateNewPasswordController>(() => CreateNewPasswordController());
  }

}
