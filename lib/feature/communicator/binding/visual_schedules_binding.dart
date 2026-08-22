import 'package:chatter_bee/feature/communicator/controller/visual_schedules_controller.dart';
import 'package:get/get.dart';

class VisualSchedulesBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<VisualSchedulesController>(
      VisualSchedulesController(),
      permanent: false,
    );
  }
}
