import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/feature/home_screen/caregiver/controller/caregiver_sub_catagory_controller.dart';
import 'package:chatter_bee/feature/home_screen/caregiver/view/caregiver_home_screen.dart'
    show CgFolderCard;
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


class CaregiverSubCategoryScreen extends StatelessWidget {
  const CaregiverSubCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CaregiverSubCategoryController>();

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
          controller.parentCategory.name,
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

        final subs = controller.subCategories.toList();
        if (subs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open_outlined,
                    size: 64, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Text('no_sub_categories_yet'.tr,
                    style: TextStyle(
                        color: Colors.grey[500], fontSize: 15)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: controller.showAddSheet,
                  icon: const Icon(Icons.add, color: Colors.black),
                  label: Text('add_sub_category'.tr,
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
              itemCount: subs.length,
              itemBuilder: (_, i) {
                final sub = subs[i];
                return Obx(() {
                  final isSelected =
                  controller.selectedIds.contains(sub.id);
                  return CgFolderCard(
                    imageUrl: AppUrl.mediaUrl(sub.imageIcon),
                    label: sub.name,
                    subLabel: sub.items.isNotEmpty
                        ? '${sub.items.length} ${'items_count_suffix'.tr}'
                        : null,
                    bgColor: _parseColor(
                        sub.color, const Color(0xFFB5CFD1)),
                    isSelected: isSelected,
                    showEditBtn: controller.isEditMode.value,
                    onTap: () => controller.onSubCategoryTap(sub),
                    onEditTap: () => controller.showEditSheet(sub),
                  );
                });
              },
            ),
          );
        });
      }),
    );
  }
}
