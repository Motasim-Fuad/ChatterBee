import 'package:chatter_bee/feature/home_screen/caregiver/controller/caregiver_item_controller.dart';
import 'package:chatter_bee/feature/home_screen/caregiver/controller/caregiver_sub_catagory_controller.dart';
import 'package:get/get.dart';

class CaregiverSubCatagoryBuinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CaregiverSubCategoryController>(() => CaregiverSubCategoryController());
  }
}
