import 'package:chatter_bee/feature/Profile/controller/pro_status_controller.dart';
import 'package:chatter_bee/feature/Profile/view/pro_feature_popup.dart';
import 'package:chatter_bee/routes/app_routes.dart';
import 'package:chatter_bee/widgets/paper_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProAccessGate {
  static bool _showing = false;

  static bool get isPro =>
      Get.isRegistered<ProStatusController>() &&
      ProStatusController.to.isProUser.value;

  static bool allowOrPrompt({String? featureName}) {
    if (isPro) return true;
    showUnlockProDialog();
    return false;
  }

  static bool openScheduleOrPrompt() {
    if (isPro) {
      Get.toNamed(AppRoutes.ACTIVITIES);
      return true;
    }
    showUnlockProDialog();
    return false;
  }

  static Future<void> showUnlockProDialog() async {
    if (_showing) return;
    _showing = true;
    try {
      await showPaperDialog(
        child: const ProFeaturePopup(),
        barrierColor: Colors.black54,
      );
    } finally {
      _showing = false;
    }
  }

  static void show({required String featureName}) {
    showUnlockProDialog();
  }
}
