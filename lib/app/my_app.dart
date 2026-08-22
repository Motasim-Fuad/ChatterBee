import 'package:chatter_bee/config/translations/app_translations.dart';
import 'package:chatter_bee/config/translations/language_controller.dart';
import 'package:chatter_bee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final langController = Get.put(LanguageController());

    return Obx(() => GetMaterialApp(
      debugShowCheckedModeBanner: false,

      translations: AppTranslations(),
      locale: langController.currentLocale.value,
      fallbackLocale: const Locale('en', 'US'),

      builder: (context, child) {
        return Directionality(
          textDirection: langController.isRTL()
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: child!,
        );
      },

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF5E6F3)),
        useMaterial3: true,
      ),
      getPages: routes,
      initialRoute: AppRoutes.SPLASHSCREEN,
    ));
  }
}
