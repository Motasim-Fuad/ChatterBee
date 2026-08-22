import 'package:chatter_bee/feature/home_screen/communicator/contoller/communicator_sub_category_controller.dart';

import 'package:get/get.dart';

class CommunicatorSubCategoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CommunicatorSubCategoryController>(
          () => CommunicatorSubCategoryController(),
    );
  }
}
