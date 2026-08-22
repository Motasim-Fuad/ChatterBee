import 'package:chatter_bee/Repository/activity/activity_repository.dart';
import 'package:chatter_bee/models/activity/activity_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ActivitiesController extends GetxController {
  final ActivityRepository _repository = ActivityRepository();

  final RxList<ActivityModel> activities = <ActivityModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isDeleting = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchActivities();
  }

  // Fetch
  Future<void> fetchActivities() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await _repository.getActivities(days: 30, limit: 100);
      if (response.isSuccess && response.data != null) {
        activities.value = response.data!;
        _sortActivities();
      } else {
        errorMessage.value = response.message;
      }
    } catch (e) {
      errorMessage.value = 'profile_update_failed'.tr;
    } finally {
      isLoading.value = false;
    }
  }

  // Today's Activities
  List<ActivityModel> get todayActivities {
    final now = DateTime.now();
    return activities.where((a) {
      try {
        final dt = DateTime.parse(a.datetime).toLocal();
        return dt.year == now.year &&
            dt.month == now.month &&
            dt.day == now.day;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  // Add Optimistic
  void onActivityAdded(ActivityModel activity) {
    activities.add(activity);

    _sortActivities();
  }

  // Update Optimistic
  void onActivityUpdated(ActivityModel updated) {
    final idx = activities.indexWhere((a) => a.id == updated.id);
    if (idx != -1) {
      activities[idx] = updated;
      _sortActivities();
    }
  }

  // Go To Add
  Future<void> goToAddActivity() async {
    final result = await Get.toNamed('/add-activity');
    if (result != null && result is ActivityModel) {
      onActivityAdded(result);
      Get.snackbar(
        'success'.tr,
        '${result.activityName} ${'activity_added'.tr}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        duration: const Duration(seconds: 2),
      );
    } else if (result == null) {
      fetchActivities();
    }
  }

  // Go To Edit
  Future<void> goToEditActivity(ActivityModel activity) async {
    final result = await Get.toNamed(
      '/edit-activity',
      arguments: activity,
    );
    if (result != null && result is ActivityModel) {
      onActivityUpdated(result);
      Get.snackbar(
        'success'.tr,
        '${result.activityName} ${'activity_updated'.tr}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // Delete
  Future<void> deleteActivity(ActivityModel activity) async {
    final confirmed = await _showDeleteConfirmation(activity.activityName);
    if (!confirmed) return;

    isDeleting.value = true;
    final response = await _repository.deleteActivity(activity.id);
    isDeleting.value = false;

    if (response.isSuccess) {
      activities.removeWhere((a) => a.id == activity.id);
      Get.snackbar(
        'deleted'.tr,
        '${activity.activityName} ${'activity_deleted'.tr}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        'error'.tr, response.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }
  int _statusPriority(String? status) {
    switch (status) {
      case 'in_progress':
        return 0;
      case 'hold':
        return 1;
      case 'done':
        return 2;
      default:
        return 3;
    }
  }

  void _sortActivities() {
    activities.sort((a, b) {
      final statusCompare =
      _statusPriority(a.status).compareTo(_statusPriority(b.status));

      if (statusCompare != 0) return statusCompare;

      return a.datetime.compareTo(b.datetime);
    });
  }

  // Confirm Delete Dialog
  Future<bool> _showDeleteConfirmation(String name) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('delete_activity'.tr),
        content: Text('${'delete_activity_confirm'.tr} "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
