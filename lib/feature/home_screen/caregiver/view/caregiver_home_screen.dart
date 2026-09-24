import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatter_bee/widgets/sentence_bar.dart';
import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:chatter_bee/feature/Profile/controller/profile_controller.dart';
import 'package:chatter_bee/feature/home_screen/caregiver/controller/caregiver_home_controller.dart';
import 'package:chatter_bee/feature/home_screen/caregiver/view/caregiver_all_categories_screen.dart';
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

/// Home Quick Speak: 15 ta word + 1 ta "See all" = 16 cell (4 x 4).
const int _kMaxHomeQs = 15;

int _homeQsCols(BuildContext context) =>
    MediaQuery.of(context).size.width >= 600 ? 8 : 4;


class CaregiverHomeScreen extends StatelessWidget {
  const CaregiverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CaregiverHomeController>();
    Get.put(ProfileController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: PageView(
              controller: controller.pageController,
              onPageChanged: (i) => controller.currentPage.value = i,
              children: const [
                _CgHomePage(),
                CaregiverAllCategoriesScreen(embedded: true),
              ],
            ),
          ),
          Obx(() => Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                2,
                    (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: controller.currentPage.value == i
                        ? const Color(0xFFFFC857)
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
          )),
        ]),
      ),
    );
  }
}


class _CgHomePage extends StatelessWidget {
  const _CgHomePage();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CaregiverHomeController>();
    final profileController = Get.find<ProfileController>();

    return Obx(() {
      if (controller.isLoading.value &&
          controller.quickSpeaks.isEmpty &&
          controller.categories.isEmpty) {
        return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFFC857)));
      }

      final cols = _homeQsCols(context);

      return RefreshIndicator(
        onRefresh: controller.refresh,
        color: const Color(0xFFFFC857),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ───────── Top bar: logo, search, profile ─────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Image.asset(ImagesLink.logo,
                            height: 47, fit: BoxFit.contain),
                      ),
                    ),
                    Row(children: [
                      IconButton(
                        icon: const Icon(Icons.search,
                            color: Color(0xFF1A1A1A)),
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
                    ]),
                  ],
                ),
              ),
            ),

            // ───────── Search box ─────────
            SliverToBoxAdapter(
              child: Obx(() {
                if (!controller.isSearchOpen.value) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: TextField(
                    onChanged: (v) => controller.searchQuery.value = v,
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    decoration: InputDecoration(
                      hintText: 'search_symbols'.tr,
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                        const BorderSide(color: Color(0xFFE3E3E9)),
                      ),
                    ),
                  ),
                );
              }),
            ),

            // ───────── Sentence bar (mockup: logo-r niche) ─────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: SentenceBar(
                  hint: 'select_quick_speak_hint'.tr,
                  onSpeak: controller.speakSelectedQuickSpeak,
                  onClear: controller.clearQuickSpeak,
                ),
              ),
            ),

            // ───────── Quick Speak header ─────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: CgSectionHeader(title: 'quick_speak'.tr)),
                    Obx(() => Row(children: [
                      _EditToggleBtn(
                        isEdit: controller.isQsEditMode.value,
                        onTap: controller.toggleQsEditMode,
                      ),
                      if (!controller.isQsEditMode.value) ...[
                        const SizedBox(width: 8),
                        _AddBtn(onTap: controller.showAddQuickSpeakSheet),
                      ],
                    ])),
                  ],
                ),
              ),
            ),

            // ───────── Quick Speak grid: 15 + See all ─────────
            Obx(() {
              final searching =
                  controller.searchQuery.value.trim().isNotEmpty;
              // search cholle filtered list; nahole original order (swap index thik thakbe)
              final qsList = searching
                  ? controller.filteredQuickSpeaks
                  : controller.quickSpeaks.toList();
              final editing = controller.isQsEditMode.value;
              final swapIdx = controller.swapFromIndex.value;
              final selectedId = controller.selectedQuickSpeakId.value;

              if (qsList.isEmpty) {
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

              final showCount = qsList.length > _kMaxHomeQs
                  ? _kMaxHomeQs
                  : qsList.length;
              final cellCount = showCount + 1; // last = See all

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                        (_, i) {
                      if (i == showCount) {
                        return CgSeeAllCard(
                          onTap: () => Get.toNamed(
                              AppRoutes.CAREGIVER_ALL_QUICK_SPEAKS),
                        );
                      }
                      final qs = qsList[i];
                      return CgFolderCard(
                        imageUrl: AppUrl.mediaUrl(qs.imageIcon),
                        label: qs.word ?? '',
                        bgColor:
                        _parseColor(qs.color, const Color(0xFFFFD700)),
                        isSelected:
                        editing ? swapIdx == i : selectedId == qs.id,
                        showEditBtn: editing,
                        onTap: () => searching
                            ? controller.selectQuickSpeak(qs)
                            : controller.onQuickSpeakTap(i, qs),
                        onEditTap: () =>
                            controller.showEditQuickSpeakSheet(qs),
                      );
                    },
                    childCount: cellCount,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.82,
                  ),
                ),
              );
            }),

            // ───────── Explore more (3 ta button) ─────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: CgSectionHeader(title: 'explore_more'.tr),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: LayoutBuilder(builder: (_, c) {
                  final perRow = c.maxWidth >= 560 ? 3 : 2;
                  final w = (c.maxWidth - 12 * (perRow - 1)) / perRow;
                  final cards = <Widget>[
                    _ExploreCard(
                      icon: Icons.calendar_month_outlined,
                      color: const Color(0xFFFDD268),
                      title: 'my_schedule'.tr,
                      subtitle: 'see_whats_next'.tr,
                      onTap: controller.openSchedule,
                    ),
                    _ExploreCard(
                      icon: Icons.keyboard_alt_outlined,
                      color: const Color(0xFFB5CFD1),
                      title: 'text_to_speak'.tr,
                      subtitle: 'type_and_hear_it'.tr,
                      onTap: () => Get.toNamed(AppRoutes.TEXT_TO_SPEAK),
                    ),
                    _ExploreCard(
                      icon: Icons.grid_view_rounded,
                      color: const Color(0xFF7BC5D3),
                      title: 'all_categories'.tr,
                      subtitle: 'browse_all_categories'.tr,
                      onTap: () => controller.goToPage(1),
                    ),
                  ];
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: cards
                        .map((e) => SizedBox(width: w, height: 76, child: e))
                        .toList(),
                  );
                }),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      );
    });
  }
}


class _ExploreCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ExploreCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.22),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: color.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: const Color(0xFF1A1A1A), size: 22),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                        fontSize: 13, fontWeight: FontWeight.w800)),
                Text(subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                        fontSize: 10.5, color: Colors.grey[600])),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 18, color: Colors.black54),
        ]),
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
        final imgSize = (constraints.maxWidth * 0.52)
            .clamp(0.0, constraints.maxHeight * 0.42);

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
        final imgSize = (constraints.maxWidth * 0.52)
            .clamp(0.0, constraints.maxHeight * 0.42);

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
    return Row(children: [
      Container(
        width: 4,
        height: 18,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: const Color(0xFFFFC857)),
      ),
      const SizedBox(width: 8),
      Flexible(
        child: Text(title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
      ),
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