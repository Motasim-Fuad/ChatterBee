import 'package:chatter_bee/feature/communicator/controller/things_controller.dart';
import 'package:get/get.dart';

class ThingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ThingsController>(
          () => ThingsController(),
    );
  }
}
