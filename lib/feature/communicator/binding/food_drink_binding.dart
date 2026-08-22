import 'package:chatter_bee/feature/communicator/controller/food_drink_controller.dart';
import 'package:get/get.dart';

class FoodDrinkBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FoodDrinkController> (() => FoodDrinkController(),);
  }
}
