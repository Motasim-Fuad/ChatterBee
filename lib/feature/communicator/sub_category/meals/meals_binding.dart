import 'package:chatter_bee/feature/communicator/sub_category/meals/meals_controller.dart';
import 'package:get/get.dart';

class MealsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MealsController>(() => MealsController());
  }
}
