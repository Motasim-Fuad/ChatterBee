// import 'package:chatter_bee/config/translations/language_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// class LanguageSelector extends StatelessWidget {
//   const LanguageSelector({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = LanguageController.to;
//
//     return Obx(() => DropdownButton<String>(
//       value: '${controller.currentLocale.value.languageCode}_${controller.currentLocale.value.countryCode}',
//       underline: const SizedBox(),
//       items: controller.supportedLanguages.map((lang) {
//         return DropdownMenuItem<String>(
//           value: lang['locale'],
//           child: Row(
//             children: [
//               Text(lang['flag']!, style: const TextStyle(fontSize: 20)),
//               const SizedBox(width: 8),
//               Text(lang['name']!),
//             ],
//           ),
//         );
//       }).toList(),
//       onChanged: (value) {
//         if (value != null) controller.changeLanguage(value);
//       },
//     ));
//   }
// }

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
        // ✅ current value: 'en_US' format
        final currentValue =
            '${controller.currentLocale.value.languageCode}_${controller.currentLocale.value.countryCode}';

        return ListView(
          children: controller.supportedLanguages.map((lang) {
            // Build locale from code + country
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