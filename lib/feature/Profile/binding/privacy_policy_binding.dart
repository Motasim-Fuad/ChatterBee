import 'package:chatter_bee/feature/Profile/controller/privacy_policy_controller.dart';
import 'package:get/get.dart';

class PrivacyPolicyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PrivacyPolicyController> (() => PrivacyPolicyController(),);
  }

}
