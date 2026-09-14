import 'dart:io';

import 'package:chatter_bee/config/schedule_icon_library.dart';
import 'package:chatter_bee/services/pro_access_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

Future<String> copyAssetToTemp(String assetPath) async {
  final bytes = await rootBundle.load(assetPath);
  final dir = await getTemporaryDirectory();
  final name = assetPath.split('/').last;
  final file = File('${dir.path}/schedule_$name');
  await file.writeAsBytes(bytes.buffer.asUint8List());
  return file.path;
}

Future<void> showScheduleImagePicker({
  required Future<void> Function(String asset) onLibraryAsset,
  required Future<void> Function() onGallery,
}) async {
  await Get.bottomSheet(
    Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('icon_library'.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: GridView.builder(
              itemCount: ScheduleIconLibrary.assets.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (_, i) {
                final asset = ScheduleIconLibrary.assets[i];
                return GestureDetector(
                  onTap: () async {
                    Get.back();
                    await onLibraryAsset(asset);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(asset, fit: BoxFit.cover),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                if (!ProAccessGate.allowOrPrompt(
                    featureName: 'custom_image_upload'.tr)) {
                  return;
                }
                Get.back();
                onGallery();
              },
              icon: const Icon(Icons.photo_library_outlined),
              label: Text('upload_custom_image'.tr),
            ),
          ),
        ],
      ),
    ),
    isScrollControlled: true,
  );
}
