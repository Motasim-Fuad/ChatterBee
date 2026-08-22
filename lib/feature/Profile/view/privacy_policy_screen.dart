import 'package:chatter_bee/config/app_colors.dart';
import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:chatter_bee/feature/Profile/controller/privacy_policy_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends GetView<PrivacyPolicyController> {
  const PrivacyPolicyScreen({super.key});

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
          'privacy_policy_title'.tr,
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

        if (controller.policyContent.value.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'no_content_available'.tr,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    color: const Color(0xFF636F85),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: controller.fetchPrivacyPolicy,
                  icon: const Icon(Icons.refresh),
                  label: Text(
                    'retry'.tr,
                    style: GoogleFonts.nunito(color: AppColors.primaryColor),
                  ),
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
                if (controller.policyTitle.value.isNotEmpty) ...[
                  _buildSectionTitle(controller.policyTitle.value),
                  const SizedBox(height: 12),
                ],
                ..._buildContentParagraphs(controller.policyContent.value),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      }),
    );
  }

  List<Widget> _buildContentParagraphs(String content) {
    final readableContent = _htmlToReadableText(content);
    final paragraphs = readableContent
        .split('\n\n')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    if (paragraphs.isEmpty) return const <Widget>[];

    final List<Widget> widgets = [];
    for (int i = 0; i < paragraphs.length; i++) {
      widgets.add(_buildSectionContent(paragraphs[i]));
      if (i < paragraphs.length - 1) widgets.add(const SizedBox(height: 16));
    }
    return widgets;
  }

  String _htmlToReadableText(String html) {
    var text = html
        .replaceAll(RegExp(r'<\s*br\s*/?\s*>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</\s*(p|div|h[1-6]|li|ul|ol|section|article)\s*>',
            caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'<\s*li(?:\s[^>]*)?>', caseSensitive: false), '• ')
        .replaceAll(RegExp(r'<[^>]*>', multiLine: true), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");

    return text
        .replaceAll(RegExp(r'[ \t]+\n'), '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF2D2D2D),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: GoogleFonts.nunito(
        fontSize: 14,
        height: 1.6,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF2D2D2D),
      ),
      textAlign: TextAlign.justify,
    );
  }
}
