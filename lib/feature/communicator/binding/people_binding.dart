import 'package:chatter_bee/feature/communicator/controller/people_controller.dart';
import 'package:get/get.dart';

class PeopleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PeopleController>(
          () => PeopleController(),
    );
  }
}
