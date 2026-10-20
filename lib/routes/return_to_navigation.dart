import 'package:chatter_bee/feature/home_screen/caregiver/controller/caregiver_home_controller.dart';
import 'package:chatter_bee/feature/home_screen/communicator/contoller/communicator_home_controller.dart';
import 'package:chatter_bee/feature/navigation_bar/navigation_bar.dart';
import 'package:chatter_bee/routes/app_routes.dart';
import 'package:chatter_bee/services/storage/data_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// Returns to the existing home shell.
///
/// Do not [Get.offAllNamed] `/navigation` while that route is already in the
/// stack. GetX indexes controllers by route name, so removing the old
/// `/navigation` also deletes the controller the new screen is using. The
/// search [TextField] then mounts with a disposed controller.
void returnToNavigation() {
  if (Get.currentRoute != AppRoutes.NAVIGATIONBAR) {
    var found = false;
    Get.until((route) {
      if (route.settings.name == AppRoutes.NAVIGATIONBAR) {
        found = true;
        return true;
      }
      return route.isFirst;
    });
    if (!found) {
      Get.offAllNamed(AppRoutes.NAVIGATIONBAR);
      return;
    }
  }
  _syncShellWithStoredRole();
}

void _syncShellWithStoredRole() {
  final communicator =
      StorageService().getUserRole()?.trim().toLowerCase() == 'communicator';

  if (Get.isRegistered<NavigationController>()) {
    Get.find<NavigationController>().syncRole();
  }

  if (communicator) {
    if (!Get.isRegistered<CommunicatorHomeController>()) {
      Get.put(CommunicatorHomeController());
    } else {
      Get.find<CommunicatorHomeController>().refresh();
    }
  } else if (!Get.isRegistered<CaregiverHomeController>()) {
    Get.put(CaregiverHomeController());
  } else {
    Get.find<CaregiverHomeController>().reloadAfterProfileChange();
  }

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (communicator) {
      if (Get.isRegistered<CaregiverHomeController>()) {
        Get.delete<CaregiverHomeController>(force: true);
      }
    } else if (Get.isRegistered<CommunicatorHomeController>()) {
      Get.delete<CommunicatorHomeController>(force: true);
    }
  });
}
