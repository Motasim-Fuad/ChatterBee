import 'package:chatter_bee/feature/communicator/controller/action_controller.dart';
import 'package:get/get.dart';

class ActionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ActionController>(
          () => ActionController(),
    );
  }
}
