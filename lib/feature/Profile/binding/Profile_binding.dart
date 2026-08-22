import 'package:chatter_bee/feature/Profile/controller/profile_controller.dart';
import 'package:get/get.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController> (() => ProfileController(),);
  }
}
