import 'package:chatter_bee/feature/authentication/controller/forgot_verification_controller.dart';
import 'package:get/get.dart';

class ForgotVerificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ForgotVerificationController>(() => ForgotVerificationController());
  }
}
