import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/feature/home_screen/communicator/contoller/communicator_home_controller.dart';
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


class CommunicatorAllCategoriesScreen
    extends GetView<CommunicatorHomeController> {
  /// true hole home-er PageView-er 2nd page hishebe dekhabe
  /// (back = home page-e ferot, status bar padding nei).
  final bool embedded;
  const CommunicatorAllCategoriesScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final searchQuery = ''.obs;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        primary: !embedded,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: Color(0xFF1A1A1A)),
          onPressed: () => embedded ? controller.goToPage(0) : Get.back(),
        ),
        title: Text(
          'all_categories'.tr,
          style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A)),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE3E3E9)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 7,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: TextField(
                onChanged: (v) => searchQuery.value = v.trim().toLowerCase(),
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                style: GoogleFonts.nunito(fontSize: 16, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'search_categories'.tr,
                  hintStyle: GoogleFonts.nunito(
                      fontSize: 16, color: Colors.grey[400]),
                  prefixIcon:
                  const Icon(Icons.search, color: Color(0xFF7BC5D3)),
                  suffixIcon: Obx(() => searchQuery.value.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.close,
                        color: Colors.grey, size: 18),
                    onPressed: () {
                      searchQuery.value = '';
                    },
                  )
                      : const SizedBox.shrink()),
                  border: InputBorder.none,
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          Expanded(
            child: Obx(() {
              final query = searchQuery.value;
              final cats = controller.categories.toList();
              final filtered = query.isEmpty
                  ? cats
                  : cats
                  .where((c) =>
                  c.name.toLowerCase().contains(query))
                  .toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_outlined,
                          size: 60, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      Text(
                        query.isEmpty
                            ? 'no_categories_available'.tr
                            : 'no_results_found'.tr,
                        style: TextStyle(
                            color: Colors.grey[500], fontSize: 15),
                      ),
                    ],
                  ),
                );
              }

              return OrientationBuilder(builder: (context, _) {
                final cols = _crossAxisCount(context);
                return RefreshIndicator(
                  onRefresh: controller.refresh,
                  color: const Color(0xFFFFC857),
                  child: GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final cat = filtered[i];
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