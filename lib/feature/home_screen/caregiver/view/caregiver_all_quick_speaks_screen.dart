import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/feature/home_screen/caregiver/controller/caregiver_home_controller.dart';
import 'package:chatter_bee/feature/home_screen/caregiver/view/caregiver_home_screen.dart'
    show CgFolderCard, CgQuickSpeakBar;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

Color _parseColor(String hex, Color fallback) {
  try {
    return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
  } catch (_) {
    return fallback;
  }
}

int _crossAxisCount(BuildContext context) {
  final w = MediaQuery.of(context).size.width;
  if (w >= 900) return 6;
  if (w >= 600) return 4;
  return 3;
}


class CaregiverAllQuickSpeaksScreen extends StatelessWidget {
  const CaregiverAllQuickSpeaksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CaregiverHomeController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: Color(0xFF1A1A1A)),
          onPressed: () => Get.back(),
        ),
        title: Text('quick_speak'.tr,
            style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A1A))),
        actions: [
          Obx(() => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: controller.toggleQsEditMode,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: controller.isQsEditMode.value
                      ? const Color(0xFFFFC857)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFC857)),
                ),
                child: Text(
                  controller.isQsEditMode.value ? 'done'.tr : 'edit'.tr,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: controller.isQsEditMode.value
                          ? Colors.black
                          : const Color(0xFFFFC857)),
                ),
              ),
            ),
          )),
          Obx(() => !controller.isQsEditMode.value
              ? Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: controller.showAddQuickSpeakSheet,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: const Color(0xFFFFC857),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.add,
                    color: Colors.black, size: 20),
              ),
            ),
          )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (controller.quickSpeaks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.record_voice_over_outlined,
                    size: 60, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Text('no_quick_speaks_hint'.tr,
                    style:
                    TextStyle(color: Colors.grey[500], fontSize: 15)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: controller.showAddQuickSpeakSheet,
                  icon: const Icon(Icons.add, color: Colors.black),
                  label: Text('add'.tr,
                      style: const TextStyle(color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC857),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          );
        }

        return OrientationBuilder(builder: (context, _) {
          final cols = _crossAxisCount(context);
          return Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: CgQuickSpeakBar(
                text: controller.selectedQuickSpeakText.value,
                imageUrl: controller.selectedQuickSpeakImage.value,
                color: _parseColor(controller.selectedQuickSpeakColor.value,
                    const Color(0xFFFFD700)),
                onSpeak: controller.speakSelectedQuickSpeak,
                onClear: controller.clearQuickSpeak,
              ),
            ),
            Expanded(child: RefreshIndicator(
              onRefresh: controller.refresh,
              color: const Color(0xFFFFC857),
              child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.82,
              ),
              itemCount: controller.quickSpeaks.length,
              itemBuilder: (_, i) {
                final qs = controller.quickSpeaks[i];
                return Obx(() => CgFolderCard(
                  imageUrl: AppUrl.mediaUrl(qs.imageIcon),
                  label: qs.word ?? '',
                  bgColor:
                  _parseColor(qs.color, const Color(0xFFFFD700)),
                  isSelected: false,
                  showEditBtn: controller.isQsEditMode.value,
                  onTap: () {
                    if (!controller.isQsEditMode.value) {
                      controller.selectQuickSpeak(qs);
                    }
                  },
                  onEditTap: () =>
                      controller.showEditQuickSpeakSheet(qs),
                ));
              },
              ),
            )),
          ]);
        });
      }),
    );
  }
}
