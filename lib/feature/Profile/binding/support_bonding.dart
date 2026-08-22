import 'package:chatter_bee/feature/Profile/controller/support_controller.dart';
import 'package:get/get.dart';

class SupportBonding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SupportController> (() => SupportController(),);
  }

}
