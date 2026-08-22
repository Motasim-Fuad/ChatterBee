import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/config/translations/language_controller.dart';
import 'package:chatter_bee/services/api_client.dart';
import 'package:chatter_bee/utils/logger_utils.dart';
import 'package:get/get.dart';

class PrivacyPolicyController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  final RxBool isLoading = false.obs;
  final RxString policyTitle = ''.obs;
  final RxString policyContent = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPrivacyPolicy();

    ever(LanguageController.to.currentLocale, (_) => fetchPrivacyPolicy());
  }

  Future<void> fetchPrivacyPolicy() async {
    try {
      isLoading.value = true;
      LoggerUtils.logInfo('=== GET PRIVACY POLICY ===');

      final String lang = LanguageController.to.currentLocale.value.languageCode;
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${AppUrl.privacyPolicy}?lang=$lang',
      );

      if (response.isSuccess && response.data != null) {
        final data = response.data!['data'] ?? response.data!;

        final translations = data?['translations'] as Map<String, dynamic>?;
        final localized = translations?[lang] ?? translations?['en'];
        final langData = localized is Map ? Map<String, dynamic>.from(localized) : <String, dynamic>{};
        policyTitle.value = data?['title'] ?? langData['title'] ?? 'Privacy Policy';
        policyContent.value = data?['content'] ?? langData['content'] ?? '';

        LoggerUtils.logSuccess('Privacy policy fetched successfully [$lang]');
      } else {
        LoggerUtils.logError('Privacy policy fetch failed: ${response.message}');
        Get.snackbar(
          'error'.tr, 'failed_load_privacy'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      LoggerUtils.logError('Privacy policy error: $e');
      Get.snackbar(
        'error'.tr, 'profile_update_failed'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
