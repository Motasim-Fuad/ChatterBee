import 'package:chatter_bee/feature/communicator/controller/health_controller.dart';
import 'package:get/get.dart';

class HealthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HealthController>(
          () => HealthController(),
    );
  }
}
