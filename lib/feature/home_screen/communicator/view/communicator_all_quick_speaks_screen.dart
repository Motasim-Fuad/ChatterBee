import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/feature/home_screen/communicator/contoller/communicator_home_controller.dart';
import 'package:chatter_bee/widgets/sentence_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'communicator_home_screen.dart';

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


class CommunicatorAllQuickSpeaksScreen
    extends GetView<CommunicatorHomeController> {
  const CommunicatorAllQuickSpeaksScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        title: Text(
          'quick_speak'.tr,
          style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A)),
        ),
      ),
      body: Column(
        children: [
          Obx(() => Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: SentenceBar(
              hint: 'select_quick_speak_hint'.tr,
              onSpeak: controller.speakQuickSpeak,
              onClear: controller.clearQuickSpeak,
              isCooldown: controller.isSpeakCooldown.value,
              cooldownCount: controller.cooldownCount.value,
            ),
          )),

          const SizedBox(height: 14),

          Expanded(
            child: OrientationBuilder(builder: (context, _) {
              final cols = _crossAxisCount(context);
              return Obx(() {
                final qsList = controller.quickSpeaks.toList();
                return RefreshIndicator(
                  onRefresh: controller.refresh,
                  color: const Color(0xFFFFC857),
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: qsList.length + 1,
                    itemBuilder: (_, i) {
                      if (i == 0) {
                        return CommCard(
                          imageUrl: null,
                          label: 'tap_to_type'.tr,
                          bgColor: const Color(0xFFE8F6F8),
                          icon: Icons.keyboard_alt_outlined,
                          isSelected: false,
                          onTap: controller.promptTypedText,
                        );
                      }
                      final qs = qsList[i - 1];
                      return Obx(() => CommCard(
                        imageUrl: AppUrl.mediaUrl(qs.imageIcon),
                        label: qs.word ?? '',
                        bgColor: _parseColor(
                            qs.color, const Color(0xFFFFD700)),
                        isSelected:
                        controller.selectedQsId.value == qs.id,
                        onTap: () => controller.onQuickSpeakTap(qs),
                      ));
                    },
                  ),
                );
              });
            }),
          ),
        ],
      ),
    );
  }
}
