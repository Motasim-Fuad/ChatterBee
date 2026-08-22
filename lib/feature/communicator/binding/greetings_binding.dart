import 'package:chatter_bee/feature/communicator/controller/greetings_controller.dart';
import 'package:get/get.dart';

class GreetingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GreetingsController>(
          () => GreetingsController(),
    );
  }
}
