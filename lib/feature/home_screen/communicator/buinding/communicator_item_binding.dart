import 'package:chatter_bee/feature/home_screen/communicator/contoller/communicator_item_controller.dart';
import 'package:get/get.dart';

class CommunicatorItemBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CommunicatorItemController>(
          () => CommunicatorItemController(),
    );
  }
}
