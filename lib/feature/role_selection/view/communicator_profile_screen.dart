import 'package:chatter_bee/config/app_colors.dart';
import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:chatter_bee/feature/role_selection/controller/communicator_profile_controller.dart';
import 'package:chatter_bee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CommunicatorProfileScreen extends GetView<CommunicatorProfileController> {
  const CommunicatorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  onTap: (){
                    Get.toNamed(AppRoutes.COMMUNICATOR_INVITATIONS);
                  },
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      color: AppColors.navColor,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('invitations'.tr,style: TextStyle(color: Colors.black,fontSize: 18),),
                            Icon(Icons.arrow_forward_ios),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text('profile_type'.tr, style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Obx(() {
                  final isChildSelected = controller.selectedProfileType.value == 'Child';
                  final isAdultSelected = controller.selectedProfileType.value == 'Adult';
                  return Row(
                    children: [
                      Expanded(child: GestureDetector(
                        onTap: () => controller.selectProfileType('child'.tr),
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: isChildSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isChildSelected ? AppColors.primaryColor : Colors.grey[300]!),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(ImagesLink.child, width: 28, height: 28,
                                  colorFilter: ColorFilter.mode(isChildSelected ? AppColors.primaryColor : Colors.black, BlendMode.srcIn)),
                              const SizedBox(height: 8),
                              Text('child'.tr, style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600,
                                  color: isChildSelected ? AppColors.primaryColor : Colors.black)),
                            ],
                          ),
                        ),
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: GestureDetector(
                        onTap: () => controller.selectProfileType('adult'.tr),
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: isAdultSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isAdultSelected ? AppColors.primaryColor : Colors.grey[300]!),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(ImagesLink.adult, width: 28, height: 28,
                                  colorFilter: ColorFilter.mode(isAdultSelected ? AppColors.primaryColor : Colors.black, BlendMode.srcIn)),
                              const SizedBox(height: 8),
                              Text('adult'.tr, style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600,
                                  color: isAdultSelected ? AppColors.primaryColor : Colors.black)),
                            ],
                          ),
                        ),
                      )),
                    ],
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
                                  colorFilter: ColorFilter.mode(isSelected ? AppColors.primaryColor : Colors.black, BlendMode.srcIn)),
                              const SizedBox(width: 8),
                              Flexible(child: Text(voiceType['type'].toString().tr,
                                  style: TextStyle(color: isSelected ? AppColors.primaryColor : Colors.black, fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        ),
                      );
                    });
                  },
                ),
                const SizedBox(height: 20),
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
                        ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.black)))
                        : Text('continue_btn'.tr,
                        style: GoogleFonts.nunito(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w700)),
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
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 200), value: widget.value ? 1.0 : 0.0);
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
              alignment: Alignment.lerp(Alignment.centerLeft, Alignment.centerRight, _animation.value)!,
              child: Container(width: 20, height: 22,
                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(1, 2))]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
