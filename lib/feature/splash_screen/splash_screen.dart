import 'package:chatter_bee/config/app_colors.dart';
import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:chatter_bee/routes/app_routes.dart';
import 'package:chatter_bee/services/storage/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    // Wait for 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    try {
      // Get token from secure storage
      final token = await _secureStorage.getAccessToken();

      // Get role from secure storage
      final role = await _secureStorage.getUserRole();

      // Get login status from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

      if (token != null && token.isNotEmpty && isLoggedIn) {
        // ✅ Token exists → Navigate based on role

        if (role == "caregiver") {
          Get.offAllNamed(AppRoutes.NAVIGATIONBAR);
        }
        else if (role == "communicator") {
          Get.offAllNamed(AppRoutes.COMMUNICATORHOMESCREEN);
        }
        else {
          // Unknown or missing role → sign in
          Get.offAllNamed(AppRoutes.SIGNINSCREEN);
        }

      } else {
        // ❌ No token → Sign In
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