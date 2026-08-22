import 'package:chatter_bee/feature/home_screen/caregiver/controller/caregiver_home_controller.dart';
import 'package:chatter_bee/feature/home_screen/communicator/contoller/communicator_home_controller.dart';
import 'package:chatter_bee/feature/navigation_bar/navigation_bar.dart';
import 'package:chatter_bee/services/storage/data_storage.dart';
import 'package:get/get.dart';

class NavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavigationController>(() => NavigationController());
    final role = StorageService().getUserRole()?.trim().toLowerCase();
    if (role == 'communicator') {
      Get.lazyPut<CommunicatorHomeController>(
        () => CommunicatorHomeController(),
      );
    } else {
      Get.lazyPut<CaregiverHomeController>(() => CaregiverHomeController());
    }
  }
}
