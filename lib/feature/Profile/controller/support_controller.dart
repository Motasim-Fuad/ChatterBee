import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/config/translations/language_controller.dart';

import 'package:chatter_bee/services/api_client.dart';
import 'package:get/get.dart';

class FaqItem {
  final int id;
  final String title;
  final String content;

  FaqItem({required this.id, required this.title, required this.content});

  // Parse from translations.{lang} — falls back to 'en' if lang missing
  factory FaqItem.fromJson(Map<String, dynamic> json, String lang) {
    final translations = json['translations'] as Map<String, dynamic>? ?? {};
    final langData = (translations[lang] ?? translations['en']) as Map<String, dynamic>? ?? {};

    return FaqItem(
      id:      json['id'] ?? 0,
      title:   langData['title']   ?? '',
      content: langData['content'] ?? '',
    );
  }
}

class SupportController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  final RxList<FaqItem> faqList     = <FaqItem>[].obs;
  final RxBool isLoading            = false.obs;
  final RxString errorMessage       = ''.obs;
  final RxString title = "Need Help? We're Here for You.".obs;
  final RxString description = ''.obs;
  final RxString supportEmail = 'support@chatterbeeapp.com'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSupport();

    ever(LanguageController.to.currentLocale, (_) => fetchSupport());
  }

  Future<void> fetchSupport() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final response = await _apiClient.get<Map<String, dynamic>>(AppUrl.support);
      if (response.isSuccess && response.data != null) {
        final data = response.data!['data'] ?? response.data!;
        title.value = data['title'] ?? title.value;
        description.value = data['description'] ?? '';
        supportEmail.value = data['support_email'] ?? supportEmail.value;
      } else {
        errorMessage.value = response.message;
      }
    } catch (_) {
      errorMessage.value = 'Unable to load support information.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchFaqs() async {
    try {
      isLoading.value   = true;
      errorMessage.value = '';

      final String lang = LanguageController.to.currentLocale.value.languageCode;
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/settings/faq/?lang=$lang',
      );

      if (response.isSuccess && response.data != null) {
        final List<dynamic> data = response.data!['data'] ?? [];

        faqList.value = data
            .map((item) => FaqItem.fromJson(item as Map<String, dynamic>, lang))
            .toList();

      } else {
        errorMessage.value = response.message;
      }
    } catch (e) {
      errorMessage.value = 'error'.tr;
    } finally {
      isLoading.value = false;
    }
  }
}
