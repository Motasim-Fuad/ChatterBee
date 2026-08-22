import 'package:chatter_bee/feature/communicator/sub_category/snacks/snacks_controller.dart';
import 'package:get/get.dart';

class SnacksBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SnacksController>(() => SnacksController());
  }
}
