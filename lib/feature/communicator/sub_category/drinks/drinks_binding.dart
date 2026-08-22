import 'package:chatter_bee/feature/communicator/sub_category/drinks/drinks_controller.dart';
import 'package:get/get.dart';

class DrinksBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DrinksController>(() => DrinksController());
  }
}
