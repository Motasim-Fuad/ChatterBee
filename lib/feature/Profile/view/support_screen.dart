import 'package:chatter_bee/config/app_colors.dart';
import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:chatter_bee/feature/Profile/controller/support_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SupportScreen extends GetView<SupportController> {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'support_title'.tr,
          style: GoogleFonts.nunito(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Image.asset(ImagesLink.logo, height: 50),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(controller.errorMessage.value,
                    style: GoogleFonts.nunito(
                        fontSize: 14, color: Colors.grey[600])),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: controller.fetchSupport,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor),
                  child: Text('retry'.tr),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(controller.title.value,
                    style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                Text(controller.description.value,
                    style: GoogleFonts.nunito(fontSize: 15, height: 1.6, color: const Color(0xFF636F85))),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Email us at:', style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    SelectableText(controller.supportEmail.value,
                        style: GoogleFonts.nunito(color: const Color(0xFF3178C6), fontWeight: FontWeight.w700)),
                  ]),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required String content,
    required bool isExpanded,
  }) {
    final RxBool expanded = isExpanded.obs;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: Obx(
              () => ExpansionTile(
            initiallyExpanded: isExpanded,
            onExpansionChanged: (value) => expanded.value = value,
            tilePadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            childrenPadding:
            const EdgeInsets.fromLTRB(16, 0, 16, 16),
            title: Text(
              title,
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF2D2D2D),
              ),
            ),
            trailing: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: expanded.value
                      ? AppColors.primaryColor
                      : const Color(0xFFE3E3E9),
                  width: 1.5,
                ),
              ),
              child: Icon(
                expanded.value ? Icons.remove : Icons.add,
                size: 16,
                color: expanded.value
                    ? AppColors.primaryColor
                    : const Color(0xFFE3E3E9),
              ),
            ),
            children: [
              if (content.isNotEmpty)
                Text(
                  content,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    color: const Color(0xFF636F85),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
