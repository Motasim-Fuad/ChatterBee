import 'package:chatter_bee/config/translations/language_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = LanguageController.to;

    return Scaffold(
      appBar: AppBar(title: const Text('Language')),
      body: Obx(() {
        final currentValue =
            '${controller.currentLocale.value.languageCode}_${controller.currentLocale.value.countryCode}';

        return ListView(
          children: controller.supportedLanguages.map((lang) {
            final localeValue = '${lang['code']}_${lang['country']}';
            final isSelected = currentValue == localeValue;

            return ListTile(
              leading: Text(lang['flag']!, style: const TextStyle(fontSize: 28)),
              title: Text(lang['name']!),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: Colors.purple)
                  : (!controller.isPro && lang['code'] != 'en')
                  ? const Icon(Icons.lock, color: Colors.grey)
                  : null,
              tileColor: isSelected ? Colors.purple.withOpacity(0.1) : null,
              onTap: () {
                controller.changeLanguage(lang['code']!);
                Get.back();
              },
            );
          }).toList(),
        );
      }),
    );
  }
}
