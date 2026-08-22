import 'package:get/get.dart';

import '../controller/activities_controller.dart';

class ActivitiesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ActivitiesController>(
          () => ActivitiesController(),
    );
  }
}
