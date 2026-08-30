import 'dart:ui';
import 'package:chatter_bee/config/app_colors.dart';
import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:chatter_bee/feature/Notification/notification_screen.dart';
import 'package:chatter_bee/feature/home_screen/caregiver/view/caregiver_home_screen.dart';
import 'package:chatter_bee/feature/home_screen/communicator/view/communicator_home_screen.dart';
import 'package:chatter_bee/services/storage/data_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NavigationController extends GetxController {
  final selectedIndex = 0.obs;

  void changeTab(int index) {
    selectedIndex.value = index;
  }
}

class NavigationScreen extends GetView<NavigationController> {
  const NavigationScreen({super.key});

  bool get _isCommunicator =>
      StorageService().getUserRole()?.trim().toLowerCase() == 'communicator';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Obx(() => IndexedStack(
            index: controller.selectedIndex.value,
            children: [
              _isCommunicator
                  ? const CommunicatorHomeScreen()
                  : const CaregiverHomeScreen(),
              const NotificationScreen(),
            ],
          )),

          Positioned(
            bottom: 30,
            left: screenWidth > 400 ? 80 : 16,
            right: screenWidth > 400 ? 80 : 16,
            child: Obx(() => _buildFloatingNavigationBar(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingNavigationBar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 10,
        vertical: isSmallScreen ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(55),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildNavItem(
              context: context,
              selectedIconPath: ImagesLink.home,
              unselectedIconPath: ImagesLink.homeGrey,
              label: 'Home',
              index: 0,
              isSelected: controller.selectedIndex.value == 0,
            ),
          ),
          Expanded(
            child: _buildNavItem(
              context: context,
              selectedIconPath: ImagesLink.notification,
              unselectedIconPath: ImagesLink.notificationGrey,
              label: 'Notification',
              index: 1,
              isSelected: controller.selectedIndex.value == 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required String selectedIconPath,
    required String unselectedIconPath,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final isTinyScreen = screenWidth < 350;

    return GestureDetector(
      onTap: () => controller.changeTab(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 8 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 26,
              height: 26,
              child: SvgPicture.asset(
                isSelected ? selectedIconPath : unselectedIconPath,
                fit: BoxFit.contain,
              ),
            ),
            if (isSelected && !isTinyScreen) ...[
              SizedBox(width: isSmallScreen ? 6 : 10),
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.nunito(
                    color: const Color(0xFF243C4D),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
