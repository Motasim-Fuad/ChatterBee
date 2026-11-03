import 'package:chatter_bee/feature/home_screen/caregiver/controller/caregiver_home_controller.dart';
import 'package:chatter_bee/feature/home_screen/communicator/contoller/communicator_home_controller.dart';
import 'package:chatter_bee/feature/Notification/notification_controller.dart';
import 'package:chatter_bee/feature/Profile/controller/profile_controller.dart';
import 'package:chatter_bee/services/pro_access_gate.dart';
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

  // The profile (name, avatar, role, switch list) belongs to the old account.
  if (Get.isRegistered<ProfileController>()) {
    Get.find<ProfileController>().loadUserProfile();
  } else {
    Get.put(ProfileController(), permanent: true);
  }

  // Notifications of the previous account must not stay on screen.
  if (Get.isRegistered<NotificationControllerdamo>()) {
    final n = Get.find<NotificationControllerdamo>();
    n.notifications.clear();
    if (ProAccessGate.isPro) {
      n.loadNotifications();
      n.loadSettings();
    }
  }

  // permanent: true => not linked to the /Profile route that is being popped,
  // so GetX will not delete the controller when that route is disposed.
  if (communicator) {
    if (!Get.isRegistered<CommunicatorHomeController>()) {
      Get.put(CommunicatorHomeController(), permanent: true);
    } else {
      Get.find<CommunicatorHomeController>().loadContent();
    }
  } else if (!Get.isRegistered<CaregiverHomeController>()) {
    Get.put(CaregiverHomeController(), permanent: true);
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

/// Call on logout / session expiry so permanent controllers never leak one
/// account's data into the next login.
void resetSessionControllers() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (Get.isRegistered<ProfileController>()) {
      Get.delete<ProfileController>(force: true);
    }
    if (Get.isRegistered<CommunicatorHomeController>()) {
      Get.delete<CommunicatorHomeController>(force: true);
    }
    if (Get.isRegistered<CaregiverHomeController>()) {
      Get.delete<CaregiverHomeController>(force: true);
    }
  });
  WidgetsBinding.instance.scheduleFrame();
}
