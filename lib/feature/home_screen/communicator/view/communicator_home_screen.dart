import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatter_bee/config/app_colors.dart';
import 'package:chatter_bee/widgets/sentence_bar.dart';
import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:chatter_bee/feature/Profile/controller/profile_controller.dart';
import 'package:chatter_bee/feature/home_screen/communicator/contoller/communicator_home_controller.dart';
import 'package:chatter_bee/feature/home_screen/communicator/view/communicator_all_categories_screen.dart';
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

/// Home Quick Speak: 15 ta word + 1 ta "See all" = 16 cell (4 x 4).
const int _kMaxHomeQs = 15;

int _homeQsCols(BuildContext context) =>
    MediaQuery.of(context).size.width >= 600 ? 8 : 4;


class CommunicatorHomeScreen extends GetView<CommunicatorHomeController> {
  const CommunicatorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ProfileController());

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: PageView(
              controller: controller.pageController,
              onPageChanged: (i) => controller.homePageIndex.value = i,
              children: const [
                _CommHomePage(),
                CommunicatorAllCategoriesScreen(embedded: true),
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
                    color: controller.homePageIndex.value == i
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


class _CommHomePage extends StatelessWidget {
  const _CommHomePage();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CommunicatorHomeController>();
    final profileController = Get.find<ProfileController>();

    return Obx(() {
      final empty =
          controller.quickSpeaks.isEmpty && controller.categories.isEmpty;

      if (controller.isLoading.value && empty) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFFFFC857)),
        );
      }

      if (controller.loadError.value.isNotEmpty && empty) {
        return _DashboardLoadError(
          message: controller.loadError.value,
          onRetry: controller.loadContent,
        );
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

            // ───────── Sentence bar ─────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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

            // ───────── Quick Speak header ─────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: CommSectionHeader(title: 'quick_speak'.tr),
              ),
            ),

            // ───────── Quick Speak grid: 15 + See all ─────────
            Obx(() {
              final searching =
                  controller.searchQuery.value.trim().isNotEmpty;
              final qsList = searching
                  ? controller.filteredQuickSpeaks
                  : controller.quickSpeaks.toList();
              // search cholle matching item-o dekhabe
              final itemResults = searching
                  ? controller.filteredItems
                  : const <CommItemModel>[];
              final selectedId = controller.selectedQsId.value;

              if (qsList.isEmpty && itemResults.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    child: Text(
                        searching
                            ? 'no_results_found'.tr
                            : 'no_quick_speaks_hint'.tr,
                        style: TextStyle(
                            color: Colors.grey[500], fontSize: 13)),
                  ),
                );
              }

              final showCount = searching
                  ? qsList.length
                  : (qsList.length > _kMaxHomeQs
                  ? _kMaxHomeQs
                  : qsList.length);
              // normal mode: last cell = See all
              final cellCount =
                  showCount + itemResults.length + (searching ? 0 : 1);

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                        (_, i) {
                      if (!searching && i == showCount) {
                        return CommSeeAllCard(
                          onTap: () => Get.toNamed(
                              AppRoutes.COMMUNICATOR_ALL_QUICK_SPEAKS),
                        );
                      }
                      if (i < showCount) {
                        final qs = qsList[i];
                        return CommCard(
                          imageUrl: AppUrl.mediaUrl(qs.imageIcon),
                          label: qs.word ?? '',
                          bgColor: _parseColor(
                              qs.color, const Color(0xFFFFD700)),
                          isSelected: selectedId == qs.id,
                          onTap: () => controller.onQuickSpeakTap(qs),
                        );
                      }
                      final item = itemResults[i - showCount];
                      return CommCard(
                        imageUrl: AppUrl.mediaUrl(item.imageIcon),
                        label: item.word ?? '',
                        bgColor: _parseColor(
                            item.color, const Color(0xFFFFD700)),
                        isSelected: false,
                        onTap: () => controller.onSearchItemTap(item),
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
                child: CommSectionHeader(title: 'explore_more'.tr),
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