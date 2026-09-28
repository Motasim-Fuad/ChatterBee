import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:chatter_bee/feature/home_screen/communicator/contoller/communicator_item_controller.dart';
import 'package:chatter_bee/feature/home_screen/communicator/view/communicator_home_screen.dart';
import 'package:chatter_bee/models/communicator_models/communicator_content_model.dart';
import 'package:chatter_bee/widgets/sentence_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chatter_bee/widgets/app_shimmer.dart';


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


class CommunicatorItemScreen extends GetView<CommunicatorItemController> {
  const CommunicatorItemScreen({super.key});

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
          controller.parentTitle,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
          ),
        ),
      ),
      body: Column(
        children: [
          Obx(() {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: SentenceBar(
                hint: 'tap_an_item'.tr,
                onSpeak: controller.speakSelected,
                onClear: controller.clearSelection,
                isCooldown: controller.isSpeakCooldown.value,
                cooldownCount: controller.cooldownCount.value,
              ),
            );
          }),

          const SizedBox(height: 14),

          Expanded(
            child: OrientationBuilder(
              builder: (context, _) {
                final cols = _crossAxisCount(context);
                return Obx(() {
                  final items = controller.items.toList();
                  if (controller.isLoading.value && items.isEmpty) {
                    return const AppShimmerGrid();
                  }
                  return RefreshIndicator(
                    onRefresh: controller.refresh,
                    color: const Color(0xFFFFC857),
                    child: GridView.builder(
                      padding:
                      const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.82,
                      ),
                      itemCount: items.length + 1,
                      itemBuilder: (_, i) {
                        if (i == 0) {
                          return AACButtonCard(
                            imageUrl: null,
                            label: 'tap_to_type'.tr,
                            bgColor: const Color(0xFFE8F6F8),
                            icon: Icons.keyboard_alt_outlined,
                            isSelected: false,
                            onTap: controller.promptTypedText,
                          );
                        }
                        final item = items[i - 1];
                        return Obx(() => _ItemCard(
                          item: item,
                          isSelected:
                          controller.selectedItemId.value ==
                              item.id,
                          onTap: () =>
                              controller.onItemTap(item),
                        ));
                      },
                    ),
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}


class _ItemCard extends StatelessWidget {
  final CommItemLite item;
  final bool isSelected;
  final VoidCallback onTap;

  const _ItemCard({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.imageIcon; 
    final bgColor = _parseColor(item.color, const Color(0xFFFFD700));

    return AACButtonCard(
      imageUrl: imageUrl,
      label: item.word ?? '',
      bgColor: bgColor,
      isSelected: isSelected,
      onTap: onTap,
    );
  }
}


class _SpeakBar extends StatelessWidget {
  final String text;
  final String? imageUrl;
  final Color itemColor;
  final String hint;
  final VoidCallback onSpeak;
  final VoidCallback onClear;
  final bool isCooldown;
  final int cooldownCount;

  const _SpeakBar({
    required this.text,
    required this.imageUrl,
    required this.itemColor,
    required this.hint,
    required this.onSpeak,
    required this.onClear,
    this.isCooldown = false,
    this.cooldownCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    final hasText = text.isNotEmpty;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE3E3E9)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 7,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: hasText
                  ? Row(children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: itemColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: imageUrl != null && imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => const Icon(
                        Icons.image_outlined,
                        color: Colors.white,
                        size: 20),
                  )
                      : const Icon(Icons.image_outlined,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                          fontSize: 16, color: Colors.black87)),
                ),
              ])
                  : Text(hint,
                  style: GoogleFonts.nunito(
                      fontSize: 16, color: Colors.grey[400])),
            ),
          ),
        ),
        const SizedBox(width: 10),

        _SpeakBtn(
          isCooldown: isCooldown,
          cooldownCount: cooldownCount,
          onTap: isCooldown ? null : onSpeak,
        ),
        const SizedBox(width: 10),

        _BarBtn(
          color: const Color(0xFFE57373),
          onTap: onClear,
          child: SvgPicture.asset(ImagesLink.cancelIcon, width: 22, height: 22),
        ),
      ],
    );
  }
}


class _SpeakBtn extends StatelessWidget {
  final bool isCooldown;
  final int cooldownCount;
  final VoidCallback? onTap;

  const _SpeakBtn({
    required this.isCooldown,
    required this.cooldownCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: isCooldown
                  ? const Color(0xFF7BC5D3).withOpacity(0.45)
                  : const Color(0xFF7BC5D3),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Center(
              child: SvgPicture.asset(
                ImagesLink.speakIcon,
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(
                  isCooldown ? Colors.white.withOpacity(0.55) : Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),

          if (isCooldown)
            Positioned(
              top: -8,
              right: -8,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: child,
                ),
                child: Container(
                  key: ValueKey(cooldownCount),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$cooldownCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BarBtn extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;
  final Widget child;

  const _BarBtn(
      {required this.color, required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        width: 46,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}