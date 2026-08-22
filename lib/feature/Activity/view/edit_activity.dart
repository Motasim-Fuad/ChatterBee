import 'package:chatter_bee/config/app_colors.dart';
import 'package:chatter_bee/feature/Activity/widget/activity_form_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/edit_activity_controller.dart';


class EditActivityScreen extends GetView<EditActivityController> {
  const EditActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'edit_activity'.tr,
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: SafeArea(
        child: ActivityForm(
          nameController: controller.activityNameController,
          selectedTime: controller.selectedTime,
          selectedImagePath: controller.selectedImagePath,
          existingImageUrl: controller.existingImageUrl,
          selectedStatus: controller.selectedStatus,
          isSaving: controller.isSaving,
          onSelectTime: () => controller.selectTime(context),
          onPickImage: controller.pickImage,
          onStatusChanged: controller.selectStatus,
          onSave: controller.saveActivity,
          saveButtonLabel: 'save'.tr,
          statusOptions: controller.statusOptions,
        ),
      ),
    );
  }
}
