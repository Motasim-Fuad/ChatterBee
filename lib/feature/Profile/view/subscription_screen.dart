import 'package:chatter_bee/config/app_colors.dart';
import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:chatter_bee/feature/Profile/controller/pro_status_controller.dart';
import 'package:chatter_bee/feature/Profile/controller/subscription_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class SubscriptionScreen extends GetView<SubscriptionController> {
  const SubscriptionScreen({super.key});

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
          'subscription'.tr,
          style: GoogleFonts.nunito(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Image.asset(ImagesLink.logo, height: 36, fit: BoxFit.contain),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFFC107)),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (ProStatusController.to.isProUser.value)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border:
                    Border.all(color: const Color(0xFFFFC107), width: 1.2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.workspace_premium_rounded,
                          color: Color(0xFFFFC107)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'You have an active Pro subscription',
                          style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w600,
                              color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),

              Text(
                'unlock_pro'.tr,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
              ),
              const SizedBox(height: 6),
              Text(
                'unlock_pro_desc'.tr,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                    fontSize: 14, color: Colors.black, height: 1.5),
              ),
              const SizedBox(height: 24),

              // Free plan card
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'ChatterBee Basic (Free)',
                            style: GoogleFonts.nunito(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade600),
                          ),
                        ),
                        Text(
                          '\$0',
                          style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...[
                      'free_feature_1'.tr,
                    ].map(
                          (f) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          f,
                          style: GoogleFonts.nunito(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                              height: 1.4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              _buildPlanCard(
                planType: 'monthly',
                title: 'ChatterBee Pro (Monthly)',
                price: controller.monthlyPrice,
                period: '/ month',
                trialText: controller.monthlyTrialText,
                features: [
                  'pro_feature_1'.tr,
                  'pro_feature_2'.tr,
                  'pro_feature_3'.tr,
                  'pro_feature_4'.tr,
                  'pro_feature_5'.tr,
                ],
              ),
              const SizedBox(height: 20),

              Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildPlanCard(
                    planType: 'annually',
                    title: 'ChatterBee Pro (Annual)',
                    price: controller.annuallyPrice,
                    period: '/ year',
                    trialText: controller.annuallyTrialText,
                    features: [
                      'pro_annual_includes'.tr,
                    ],
                  ),
                  Positioned(
                    top: -10,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC107),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Best Value',
                        style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: controller.restorePurchases,
                child: Text(
                  'Restore purchases',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: Colors.grey[600],
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Platform.isIOS
                    ? Text(
                  'Payment will be charged to your Apple ID account at confirmation of purchase. '
                      'Subscription automatically renews unless canceled at least 24 hours before '
                      'the end of the current period. You can manage or cancel your subscription in '
                      'your App Store account settings.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: Colors.grey[500],
                    height: 1.5,
                  ),
                )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => launchUrl(
                      Uri.parse('https://chatterbeeapp.com/sample-page/'),
                      mode: LaunchMode.externalApplication,
                    ),
                    child: Text(
                      'Terms of Use',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: const Color(0xFFFFC107),
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    ' |  ',
                    style: GoogleFonts.nunito(
                        fontSize: 12, color: Colors.grey[400]),
                  ),
                  GestureDetector(
                    onTap: () => launchUrl(
                      Uri.parse('https://chatterbeeapp.com/privacy-policy/'),
                      mode: LaunchMode.externalApplication,
                    ),
                    child: Text(
                      'Privacy Policy',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: const Color(0xFFFFC107),
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        );
      }),
    );
  }

  // Build Plan Card
  Widget _buildPlanCard({
    required String planType,
    required String title,
    required String price,
    required String period,
    required String trialText,
    required List<String> features,
  }) {
    return Obx(() {
      final isSelected = controller.isPlanSelected(planType);
      return GestureDetector(
        onTap: () => controller.onPlanTapped(planType),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
              isSelected ? const Color(0xFFFFC107) : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: const Color(0xFFFFC107).withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ]
                : [],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFFFC107)
                              : Colors.grey[400]!,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFFFC107)),
                        ),
                      )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.nunito(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.black),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: Colors.green.shade300, width: 1),
                          ),
                          child: Text(
                            trialText,
                            style: GoogleFonts.nunito(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        price,
                        style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black),
                      ),
                      Text(
                        period,
                        style: GoogleFonts.nunito(
                            fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...features.map(
                    (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset(ImagesLink.check),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          f,
                          style: GoogleFonts.nunito(
                              fontSize: 13,
                              color: Colors.black87,
                              height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}