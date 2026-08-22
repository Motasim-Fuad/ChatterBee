import 'package:chatter_bee/feature/communicator/controller/emotions_controller.dart';
import 'package:get/get.dart';

class EmotionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmotionsController>(
          () => EmotionsController(),
    );
  }
}
