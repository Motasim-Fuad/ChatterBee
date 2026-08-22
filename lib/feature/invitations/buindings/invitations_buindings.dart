import 'package:chatter_bee/feature/invitations/controller/caregiver_invitation_controller.dart';
import 'package:chatter_bee/feature/invitations/controller/communicator_invitation_controller.dart';
import 'package:get/get.dart';

class CaregiverInvitationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CaregiverInvitationController>(() => CaregiverInvitationController());
  }
}

class CommunicatorInvitationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CommunicatorInvitationController>(() => CommunicatorInvitationController());
  }
}
