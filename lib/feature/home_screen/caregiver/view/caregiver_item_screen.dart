import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:chatter_bee/feature/home_screen/caregiver/controller/caregiver_item_controller.dart';
import 'package:chatter_bee/feature/home_screen/caregiver/view/caregiver_home_screen.dart'
    show CgFolderCard, CgFolderPainter;
import 'package:chatter_bee/models/caregiver_models/caregiver_content_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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


class CaregiverItemScreen extends StatelessWidget {
  const CaregiverItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CaregiverItemController>();

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
          controller.parentTitle,
          style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A)),
        ),
        actions: [
          Obx(() => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: controller.toggleEditMode,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: controller.isEditMode.value
                      ? const Color(0xFFFFC857)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFC857)),
                ),
                child: Text(
                  controller.isEditMode.value ? 'done'.tr : 'edit'.tr,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: controller.isEditMode.value
                          ? Colors.black
                          : const Color(0xFFFFC857)),
                ),
              ),
            ),
          )),
          Obx(() => !controller.isEditMode.value
              ? Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: controller.showAddSheet,
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
        if (controller.isLoading.value) {
          return const Center(
              child:
              CircularProgressIndicator(color: Color(0xFFFFC857)));
        }

        return Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: _CaregiverSpeakBar(
              text: controller.selectedWord.value,
              imageUrl: AppUrl.mediaUrl(controller.selectedImage.value),
              itemColor: _parseColor(controller.selectedColor.value,
                  const Color(0xFFFFD700)),
              onSpeak: controller.speakSelected,
              onClear: controller.clearSelectionBar,
            ),
          ),
          Expanded(child: OrientationBuilder(builder: (context, _) {
            final cols = _crossAxisCount(context);
            final extra = controller.isEditMode.value ? 0 : 1;
            return RefreshIndicator(
            onRefresh: controller.refresh,
            color: const Color(0xFFFFC857),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.82,
              ),
              itemCount: extra + controller.items.length,
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
                final item = controller.items[i - extra];
                return Obx(() {
                  final isSelected = controller.isEditMode.value
                      ? controller.selectedIds.contains(item.id)
                      : controller.selectedItemId.value == item.id;
                  return CgFolderCard(
                    imageUrl: AppUrl.mediaUrl(item.imageIcon),
                    label: item.word ?? '',
                    bgColor: _parseColor(
                        item.color, const Color(0xFFFFD700)),
                    isSelected: isSelected,
                    showEditBtn: controller.isEditMode.value,
                    onTap: () {
                      if (controller.isEditMode.value) {
                        controller.toggleSelection(item.id);
                      } else {
                        controller.onItemTap(item);
                      }
                    },
                    onEditTap: () => controller.showEditSheet(item),
                  );
                });
              },
            ),
            );
          })),
        ]);
      }),
    );
  }
}

class _CaregiverSpeakBar extends StatelessWidget {
  final String text;
  final String? imageUrl;
  final Color itemColor;
  final VoidCallback onSpeak;
  final VoidCallback onClear;

  const _CaregiverSpeakBar({
    required this.text,
    required this.imageUrl,
    required this.itemColor,
    required this.onSpeak,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasText = text.isNotEmpty;
    return Row(children: [
      Expanded(
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE3E3E9)),
          ),
          child: hasText
              ? Row(children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                        color: itemColor,
                        borderRadius: BorderRadius.circular(8)),
                    clipBehavior: Clip.antiAlias,
                    child: imageUrl != null && imageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imageUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => const Icon(
                                Icons.image_outlined,
                                color: Colors.white,
                                size: 20))
                        : const Icon(Icons.image_outlined,
                            color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(fontSize: 16)),
                  ),
                ])
              : Align(
                  alignment: Alignment.centerLeft,
                  child: Text('tap_an_item'.tr,
                      style: GoogleFonts.nunito(
                          fontSize: 16, color: Colors.grey[400]))),
        ),
      ),
      const SizedBox(width: 10),
      _CaregiverBarButton(
          color: const Color(0xFF7BC5D3),
          onTap: hasText ? onSpeak : null,
          child: SvgPicture.asset(ImagesLink.speakIcon,
              width: 22, height: 22)),
      const SizedBox(width: 10),
      _CaregiverBarButton(
          color: const Color(0xFFE57373),
          onTap: onClear,
          child: SvgPicture.asset(ImagesLink.cancelIcon,
              width: 22, height: 22)),
    ]);
  }
}

class _CaregiverBarButton extends StatelessWidget {
  final Color color;
  final VoidCallback? onTap;
  final Widget child;
  const _CaregiverBarButton(
      {required this.color, required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
              color: onTap == null ? color.withOpacity(.45) : color,
              borderRadius: BorderRadius.circular(12)),
          child: Center(child: child),
        ),
      );
}

// Show Item Dialog

void _showItemDialog(
    BuildContext context,
    CaregiverItemController controller,
    ItemModel item,
    ) {
  final bgColor = _parseColor(item.color, const Color(0xFFFFD700));
  final imageUrl = AppUrl.mediaUrl(item.imageIcon);
  final hasAudio = item.speak != null;

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, _, __) {
      final curved =
      CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
      return ScaleTransition(
        scale: Tween(begin: 0.65, end: 1.0).animate(curved),
        child: FadeTransition(
          opacity: anim,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: 220,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                        color: bgColor.withOpacity(0.4), width: 2),
                    boxShadow: [
                      BoxShadow(
                          color: bgColor.withOpacity(0.35),
                          blurRadius: 32,
                          spreadRadius: 4)
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: bgColor.withOpacity(0.2),
                        ),
                        child: imageUrl != null && imageUrl.isNotEmpty
                            ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Icon(
                                Icons.record_voice_over_outlined,
                                color: bgColor,
                                size: 48),
                          ),
                        )
                            : Icon(Icons.record_voice_over_outlined,
                            color: bgColor, size: 48),
                      ),
                      const SizedBox(height: 16),
                      Text(item.word ?? '',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1A1A))),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () async {
                          if (!hasAudio) {
                            Navigator.of(ctx).pop();
                            Get.snackbar('no_audio_title'.tr,
                                'item_has_no_audio'.tr,
                                snackPosition: SnackPosition.BOTTOM);
                            return;
                          }
                          await controller.playItemAudio(item);
                          Navigator.of(ctx).pop();
                        },
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: hasAudio
                                ? bgColor
                                : Colors.grey[300],
                            shape: BoxShape.circle,
                            boxShadow: hasAudio
                                ? [
                              BoxShadow(
                                  color:
                                  bgColor.withOpacity(0.5),
                                  blurRadius: 14,
                                  spreadRadius: 2)
                            ]
                                : [],
                          ),
                          child: Icon(
                            hasAudio
                                ? Icons.volume_up
                                : Icons.volume_off,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        hasAudio ? 'tap_to_speak'.tr : 'no_audio'.tr,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
