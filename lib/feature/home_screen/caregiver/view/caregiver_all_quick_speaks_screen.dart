import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/feature/home_screen/caregiver/controller/caregiver_home_controller.dart';
import 'package:chatter_bee/feature/home_screen/caregiver/view/caregiver_home_screen.dart'
    show CgFolderCard;
import 'package:chatter_bee/widgets/sentence_bar.dart';
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
          onPressed: () {
            controller.swapFromIndex.value = -1;
            Get.back();
          },
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
      body: OrientationBuilder(builder: (context, _) {
        final cols = _crossAxisCount(context);
        return Obx(() {
          final extra = controller.isQsEditMode.value ? 0 : 1;
          final qsList = controller.quickSpeaks.toList();
          final editing = controller.isQsEditMode.value;
          final swapIdx = controller.swapFromIndex.value;
          final selectedQsId = controller.selectedQuickSpeakId.value;

          return Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: SentenceBar(
                hint: 'select_quick_speak_hint'.tr,
                onSpeak: controller.speakSelectedQuickSpeak,
                onClear: controller.clearQuickSpeak,
              ),
            ),
            if (editing)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Text(
                  'swap_hint'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refresh,
                color: const Color(0xFFFFC857),
                child: GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: extra + qsList.length,
                  itemBuilder: (_, i) {
                    if (extra == 1 && i == 0) {
                      return CgFolderCard(
                        imageUrl: null,
                        label: 'tap_to_type'.tr,
                        bgColor: const Color(0xFFE8F6F8),
                        icon: Icons.keyboard_alt_outlined,
                        isSelected: false,
                        showEditBtn: false,
                        onTap: controller.promptTypedText,
                      );
                    }
                    // idx = quickSpeaks list-er asol index (swap er jonno)
                    final idx = i - extra;
                    final qs = qsList[idx];
                    return CgFolderCard(
                      imageUrl: AppUrl.mediaUrl(qs.imageIcon),
                      label: qs.word ?? '',
                      bgColor:
                      _parseColor(qs.color, const Color(0xFFFFD700)),
                      isSelected:
                      editing ? swapIdx == idx : selectedQsId == qs.id,
                      showEditBtn: editing,
                      onTap: () => controller.onQuickSpeakTap(idx, qs),
                      onEditTap: () =>
                          controller.showEditQuickSpeakSheet(qs),
                    );
                  },
                ),
              ),
            ),
          ]);
        });
      }),
    );
  }
}