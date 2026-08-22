import 'package:chatter_bee/feature/communicator/sub_category/breakfast/breakfast_controller.dart';
import 'package:get/get.dart';

class BreakfastBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BreakfastController>(
          () => BreakfastController(),
    );
  }
}
