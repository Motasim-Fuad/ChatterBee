import 'dart:async';

import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:chatter_bee/services/storage/data_storage.dart';
import 'package:chatter_bee/services/tts_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BuddyBeeEncouragement {
  static bool get _enabled => StorageService().buddyMode();

  static Future<void> maybeShow() async {
    if (!_enabled) return;
    if (Get.isDialogOpen ?? false) return;

    unawaited(_speakGoodJob());

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: const Padding(
          padding: EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _BeeThumbsUp(),
              SizedBox(height: 16),
              Text(
                'Good job!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );

    await Future.delayed(const Duration(seconds: 2));
    if (Get.isDialogOpen ?? false) Get.back();
  }

  static Future<void> _speakGoodJob() async {
    await Future.delayed(const Duration(milliseconds: 250));
    await TtsService.to.speakWhenIdle('Good job!', lang: 'en');
  }
}

class _BeeThumbsUp extends StatelessWidget {
  const _BeeThumbsUp();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      width: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(ImagesLink.logo, height: 96, fit: BoxFit.contain),
          const Positioned(
            right: 0,
            bottom: 4,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Color(0xFFFFC857),
              child: Icon(Icons.thumb_up_alt_rounded,
                  color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
