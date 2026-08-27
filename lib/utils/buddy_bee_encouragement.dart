import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:chatter_bee/feature/home_screen/communicator/contoller/communicator_home_controller.dart';
import 'package:chatter_bee/services/tts_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BuddyBeeEncouragement {
  static Future<void> maybeShow() async {
    var enabled = false;
    if (Get.isRegistered<CommunicatorHomeController>()) {
      enabled = Get.find<CommunicatorHomeController>().isBuddyMode.value;
    }
    if (!enabled) return;

    TtsService.to.speak('Good job!', lang: 'en');

    if (Get.isDialogOpen ?? false) return;

    await Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(ImagesLink.success, height: 96),
              const SizedBox(height: 16),
              Text(
                'good_job'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'buddy_bee_encouragement_msg'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF636F85), height: 1.4),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: Get.back,
                child: Text('done'.tr),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}
