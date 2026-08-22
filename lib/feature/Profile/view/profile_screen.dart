import 'package:chatter_bee/config/app_colors.dart';
import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:chatter_bee/config/translations/widgets/language_selector.dart';
import 'package:chatter_bee/feature/Profile/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'profile_setup'.tr,
          style: GoogleFonts.nunito(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Image.asset(ImagesLink.logo, height: 50),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    children: [
                      Obx(() {
                        final hasAvatar = controller.avatarUrl.value.isNotEmpty;
                        return Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                            image: hasAvatar
                                ? DecorationImage(
                              image: CachedNetworkImageProvider(controller.avatarUrl.value),
                              fit: BoxFit.cover,
                            )
                                : null,
                          ),
                          child: !hasAvatar
                              ? Icon(Icons.person, size: 50, color: Colors.grey[400])
                              : null,
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                _buildSubscription(context),
                const SizedBox(height: 16),

                if (controller.canSwitchUser) Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('switch_user'.tr,
                          style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black)),
                      const SizedBox(height: 12),
                      Obx(() => controller.switchableUsers.isEmpty
                          ? Text('No linked communicator accounts', style: GoogleFonts.nunito(color: Colors.grey[600]))
                          : Column(children: controller.switchableUsers.map((user) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildRoleCard(
                                icon: SvgPicture.asset(ImagesLink.simplificationCare),
                                title: (user['full_name'] ?? user['email'] ?? 'Communicator').toString(),
                                role: 'communicator',
                                isSelected: false,
                                onTap: () => controller.switchToUser(user),
                              ),
                            )).toList())),
                    ],
                  ),
                ),
                if (controller.canSwitchUser) const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('personal_information'.tr,
                              style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black)),
                          IconButton(
                            icon: SvgPicture.asset(ImagesLink.edit),
                            onPressed: controller.onEditPersonalInfo,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Obx(() => Column(
                        children: [
                          _buildInfoTile(
                            icon: SvgPicture.asset(ImagesLink.parsonIcon),
                            label: controller.userName.value.isEmpty ? '—' : controller.userName.value,
                          ),
                          const SizedBox(height: 8),
                          _buildInfoTile(
                            icon: SvgPicture.asset(ImagesLink.mailIcon),
                            label: controller.userEmail.value.isEmpty ? '—' : controller.userEmail.value,
                          ),
                          const SizedBox(height: 8),
                          _buildInfoTile(
                            icon: SvgPicture.asset(ImagesLink.child, color: const Color(0xFF211F2F)),
                            label: controller.userType.value.isEmpty ? '—' : controller.userType.value,
                          ),
                        ],
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('settings'.tr,
                          style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black)),
                      const SizedBox(height: 12),
                      _buildMenuTile(
                        icon: SvgPicture.asset(ImagesLink.clarityLanguage),
                        title: 'language'.tr,
                        onTap: () => Get.to(() => const LanguageSelector()),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                      const SizedBox(height: 8),
                      _buildMenuTile(
                        icon: SvgPicture.asset(ImagesLink.lockIcon),
                        title: 'change_password'.tr,
                        onTap: controller.onChangePasswordTap,
                        trailing: const Icon(Icons.chevron_right),
                      ),
                      const SizedBox(height: 8),
                      _buildMenuTile(
                        icon: SvgPicture.asset(ImagesLink.privacy),
                        title: 'privacy_policy'.tr,
                        onTap: controller.onPrivacyPolicyTap,
                        trailing: const Icon(Icons.chevron_right),
                      ),
                      const SizedBox(height: 8),
                      _buildMenuTile(
                        icon: SvgPicture.asset(ImagesLink.support),
                        title: 'support'.tr,
                        onTap: controller.onSupportTap,
                        trailing: const Icon(Icons.chevron_right),
                      ),
                      const SizedBox(height: 8),
                      _buildMenuTile(
                        icon: SvgPicture.asset(ImagesLink.logout),
                        title: 'logout'.tr,
                        onTap: controller.onLogoutTap,
                        textColor: Colors.red,
                      ),
                      const SizedBox(height: 8),
                      _buildMenuTile(
                        icon: SvgPicture.asset(ImagesLink.delete),
                        title: 'delete_account'.tr,
                        onTap: controller.onDeleteAccountTap,
                        textColor: Colors.red,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMenuTile({
    Widget? icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            if (icon != null) ...[SizedBox(width: 24, height: 24, child: icon), const SizedBox(width: 10)],
            Expanded(child: Text(title, style: GoogleFonts.nunito(fontSize: 16, color: textColor ?? Colors.black87))),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildSubscription(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: GestureDetector(
        onTap: controller.onSubscriptionTap,
        child: Row(
          children: [
            Expanded(child: Text('subscription'.tr,
                style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black))),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required Widget icon,
    required String title,
    required String role,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            SizedBox(width: 24, height: 24, child: icon),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w700))),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? Colors.black : Colors.grey[400]!, width: 2),
              ),
              child: isSelected
                  ? Center(child: Container(width: 12, height: 12,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black)))
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({required Widget icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          SizedBox(width: 24, height: 24, child: icon),
          const SizedBox(width: 10),
          Text(label, style: GoogleFonts.nunito(fontSize: 16, color: Colors.black87)),
        ],
      ),
    );
  }
}
