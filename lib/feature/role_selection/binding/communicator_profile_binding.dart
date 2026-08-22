import 'package:chatter_bee/feature/role_selection/controller/communicator_profile_controller.dart';
import 'package:get/get.dart';

class CommunicatorProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CommunicatorProfileController> (() => CommunicatorProfileController(),
    );
  }
}
