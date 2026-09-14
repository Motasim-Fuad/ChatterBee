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
        policyTitle.value = (data?['title'] ??
                langData['title'] ??
                data?['heading'] ??
                'Privacy Policy')
            .toString();
        final content = data?['content'] ??
            langData['content'] ??
            data?['body'] ??
            data?['text'] ??
            data?['privacy_policy'] ??
            langData['body'] ??
            '';
        policyContent.value = content.toString();
        if (policyContent.value.trim().isEmpty) {
          _useFallbackPolicy();
        }

        LoggerUtils.logSuccess('Privacy policy fetched successfully [$lang]');
      } else {
        LoggerUtils.logError('Privacy policy fetch failed: ${response.message}');
        _useFallbackPolicy();
      }
    } catch (e) {
      LoggerUtils.logError('Privacy policy error: $e');
      _useFallbackPolicy();
    } finally {
      isLoading.value = false;
    }
  }

  void _useFallbackPolicy() {
    policyTitle.value = 'Privacy Policy';
    policyContent.value = '''
ChatterBee respects your privacy and is committed to protecting the personal information you share with us.

Information we collect
We collect the information you provide when you create an account, such as your name, email address, and profile details, as well as content you add in the app to support communication.

How we use information
We use this information to provide and improve ChatterBee, personalize the experience, sync linked caregiver and communicator accounts, and send important service communications.

Sharing
We do not sell your personal information. We may share data with service providers who help us operate the app, and when required by law.

Your choices
You can update profile information in Settings and request account deletion from a caregiver account.

Contact
If you have questions about this policy, email support@chatterbeeapp.com.
''';
  }
}
