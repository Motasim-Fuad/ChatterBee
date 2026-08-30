import 'package:chatter_bee/config/app_colors.dart';
import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:chatter_bee/routes/app_routes.dart';
import 'package:chatter_bee/services/storage/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SecureStorageService _secureStorage = SecureStorageService();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));

    try {
      final token = await _secureStorage.getAccessToken();
      final role = await _secureStorage.getUserRole();

      if (token != null && token.isNotEmpty) {
        if (role == "caregiver") {
          Get.offAllNamed(AppRoutes.NAVIGATIONBAR);
        } else if (role == "communicator") {
          Get.offAllNamed(AppRoutes.COMMUNICATORHOMESCREEN);
        } else {
          Get.offAllNamed(AppRoutes.SIGNINSCREEN);
        }
      } else {
        Get.offAllNamed(AppRoutes.SIGNINSCREEN);
      }
    } catch (e) {
      print('Error checking auth: $e');
      Get.offAllNamed(AppRoutes.SIGNINSCREEN);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBgColor,
      body: Center(
        child: Image.asset(ImagesLink.splashLogo, height: 140),
      ),
    );
  }
}
