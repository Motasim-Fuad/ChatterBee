import 'package:chatter_bee/feature/invitations/controller/caregiver_invitation_controller.dart';
import 'package:chatter_bee/feature/role_selection/controller/caregiver_profile_controller.dart';
import 'package:get/get.dart';

class CaregiverProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CaregiverProfileController>(() => CaregiverProfileController());
    Get.lazyPut<CaregiverInvitationController>(() => CaregiverInvitationController());
  }
}