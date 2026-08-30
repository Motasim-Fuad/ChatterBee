import 'dart:io';
import 'package:chatter_bee/Repository/activity/activity_repository.dart';
import 'package:chatter_bee/models/activity/activity_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EditActivityController extends GetxController {
  final ActivityRepository _repository = ActivityRepository();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController activityNameController = TextEditingController();

  late ActivityModel _original;

  final RxString selectedTime = ''.obs;
  final RxString selectedImagePath = ''.obs;
  final RxString existingImageUrl = ''.obs;
  final RxBool isSaving = false.obs;
  final RxString selectedStatus = 'in_progress'.obs;

  TimeOfDay? _pickedTime;

  final List<Map<String, String>> statusOptions = [
    {'value': 'in_progress', 'labelKey': 'status_in_progress'},
    {'value': 'done',        'labelKey': 'status_done'},
    {'value': 'hold',        'labelKey': 'status_hold'},
  ];

  @override
  void onInit() {
    super.onInit();
    _original = Get.arguments as ActivityModel;
    _prefill();
  }

  void _prefill() {
    activityNameController.text = _original.activityName;
    selectedStatus.value = _original.status ?? 'in_progress';
    existingImageUrl.value = _original.imageIcon ?? '';

    try {
      final dt = DateTime.parse(_original.datetime).toLocal();
      _pickedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
      selectedTime.value = _formatTime(_pickedTime!);
    } catch (_) {
      final now = TimeOfDay.now();
      _pickedTime = now;
      selectedTime.value = _formatTime(now);
    }
  }

  Future<void> selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _pickedTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFFDD268),
            onPrimary: Colors.black87,
            surface: Colors.white,
            onSurface: Colors.black87,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      _pickedTime = picked;
      selectedTime.value = _formatTime(picked);
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour =
    hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  String _buildDatetimeString() {
    final now = DateTime.now();
    final hour = _pickedTime?.hour ?? now.hour;
    final minute = _pickedTime?.minute ?? now.minute;
    return DateTime(now.year, now.month, now.day, hour, minute, 0)
        .toUtc()
        .toIso8601String();
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      if (image != null) {
        selectedImagePath.value = image.path;
        existingImageUrl.value = '';
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr, 'failed_pick_image_activity'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void selectStatus(String value) => selectedStatus.value = value;

  Future<void> saveActivity() async {
    final name = activityNameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar(
        'missing_field'.tr, 'activity_name_required'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    isSaving.value = true;
    final response = await _repository.updateActivity(
      activityId: _original.id,
      activityName: name,
      datetime: _buildDatetimeString(),
      status: selectedStatus.value,
      imageFile: selectedImagePath.value.isNotEmpty
          ? File(selectedImagePath.value)
          : null,
    );
    isSaving.value = false;

    if (response.isSuccess && response.data != null) {
      Get.back(result: response.data);
    } else {
      Get.snackbar(
        'error'.tr, response.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  @override
  void onClose() {
    activityNameController.dispose();
    super.onClose();
  }
}
