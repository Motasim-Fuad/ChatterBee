import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:chatter_bee/feature/Profile/controller/profile_controller.dart';
import 'package:chatter_bee/feature/home_screen/caregiver/controller/caregiver_home_controller.dart';
import 'package:chatter_bee/models/caregiver_models/caregiver_content_model.dart';
import 'package:chatter_bee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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

const int _kMaxHome = 8;

class _ExploreItem {
  final String labelKey;
  final IconData icon;
  final Color color;
  final String route;
  const _ExploreItem({
    required this.labelKey,
    required this.icon,
    required this.color,
    required this.route,
  });
}


class CaregiverHomeScreen extends StatelessWidget {
  const CaregiverHomeScreen({super.key});

  static const List<_ExploreItem> _exploreItems = [
    _ExploreItem(
      labelKey: 'my_schedule',
      icon: Icons.calendar_month_outlined,
      color: Color(0xFFFDD268),
      route: AppRoutes.ACTIVITIES,
    ),
    _ExploreItem(
      labelKey: 'text_to_speak',
      icon: Icons.keyboard_voice_outlined,
      color: Color(0xFFB5CFD1),
      route: AppRoutes.TEXT_TO_SPEAK,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CaregiverHomeController>();
    final profileController = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFC857)),
            );
          }

          return OrientationBuilder(builder: (context, _) {
            final cols = _crossAxisCount(context);

            return RefreshIndicator(
              onRefresh: controller.refresh,
              color: const Color(0xFFFFC857),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(ImagesLink.logo, height: 47),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.search, color: Color(0xFF1A1A1A)),
                                onPressed: () => controller.isSearchOpen.toggle(),
                              ),
                          GestureDetector(
                            onTap: () => Get.toNamed(AppRoutes.PROFILE),
                            child: CustomPaint(
                              size: const Size(48, 48),
                              painter: CgDashedCirclePainter(
                                color: const Color(0xFFB5CFD1),
                                strokeWidth: 1.0,
                                dashWidth: 4.0,
                                dashSpace: 3.1,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(3),
                                child: Obx(() => CircleAvatar(
                                  radius: 22,
                                  backgroundColor: Colors.grey.shade200,
                                  backgroundImage: profileController
                                      .avatarUrl.value.isNotEmpty
                                      ? CachedNetworkImageProvider(
                                      profileController.avatarUrl.value)
                                      : null,
                                  child: profileController
                                      .avatarUrl.value.isEmpty
                                      ? const Icon(Icons.person,
                                      size: 26, color: Colors.grey)
                                      : null,
                                )),
                              ),
                            ),
                          ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Obx(() {
                      if (!controller.isSearchOpen.value) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: TextField(
                          onChanged: (v) => controller.searchQuery.value = v,
                          decoration: InputDecoration(
                            hintText: 'search_symbols'.tr,
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE3E3E9)),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CgSectionHeader(title: 'quick_speak'.tr),
                          Obx(() => Row(children: [
                            _EditToggleBtn(
                              isEdit: controller.isQsEditMode.value,
                              onTap: controller.toggleQsEditMode,
                            ),
                            if (!controller.isQsEditMode.value) ...[
                              const SizedBox(width: 8),
                              _AddBtn(
                                  onTap: controller.showAddQuickSpeakSheet),
                            ],
                          ])),
                        ],
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Obx(() => CgQuickSpeakBar(
                        text: controller.selectedQuickSpeakText.value,
                        imageUrl: controller.selectedQuickSpeakImage.value,
                        color: _parseColor(controller.selectedQuickSpeakColor.value,
                            const Color(0xFFFFD700)),
                        onSpeak: controller.speakSelectedQuickSpeak,
                        onClear: controller.clearQuickSpeak,
                      )),
                    ),
                  ),

                  Obx(() {
                    final qsList = controller.filteredQuickSpeaks;
                    final showType = !controller.isQsEditMode.value;
                    final extra = showType ? 1 : 0;
                    if (qsList.isEmpty && !showType) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          child: Text('no_quick_speaks_hint'.tr,
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 13)),
                        ),
                      );
                    }

                    final hasMore = qsList.length > _kMaxHome;
                    final showCount =
                    hasMore ? _kMaxHome : qsList.length;
                    final cellCount = extra + showCount + (hasMore ? 1 : 0);

                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                              (_, i) {
                            if (showType && i == 0) {
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
                            if (hasMore && i == extra + showCount) {
                              return CgSeeAllCard(
                                onTap: () => Get.toNamed(
                                    AppRoutes.CAREGIVER_ALL_QUICK_SPEAKS),
                              );
                            }
                            final qs = qsList[i - extra];
                            return Obx(() => CgFolderCard(
                              imageUrl: AppUrl.mediaUrl(qs.imageIcon),
                              label: qs.word ?? '',
                              bgColor: _parseColor(
                                  qs.color, const Color(0xFFFFD700)),
                              isSelected: false,
                              showEditBtn: controller.isQsEditMode.value,
                              onTap: () {
                                if (!controller.isQsEditMode.value) {
                                  controller.selectQuickSpeak(qs);
                                }
                              },
                              onEditTap: () => controller
                                  .showEditQuickSpeakSheet(qs),
                            ));
                          },
                          childCount: cellCount,
                        ),
                        gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.82,
                        ),
                      ),
                    );
                  }),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CgSectionHeader(title: 'tap_to_talk'.tr),
                          Obx(() => Row(children: [
                            _EditToggleBtn(
                              isEdit: controller.isEditMode.value,
                              onTap: controller.toggleEditMode,
                            ),
                            if (!controller.isEditMode.value) ...[
                              const SizedBox(width: 8),
                              _AddBtn(
                                  onTap:
                                  controller.showAddCategorySheet),
                            ],
                          ])),
                        ],
                      ),
                    ),
                  ),

                  Obx(() {
                    if (controller.filteredCategories.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              children: [
                                Icon(Icons.category_outlined,
                                    size: 60, color: Colors.grey[300]),
                                const SizedBox(height: 12),
                                Text('no_categories_yet'.tr,
                                    style:
                                    TextStyle(color: Colors.grey[500])),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: controller.showAddCategorySheet,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                      const Color(0xFFFFC857)),
                                  child: Text('add_category'.tr,
                                      style: const TextStyle(
                                          color: Colors.black)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    final hasMore =
                        controller.filteredCategories.length > _kMaxHome;
                    final showCount =
                    hasMore ? _kMaxHome : controller.filteredCategories.length;
                    final cellCount = showCount + (hasMore ? 1 : 0);

                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                              (_, i) {
                            if (hasMore && i == _kMaxHome) {
                              return CgSeeAllCard(
                                onTap: () => Get.toNamed(
                                    AppRoutes.CAREGIVER_ALL_CATEGORIES),
                              );
                            }
                            final cat = controller.filteredCategories[i];
                            return Obx(() {
                              final isSelected = controller
                                  .selectedCategoryIds
                                  .contains(cat.id);
                              return CgFolderCard(
                                imageUrl: AppUrl.mediaUrl(cat.imageIcon),
                                label: cat.name,
                                subLabel: cat.subCategories.isNotEmpty
                                    ? '${cat.subCategories.length} ${'sub_count_suffix'.tr}'
                                    : null,
                                bgColor: _parseColor(
                                    cat.color, const Color(0xFFB5CFD1)),
                                isSelected: isSelected,
                                showEditBtn: controller.isEditMode.value,
                                onTap: () => controller.onCategoryTap(cat),
                                onEditTap: () =>
                                    controller.showEditCategorySheet(cat),
                              );
                            });
                          },
                          childCount: cellCount,
                        ),
                        gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.82,
                        ),
                      ),
                    );
                  }),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                      child: CgSectionHeader(title: 'explore_more'.tr),
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                            (_, i) {
                          final item = _exploreItems[i];
                          return CgFolderCard(
                            label: item.labelKey.tr,
                            bgColor: item.color,
                            icon: item.icon,
                            isSelected: false,
                            showEditBtn: false,
                            onTap: () => Get.toNamed(item.route),
                          );
                        },
                        childCount: _exploreItems.length,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.82,
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            );
          });
        }),
      ),
    );
  }
}

class CgQuickSpeakBar extends StatelessWidget {
  final String text;
  final String imageUrl;
  final Color color;
  final VoidCallback onSpeak;
  final VoidCallback onClear;

  const CgQuickSpeakBar({super.key, required this.text, required this.imageUrl,
    required this.color, required this.onSpeak, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final selected = text.isNotEmpty;
    return LayoutBuilder(builder: (_, constraints) {
      final compact = constraints.maxWidth < 340;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              height: 64,
              padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE3E3E9)),
              ),
              child: selected
                  ? Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: imageUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => ColoredBox(color: color),
                                    errorWidget: (_, __, ___) => const Icon(
                                      Icons.image_outlined,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.image_outlined, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            text,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.nunito(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'select_quick_speak_hint'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(
                            fontSize: 15, color: Colors.grey[400]),
                      ),
                    ),
            ),
          ),
          SizedBox(width: compact ? 6 : 10),
          _CaregiverBarButton(
              color: const Color(0xFF7BC5D3),
              onTap: onSpeak,
              child: SvgPicture.asset(ImagesLink.speakIcon,
                  width: 22, height: 22)),
          SizedBox(width: compact ? 6 : 10),
          _CaregiverBarButton(
              color: const Color(0xFFE57373),
              onTap: onClear,
              child: SvgPicture.asset(ImagesLink.cancelIcon,
                  width: 22, height: 22)),
        ],
      );
    });
  }
}

class _CgBarAction extends StatelessWidget {
  final double size;
  final Color color;
  final bool enabled;
  final IconData icon;
  final VoidCallback onTap;
  const _CgBarAction({required this.size, required this.color, required this.enabled,
    required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: enabled ? onTap : null,
    borderRadius: BorderRadius.circular(12),
    child: Container(width: size, height: size,
      decoration: BoxDecoration(color: enabled ? color : color.withOpacity(.4),
        borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: Colors.white, size: 22)),
  );
}

// Show Cg Card Lift Dialog

void showCgCardLiftDialog({
  required BuildContext context,
  required String? imageUrl,
  required String label,
  required Color color,
  required bool hasAudio,
  VoidCallback? onPlayAudio,
}) {
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
        scale: Tween(begin: 0.7, end: 1.0).animate(curved),
        child: FadeTransition(
          opacity: anim,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: 220,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(24),
                    border:
                    Border.all(color: color.withOpacity(0.4), width: 2),
                    boxShadow: [
                      BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 4),
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
                          color: color.withOpacity(0.2),
                        ),
                        child: imageUrl != null && imageUrl.isNotEmpty
                            ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Icon(
                                Icons.image_outlined,
                                color: color,
                                size: 48),
                          ),
                        )
                            : Icon(Icons.record_voice_over_outlined,
                            color: color, size: 48),
                      ),
                      const SizedBox(height: 16),
                      Text(label,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1A1A))),
                      if (hasAudio && onPlayAudio != null) ...[
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            onPlayAudio();
                            Navigator.of(ctx).pop();
                          },
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: color.withOpacity(0.4),
                                    blurRadius: 12)
                              ],
                            ),
                            child: const Icon(Icons.volume_up,
                                color: Colors.white, size: 28),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('tap_to_speak'.tr,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[500])),
                      ],
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


class CgFolderCard extends StatelessWidget {
  final String? imageUrl;
  final String label;
  final String? subLabel;
  final Color bgColor;
  final IconData? icon;
  final bool isSelected;
  final bool showEditBtn;
  final VoidCallback onTap;
  final VoidCallback? onEditTap;

  const CgFolderCard({
    super.key,
    this.imageUrl,
    required this.label,
    this.subLabel,
    required this.bgColor,
    this.icon,
    required this.isSelected,
    required this.showEditBtn,
    required this.onTap,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: LayoutBuilder(builder: (context, constraints) {
        final tabH = constraints.maxHeight * 0.10;
        final topPad = tabH + 6;
        final imgSize = constraints.maxWidth * 0.52;

        return CustomPaint(
          painter: CgFolderPainter(
            cardColor:
            isSelected ? bgColor.withOpacity(0.15) : Colors.white,
            tabColor: bgColor,
            isSelected: isSelected,
            selectedBorderColor: bgColor,
          ),
          child: Stack(children: [
            Positioned.fill(
              top: topPad,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: imgSize,
                    height: imgSize,
                    decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(10)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: imageUrl != null && imageUrl!.isNotEmpty
                          ? CachedNetworkImage(
                        imageUrl: imageUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Icon(
                            Icons.image_outlined,
                            color: Colors.white,
                            size: imgSize * 0.45),
                      )
                          : Icon(
                        icon ?? Icons.image_outlined,
                        color: icon != null
                            ? bgColor._darken(30)
                            : Colors.white,
                        size: imgSize * 0.50,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1A1A))),
                  ),
                  if (subLabel != null)
                    Text(subLabel!,
                        style: TextStyle(
                            fontSize: 9, color: Colors.grey[400])),
                ],
              ),
            ),
            if (showEditBtn)
              Positioned(
                top: tabH - 9,
                right: 5,
                child: GestureDetector(
                  onTap: onEditTap,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                        color: Color(0xFFFFC857), shape: BoxShape.circle),
                    child:
                    const Icon(Icons.edit, size: 12, color: Colors.black),
                  ),
                ),
              ),
            if (isSelected)
              Positioned(
                top: tabH - 9,
                left: 5,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration:
                  BoxDecoration(color: bgColor, shape: BoxShape.circle),
                  child:
                  const Icon(Icons.check, color: Colors.white, size: 13),
                ),
              ),
          ]),
        );
      }),
    );
  }
}

class CgSeeAllCard extends StatelessWidget {
  final VoidCallback onTap;
  const CgSeeAllCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: LayoutBuilder(builder: (context, constraints) {
        final tabH = constraints.maxHeight * 0.10;
        final topPad = tabH + 6;
        final imgSize = constraints.maxWidth * 0.52;

        return CustomPaint(
          painter: const CgFolderPainter(
            cardColor: Color(0xFFEDF7F9),
            tabColor: Color(0xFF7BC5D3),
          ),
          child: Stack(children: [
            Positioned.fill(
              top: topPad,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: imgSize,
                    height: imgSize,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7BC5D3).withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.grid_view_rounded,
                        color: const Color(0xFF7BC5D3), size: imgSize * 0.52),
                  ),
                  const SizedBox(height: 6),
                  Text('see_all'.tr,
                      style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF7BC5D3))),
                ],
              ),
            ),
          ]),
        );
      }),
    );
  }
}

class CgSectionHeader extends StatelessWidget {
  final String title;
  const CgSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 4,
        height: 18,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: const Color(0xFFFFC857)),
      ),
      const SizedBox(width: 8),
      Text(title,
          style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87)),
    ]);
  }
}

class _EditToggleBtn extends StatelessWidget {
  final bool isEdit;
  final VoidCallback onTap;
  const _EditToggleBtn({required this.isEdit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isEdit ? const Color(0xFFFFC857) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFC857)),
        ),
        child: Text(isEdit ? 'done'.tr : 'edit'.tr,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isEdit ? Colors.black : const Color(0xFFFFC857))),
      ),
    );
  }
}

class _AddBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _AddBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
            color: const Color(0xFFFFC857),
            borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.add, size: 14, color: Colors.black),
          const SizedBox(width: 4),
          Text('add'.tr,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black)),
        ]),
      ),
    );
  }
}


class CgFolderPainter extends CustomPainter {
  final Color cardColor;
  final Color tabColor;
  final bool isSelected;
  final Color selectedBorderColor;

  const CgFolderPainter({
    required this.cardColor,
    required this.tabColor,
    this.isSelected = false,
    this.selectedBorderColor = const Color(0xFFFFC857),
  });

  @override
  void paint(Canvas canvas, Size size) {
    const radius = 16.0;
    const topRightRadius = 8.0;
    final tabWidth = size.width * 0.55;
    final tabHeight = size.height * 0.10;
    final tabSlantWidth = tabHeight * 0.5;

    final path = Path()
      ..moveTo(0, size.height - radius)
      ..quadraticBezierTo(0, size.height, radius, size.height)
      ..lineTo(size.width - radius, size.height)
      ..quadraticBezierTo(
          size.width, size.height, size.width, size.height - radius)
      ..lineTo(size.width, topRightRadius)
      ..quadraticBezierTo(size.width, 0, size.width - topRightRadius, 0)
      ..lineTo(tabWidth + tabSlantWidth + radius, 0)
      ..quadraticBezierTo(tabWidth + tabSlantWidth, 0,
          tabWidth + tabSlantWidth, radius * 0.3)
      ..lineTo(tabWidth, tabHeight)
      ..lineTo(radius, tabHeight)
      ..quadraticBezierTo(0, tabHeight, 0, tabHeight + radius)
      ..lineTo(0, size.height - radius)
      ..close();

    canvas.drawShadow(path, Colors.black.withOpacity(0.10), 6.0, false);
    canvas.drawPath(path, Paint()
      ..color = cardColor
      ..style = PaintingStyle.fill);

    final tabPath = Path()
      ..moveTo(0, 0)
      ..lineTo(tabWidth + tabSlantWidth + radius, 0)
      ..quadraticBezierTo(tabWidth + tabSlantWidth, 0,
          tabWidth + tabSlantWidth, radius * 0.3)
      ..lineTo(tabWidth, tabHeight)
      ..lineTo(0, tabHeight)
      ..close();

    canvas.save();
    canvas.clipPath(path);
    canvas.drawPath(tabPath, Paint()
      ..color = tabColor
      ..style = PaintingStyle.fill);
    canvas.restore();

    if (isSelected) {
      canvas.drawPath(
          path,
          Paint()
            ..color = selectedBorderColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0);
    }
  }

  @override
  bool shouldRepaint(CgFolderPainter old) =>
      old.cardColor != cardColor ||
          old.tabColor != tabColor ||
          old.isSelected != isSelected;
}


class CgDashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  CgDashedCirclePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final circumference = 2 * 3.14159 * radius;
    final dashCount = (circumference / (dashWidth + dashSpace)).floor();
    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * (dashWidth + dashSpace) / radius,
        dashWidth / radius,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CgDashedCirclePainter old) =>
      old.color != color ||
          old.strokeWidth != strokeWidth ||
          old.dashWidth != dashWidth ||
          old.dashSpace != dashSpace;
}

extension _ColorX on Color {
  Color _darken(int percent) {
    final f = 1 - percent / 100;
    return Color.fromARGB(
        alpha, (red * f).round(), (green * f).round(), (blue * f).round());
  }
}
