import 'package:chatter_bee/feature/communicator/sub_category/fruits/fruits_controller.dart';
import 'package:get/get.dart';

class FruitsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FruitsController>(() => FruitsController());
  }
}
