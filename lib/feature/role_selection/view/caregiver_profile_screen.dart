import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatter_bee/config/app_colors.dart';
import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:chatter_bee/feature/invitations/controller/caregiver_invitation_controller.dart';
import 'package:chatter_bee/feature/role_selection/controller/caregiver_profile_controller.dart';
import 'package:chatter_bee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CaregiverProfileScreen extends GetView<CaregiverProfileController> {
  const CaregiverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CaregiverInvitationController>()) {
      Get.put(CaregiverInvitationController());
    }
    final invCtrl = Get.find<CaregiverInvitationController>();

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('profile_setup'.tr,
            style: GoogleFonts.nunito(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600)),
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
                      Obx(() => Container(
                        width: 85,
                        height: 85,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                          image: controller.profileImage.value != null
                              ? DecorationImage(
                              image: FileImage(controller.profileImage.value!),
                              fit: BoxFit.cover)
                              : null,
                        ),
                        child: controller.profileImage.value == null
                            ? const Icon(Icons.person, size: 50, color: Colors.white)
                            : null,
                      )),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: controller.pickImage,
                          child: SvgPicture.asset(ImagesLink.cameraIcon),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                Text('full_name'.tr,
                    style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
                const SizedBox(height: 6),
                SizedBox(
                  height: 48,
                  child: TextField(
                    controller: controller.fullNameController,
                    decoration: InputDecoration(
                      hintText: 'enter_full_name'.tr,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SvgPicture.asset(ImagesLink.parsonIcon, width: 20, height: 20),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFFC857), width: 1)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),


                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('buddy_bee_mode'.tr, style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w600)),
                    Obx(() => CustomSwitch(
                      value: controller.isBuddyBeeMode.value,
                      onChanged: (val) => controller.toggleBuddyBeeMode(val),
                    )),
                  ],
                ),
                Text('buddy_bee_desc'.tr,
                    style: GoogleFonts.nunito(fontSize: 14, color: const Color(0xFF636F85))),
                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.CAREGIVER_CONNECTIONS),
                  child: Row(
                    children: [
                      Text('linked_accounts'.tr, style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      Text('( Communicator )', style: GoogleFonts.nunito(fontSize: 14, color: const Color(0xFF636F85))),
                      const Spacer(),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                Obx(() {
                  if (invCtrl.isLoadingConnections.value) {
                    return const SizedBox(
                      height: 90,
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    );
                  }

                  if (invCtrl.connections.isEmpty) {
                    return GestureDetector(
                      onTap: () {
                        if (controller.canAddCommunicator(invCtrl.connections.length)) {
                          invCtrl.showInviteDialog();
                        }
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(88, 88),
                            painter: DashedCirclePainter(
                                color: const Color(0xFFB5CFD1),
                                strokeWidth: 2,
                                dashWidth: 8,
                                dashSpace: 4),
                          ),
                          Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.transparent)),
                            child: const Icon(Icons.add, color: Colors.grey, size: 28),
                          ),
                        ],
                      ),
                    );
                  }

                  return SizedBox(
                    height: 90,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: invCtrl.connections.length + 1,
                      itemBuilder: (context, index) {
                        if (index == invCtrl.connections.length) {
                          return GestureDetector(
                            onTap: () {
                              if (controller.canAddCommunicator(invCtrl.connections.length)) {
                                invCtrl.showInviteDialog();
                              }
                            },
                            child: Container(
                              width: 80, height: 80,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: const Icon(Icons.add, color: Colors.grey),
                            ),
                          );
                        }

                        final connection = invCtrl.connections[index];
                        return Obx(() {
                          final isSelected = invCtrl.selectedConnectionId.value == connection.id;
                          final isSwitching = invCtrl.isSwitchingTo.value == connection.id;

                          return GestureDetector(
                            onTap: isSwitching ? null : () => invCtrl.selectCommunicator(connection),
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CustomPaint(
                                    size: const Size(88, 88),
                                    painter: DashedCirclePainter(
                                      color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFFB5CFD1),
                                      strokeWidth: isSelected ? 3 : 2,
                                      dashWidth: 8,
                                      dashSpace: 4,
                                    ),
                                  ),
                                  if (isSwitching)
                                    const SizedBox(
                                      width: 80, height: 80,
                                      child: Center(child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Color(0xFF4CAF50))),
                                    )
                                  else
                                    CircleAvatar(
                                      radius: 40,
                                      backgroundColor: isSelected
                                          ? const Color(0xFFE8F5E9)
                                          : Colors.grey[200],
                                      backgroundImage: _hasValidUrl(connection.communicatorAvatar)
                                          ?CachedNetworkImageProvider("${AppUrl.baseUrl}${connection.communicatorAvatar}")
                                          : null,
                                      child: !_hasValidUrl(connection.communicatorAvatar)
                                          ? Text(
                                          connection.communicatorName.isNotEmpty
                                              ? connection.communicatorName[0].toUpperCase()
                                              : '?',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: isSelected
                                                  ? const Color(0xFF4CAF50)
                                                  : Colors.grey[500]))
                                          : null,
                                    ),
                                ],
                              ),
                            ),
                          );
                        });
                      },
                    ),
                  );
                }),
                const SizedBox(height: 20),

                if (false) ...[
                Text('voice_type'.tr, style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, childAspectRatio: 2.5, crossAxisSpacing: 12, mainAxisSpacing: 12),
                  itemCount: controller.voiceTypes.length,
                  itemBuilder: (context, index) {
                    final voiceType = controller.voiceTypes[index];
                    return Obx(() {
                      final isSelected = controller.selectedVoiceType.value == voiceType['key'];
                      return GestureDetector(
                        onTap: () => controller.selectVoiceType(voiceType['key']),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSelected ? AppColors.primaryColor : Colors.grey[300]!),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(voiceType['icon'], width: 20, height: 20,
                                  colorFilter: ColorFilter.mode(
                                      isSelected ? AppColors.primaryColor : Colors.black,
                                      BlendMode.srcIn)),
                              const SizedBox(width: 8),
                              Flexible(child: Text(voiceType['type'].toString().tr,
                                  style: TextStyle(
                                      color: isSelected ? AppColors.primaryColor : Colors.black,
                                      fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        ),
                      );
                    });
                  },
                ),

                Center(
                  child: TextButton.icon(
                    onPressed: () => Get.snackbar('Preview', 'Voice preview would play here',
                        snackPosition: SnackPosition.TOP),
                    icon: SvgPicture.asset(ImagesLink.voiceIcon),
                    label: Text('preview_voice'.tr,
                        style: GoogleFonts.nunito(
                            color: AppColors.primaryColor, fontWeight: FontWeight.w700, fontSize: 18)),
                  ),
                ),
                Center(
                  child: TextButton.icon(
                    onPressed: () => Get.snackbar('Upload', 'Voice upload functionality',
                        snackPosition: SnackPosition.BOTTOM),
                    icon: SvgPicture.asset(ImagesLink.voiceMic),
                    label: Text('upload_voice'.tr,
                        style: GoogleFonts.nunito(
                            color: const Color(0xFFb5cfd1), fontWeight: FontWeight.w700, fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 30),
                ],

                Obx(() => SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: controller.isSaving.value ? null : controller.onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: controller.isSaving.value
                        ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.black)))
                        : Text('continue_btn'.tr,
                        style: GoogleFonts.nunito(
                            color: Colors.black, fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                )),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }),
    );
  }

  // Returns true when the avatar URL is usable
  bool _hasValidUrl(String? url) {
    return url != null && url.isNotEmpty && Uri.tryParse(url)?.hasAbsolutePath == true;
  }
}

class CustomSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const CustomSwitch({Key? key, required this.value, required this.onChanged}) : super(key: key);
  @override
  State<CustomSwitch> createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
        value: widget.value ? 1.0 : 0.0);
    _animation = _controller.drive(CurveTween(curve: Curves.easeInOut));
  }
  @override
  void didUpdateWidget(covariant CustomSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.value ? _controller.forward() : _controller.reverse();
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) => Container(
          width: 40, height: 22,
          padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 3),
          decoration: BoxDecoration(
            color: widget.value ? AppColors.primaryColor : Colors.grey[300],
            borderRadius: BorderRadius.circular(18),
          ),
          child: Stack(children: [
            Align(
              alignment: Alignment.lerp(
                  Alignment.centerLeft, Alignment.centerRight, _animation.value)!,
              child: Container(
                width: 20, height: 22,
                decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(1, 2))
                    ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  DashedCirclePainter(
      {required this.color,
        required this.strokeWidth,
        required this.dashWidth,
        required this.dashSpace});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final circumference = 2 * 3.14159 * radius;
    final dashCount = (circumference / (dashWidth + dashSpace)).floor();
    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          i * (dashWidth + dashSpace) / radius,
          dashWidth / radius,
          false,
          paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
