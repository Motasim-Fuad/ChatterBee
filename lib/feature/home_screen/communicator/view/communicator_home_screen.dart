import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatter_bee/config/app_colors.dart';
import 'package:chatter_bee/widgets/sentence_bar.dart';
import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:chatter_bee/feature/Profile/controller/profile_controller.dart';
import 'package:chatter_bee/feature/home_screen/communicator/contoller/communicator_home_controller.dart';
import 'package:chatter_bee/models/communicator_models/communicator_content_model.dart';
import 'package:chatter_bee/routes/app_routes.dart';
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


class CommunicatorHomeScreen extends GetView<CommunicatorHomeController> {
  const CommunicatorHomeScreen({super.key});

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
    final profileController = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFC857)),
            );
          }

          if (controller.loadError.value.isNotEmpty) {
            return _DashboardLoadError(
              message: controller.loadError.value,
              onRetry: controller.loadContent,
            );
          }

          return OrientationBuilder(builder: (context, _) {
            final cols = _crossAxisCount(context);

            return GestureDetector(
              onHorizontalDragEnd: (details) {
                final v = details.primaryVelocity ?? 0;
                if (v < -250) controller.homePageIndex.value = 1;
                if (v > 250) controller.homePageIndex.value = 0;
              },
              child: RefreshIndicator(
              onRefresh: controller.refresh,
              color: const Color(0xFFFFC857),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
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
                              painter: DashedCirclePainter(
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
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
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
                              borderSide: const BorderSide(color: Color(0xFFE3E3E9)),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                      child: Obx(() => SentenceBar(
                        hint: 'select_quick_speak_hint'.tr,
                        lang: controller.currentLang,
                        isCooldown: controller.isSpeakCooldown.value,
                        cooldownCount: controller.cooldownCount.value,
                        onSpeak: controller.speakQuickSpeak,
                        onClear: controller.clearQuickSpeak,
                      )),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Obx(() => controller.homePageIndex.value == 0
                        ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                      child: CommSectionHeader(title: 'quick_speak'.tr),
                    )
                        : const SizedBox.shrink()),
                  ),

                  Obx(() {
                    if (controller.homePageIndex.value != 0) {
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    }
                    final qsList = controller.filteredQuickSpeaks;
                    final hasMore = qsList.length > _kMaxHome;
                    final showCount = hasMore ? _kMaxHome : qsList.length;
                    final cellCount = 1 + showCount + (hasMore ? 1 : 0);

                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                              (_, i) {
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
                            if (hasMore && i == showCount + 1) {
                              return CommSeeAllCard(
                                onTap: () => Get.toNamed(
                                    AppRoutes.COMMUNICATOR_ALL_QUICK_SPEAKS),
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
                    child: Obx(() => Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                      child: CommSectionHeader(
                          title: controller.homePageIndex.value == 0
                              ? 'tap_to_talk'.tr
                              : 'all_categories'.tr),
                    )),
                  ),

                  Obx(() {
                    if (controller.homePageIndex.value == 0) {
                      final words = controller.homeTalkButtons;
                      if (words.isEmpty) {
                        return SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Text('no_categories_available'.tr,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[500])),
                          ),
                        );
                      }
                      return SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) {
                              final item = words[i];
                              return CommCard(
                                imageUrl: AppUrl.mediaUrl(item.imageIcon),
                                label: item.word ?? '',
                                bgColor: _parseColor(
                                    item.color, const Color(0xFFFFD700)),
                                isSelected: false,
                                onTap: () => controller.onSearchItemTap(item),
                              );
                            },
                            childCount: words.length,
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
                    }

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
                                Text('no_categories_available'.tr,
                                    style:
                                    TextStyle(color: Colors.grey[500])),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    final cats = controller.filteredCategories;
                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                              (_, i) {
                            final cat = cats[i];
                            return CommCard(
                              imageUrl: AppUrl.mediaUrl(cat.imageIcon),
                              label: cat.name,
                              subLabel: cat.subCategoriesCount > 0
                                  ? '${cat.subCategoriesCount} ${'sub_count_suffix'.tr}'
                                  : null,
                              bgColor: _parseColor(
                                  cat.color, const Color(0xFFB5CFD1)),
                              isSelected: false,
                              onTap: () => controller.onCategoryTap(cat),
                            );
                          },
                          childCount: cats.length,
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

                  Obx(() {
                    if (controller.homePageIndex.value == 0) {
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    }
                    return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
                      child: CommSectionHeader(title: 'explore_more'.tr),
                    ),
                  );
                  }),

                  Obx(() {
                    if (controller.homePageIndex.value == 0) {
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    }
                    return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                            (_, i) {
                          final item = _exploreItems[i];
                          return CommCard(
                            label: item.labelKey.tr,
                            bgColor: item.color,
                            icon: item.icon,
                            isSelected: false,
                            onTap: item.route == AppRoutes.ACTIVITIES
                                ? controller.openSchedule
                                : () => Get.toNamed(item.route),
                          );
                        },
                        childCount: _exploreItems.length,
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
                    child: Obx(() => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: controller.homePageIndex.value == 0
                                ? null
                                : () => controller.homePageIndex.value = 0,
                            icon: const Icon(Icons.chevron_left),
                          ),
                          Icon(
                            controller.homePageIndex.value == 0
                                ? Icons.circle
                                : Icons.circle_outlined,
                            size: 10,
                            color: const Color(0xFFFFC857),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            controller.homePageIndex.value == 1
                                ? Icons.circle
                                : Icons.circle_outlined,
                            size: 10,
                            color: const Color(0xFFFFC857),
                          ),
                          IconButton(
                            onPressed: controller.homePageIndex.value == 1
                                ? null
                                : () => controller.homePageIndex.value = 1,
                            icon: const Icon(Icons.chevron_right),
                          ),
                        ],
                      ),
                    )),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            ),
            );
          });
        }),
      ),
    );
  }
}

class _DashboardLoadError extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _DashboardLoadError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text('retry'.tr),
            ),
          ],
        ),
      ),
    );
  }
}


class CommCard extends StatelessWidget {
  final String? imageUrl;
  final String label;
  final String? subLabel;
  final Color bgColor;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const CommCard({
    super.key,
    this.imageUrl,
    required this.label,
    this.subLabel,
    required this.bgColor,
    this.icon,
    required this.isSelected,
    required this.onTap,
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
          painter: CommFolderPainter(
            cardColor: isSelected ? bgColor.withOpacity(0.15) : Colors.white,
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
            if (isSelected)
              Positioned(
                top: tabH - 8,
                left: 5,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration:
                  BoxDecoration(color: bgColor, shape: BoxShape.circle),
                  child:
                  const Icon(Icons.check, color: Colors.white, size: 12),
                ),
              ),
          ]),
        );
      }),
    );
  }
}

class CommSeeAllCard extends StatelessWidget {
  final VoidCallback onTap;
  const CommSeeAllCard({super.key, required this.onTap});

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
          painter: const CommFolderPainter(
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
                    child: Icon(
                      Icons.grid_view_rounded,
                      color: const Color(0xFF7BC5D3),
                      size: imgSize * 0.52,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'see_all'.tr,
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF7BC5D3),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        );
      }),
    );
  }
}


class CommSpeakBar extends StatelessWidget {
  final String text;
  final String imageUrl;
  final Color color;
  final String hint;
  final VoidCallback onSpeak;
  final VoidCallback onClear;

  final bool isCooldown;

  final int cooldownCount;

  const CommSpeakBar({
    super.key,
    required this.text,
    this.imageUrl = '',
    this.color = const Color(0xFFFFD700),
    required this.hint,
    required this.onSpeak,
    required this.onClear,
    this.isCooldown = false,
    this.cooldownCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    final hasText = text.isNotEmpty;
    return Row(children: [
      Expanded(
        child: Container(
          height: 64,
          padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE3E3E9)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 7,
                  offset: const Offset(0, 4))
            ],
          ),
          child: hasText
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
                    hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                        fontSize: 15, color: Colors.grey[400]),
                  ),
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
    ]);
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
                    offset: const Offset(0, 4))
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
                offset: const Offset(0, 4))
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}

class CommSectionHeader extends StatelessWidget {
  final String title;
  const CommSectionHeader({super.key, required this.title});

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
      Expanded(
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

class CommFolderPainter extends CustomPainter {
  final Color cardColor;
  final Color tabColor;
  final bool isSelected;
  final Color selectedBorderColor;

  const CommFolderPainter({
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
  bool shouldRepaint(CommFolderPainter old) =>
      old.cardColor != cardColor ||
          old.tabColor != tabColor ||
          old.isSelected != isSelected;
}

class DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DashedCirclePainter({
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
      final startAngle = (i * (dashWidth + dashSpace) / radius);
      final sweepAngle = dashWidth / radius;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
          startAngle, sweepAngle, false, paint);
    }
  }

  @override
  bool shouldRepaint(DashedCirclePainter old) =>
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
