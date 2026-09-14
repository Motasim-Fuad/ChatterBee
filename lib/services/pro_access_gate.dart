import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:chatter_bee/feature/Profile/controller/pro_status_controller.dart';
import 'package:chatter_bee/routes/app_routes.dart';
import 'package:chatter_bee/services/revenueCat_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProAccessGate {
  static bool get isPro =>
      Get.isRegistered<ProStatusController>() &&
      ProStatusController.to.isProUser.value;

  static bool allowOrPrompt({String? featureName}) {
    if (isPro) return true;
    show(featureName: featureName ?? 'custom_image_upload'.tr);
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

  static void showUnlockProDialog() {
    const features = [
      'Real-Time Notifications',
      'Visual Routines',
      'Advanced Customization',
      'BuddyBee Encouragement',
      'Linked Caregiver Accounts',
    ];
    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Image.asset(ImagesLink.logo, height: 72, fit: BoxFit.contain),
            const SizedBox(height: 16),
            const Text('Unlock ChatterBee Pro',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            const Text(
              'Unlock powerful tools that help caregivers stay connected while creating a more personalized communication experience.',
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.45, color: Color(0xFF636F85)),
            ),
            const SizedBox(height: 18),
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(children: [
                    const Icon(Icons.check_circle_rounded,
                        size: 20, color: Color(0xFFF4B400)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(feature,
                            style: const TextStyle(fontWeight: FontWeight.w600))),
                  ]),
                )),
            const SizedBox(height: 20),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.toNamed(AppRoutes.SUBSCRIPTION);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC857),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Unlock ChatterBee Pro',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                )),
            TextButton(onPressed: Get.back, child: const Text('Maybe Later')),
            TextButton(
              onPressed: () async {
                final restored =
                    await RevenueCatService.instance.restorePurchases();
                if (restored && Get.isRegistered<ProStatusController>()) {
                  ProStatusController.to.isProUser.value = true;
                  Get.back();
                  Get.toNamed(AppRoutes.ACTIVITIES);
                } else {
                  Get.snackbar(
                      'Not found', 'No active subscription to restore.');
                }
              },
              child: const Text('Already subscribed? Restore Purchase'),
            ),
          ]),
        ),
      ),
    );
  }

  static void show({required String featureName}) {
    showUnlockProDialog();
  }
}
