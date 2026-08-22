import 'package:chatter_bee/feature/Activity/controller/edit_activity_controller.dart';
import 'package:get/get.dart';


class EditActivityBuinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditActivityController>(
          () => EditActivityController(),
    );
  }
}
