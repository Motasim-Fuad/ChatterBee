import 'package:chatter_bee/config/app_colors.dart';
import 'package:chatter_bee/feature/Profile/controller/pro_status_controller.dart';
import 'package:chatter_bee/feature/Profile/view/pro_feature_popup.dart'; // path ঠিক করে নিন
import 'package:chatter_bee/services/revenueCat_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionController extends GetxController {
  final selectedPlan = 'monthly'.obs;
  final isLoading = false.obs;

  // Read Pro status from the global controller
  bool get isProUser => ProStatusController.to.isProUser.value;

  Package? _monthlyPackage;
  Package? _annuallyPackage;

  // Prices
  String get monthlyPrice =>
      _monthlyPackage?.storeProduct.priceString ?? '\$2.99';

  String get annuallyPrice =>
      _annuallyPackage?.storeProduct.priceString ?? '\$29.99';

  // Trial texts
  String get monthlyTrialText {
    final days =
        _monthlyPackage?.storeProduct.introductoryPrice?.periodNumberOfUnits;
    return days != null ? '$days-day free trial' : '3-day free trial';
  }

  String get annuallyTrialText {
    final days =
        _annuallyPackage?.storeProduct.introductoryPrice?.periodNumberOfUnits;
    return days != null ? '$days-week free trial' : '1-week free trial';
  }

  bool isPlanSelected(String plan) => selectedPlan.value == plan;
  void selectPlan(String plan) => selectedPlan.value = plan;

  Package? get selectedPackage =>
      selectedPlan.value == 'monthly' ? _monthlyPackage : _annuallyPackage;

  // Plan card tap -> select plan + show popup
  void onPlanTapped(String plan) {
    if (isProUser) {
      Get.snackbar('Already Pro', 'You have an active subscription.',
          snackPosition: SnackPosition.TOP);
      return;
    }
    selectPlan(plan);
    Get.dialog(
      const ProFeaturePopup(),
      barrierColor: Colors.black54,
    );
  }

  @override
  void onInit() {
    super.onInit();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    isLoading.value = true;
    try {
      final list = await RevenueCatService.instance.getOfferings();

      for (final pkg in list) {
        if (pkg.packageType == PackageType.monthly) {
          _monthlyPackage = pkg;
          debugPrint('[RC] Monthly: ${pkg.storeProduct.priceString}');
        }
        if (pkg.packageType == PackageType.annual) {
          _annuallyPackage = pkg;
          debugPrint('[RC] Annual: ${pkg.storeProduct.priceString}');
        }
      }

      if (_monthlyPackage == null && _annuallyPackage == null) {
        debugPrint('[RC] No packages found!');
      }
    } catch (e) {
      debugPrint('[RC] _loadOfferings error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Called from popup's "Unlock with ChatterBee Pro"
  void onContinuePressed() {
    if (isProUser) {
      Get.snackbar('Already Pro', 'You have an active subscription.',
          snackPosition: SnackPosition.TOP);
      return;
    }

    final pkg = selectedPackage;
    if (pkg == null) {
      Get.snackbar('Error', 'Product not found. Please try again.',
          snackPosition: SnackPosition.TOP);
      return;
    }

    _purchase(pkg);
  }

  Future<void> _purchase(Package package) async {
    isLoading.value = true;
    try {
      final success = await RevenueCatService.instance.purchase(package);
      if (success) {
        ProStatusController.to.isProUser.value = true;
        _showSuccessSheet();
      } else {
        Get.snackbar('Cancelled', 'Purchase was cancelled.',
            snackPosition: SnackPosition.TOP);
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Restore
  Future<void> restorePurchases() async {
    isLoading.value = true;
    try {
      final restored = await RevenueCatService.instance.restorePurchases();
      if (restored) {
        ProStatusController.to.isProUser.value = true;
        Get.snackbar('Restored!', 'Your subscription has been restored.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green.shade100);
      } else {
        Get.snackbar('Not found', 'No active subscription to restore.',
            snackPosition: SnackPosition.TOP);
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Show Success Sheet
  void _showSuccessSheet() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: Color(0xFFFFC107),
                    size: 44,
                  ),
                ),
                const SizedBox(height: 20),
                Text('payment_success'.tr,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.black)),
                const SizedBox(height: 10),
                Text('payment_success_desc'.tr,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                        fontSize: 14, color: Colors.grey[600], height: 1.5)),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('done'.tr,
                        style: GoogleFonts.nunito(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
    );
  }
}