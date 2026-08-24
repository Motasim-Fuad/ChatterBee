import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:chatter_bee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VisualSchedulesController extends GetxController {
  var scheduleItems = <ScheduleItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    print('VisualSchedulesController initialized - Instance: ${hashCode}');
    _loadScheduleItems();
  }

  void _loadScheduleItems() {
    scheduleItems.value = [
      ScheduleItemModel(
        id: '1',
        imagePath: ImagesLink.morningRoutineImg,
        title: 'Morning Routing',
        time: '8:00 AM',
        isAsset: true,
      ),
      ScheduleItemModel(
        id: '2',
        imagePath: ImagesLink.therapySessionImg,
        title: 'Therapy Session',
        time: '11:00 PM',
        isAsset: true,
      ),
      ScheduleItemModel(
        id: '3',
        imagePath: ImagesLink.afternoonSnackImg,
        title: 'Afternoon Snack',
        time: '5:00 AM',
        isAsset: true,
      ),
      ScheduleItemModel(
        id: '4',
        imagePath: ImagesLink.dinnerImg,
        title: 'Dinner',
        time: '10:00 PM',
        isAsset: true,
      ),
    ];
    print('Initial schedule items loaded: ${scheduleItems.length}');
  }

  void onScheduleMenuTap(String scheduleId) {
    print('Menu tapped for schedule: $scheduleId');
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Activity'),
        content: const Text('Are you sure you want to delete this activity?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              deleteActivity(scheduleId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> onAddActivityTap() async {
    print('Add Activity button tapped');
    print('Current controller instance: ${hashCode}');
    print('Current items count BEFORE navigation: ${scheduleItems.length}');

    final result = await Get.toNamed(AppRoutes.ADD_ACTIVITY);

    print('Returned from Add Activity screen');
    print('Current controller instance AFTER navigation: ${hashCode}');
    print('Result received: $result');
    print('Result type: ${result.runtimeType}');

    if (result != null && result is Map<String, dynamic>) {
      print('Valid result received');
      print('Activity name: ${result['name']}');
      print('⏰ Activity time: ${result['time']}');
      print('Activity image: ${result['imagePath']}');
      print('Current items count BEFORE adding: ${scheduleItems.length}');

      addActivity(
        name: result['name'],
        time: result['time'],
        imagePath: result['imagePath'],
      );

      print('Current items count AFTER adding: ${scheduleItems.length}');
    } else {
      print('No result or invalid result type');
      if (result == null) {
        print('Result is null');
      } else {
        print('Result type is: ${result.runtimeType}');
      }
    }
  }

  // On Edit Activity Tap
  Future<void> onEditActivityTap(String scheduleId) async {
    print('Edit Activity button tapped for id: $scheduleId');

    final item = scheduleItems.firstWhere((item) => item.id == scheduleId);

    print('Current controller instance: ${hashCode}');
    print('Editing: ${item.title}');

    final result = await Get.toNamed(
      AppRoutes.ADD_ACTIVITY,
      arguments: {
        'isEdit': true,
        'id': item.id,
        'name': item.title,
        'time': item.time,
        'imagePath': item.imagePath,
        'isAsset': item.isAsset,
      },
    );

    print('Returned from Edit Activity screen');
    print('Result received: $result');

    if (result != null && result is Map<String, dynamic>) {
      print('Valid result received');
      updateActivity(
        id: scheduleId,
        name: result['name'],
        time: result['time'],
        imagePath: result['imagePath'],
      );
    }
  }

  void addActivity({
    required String name,
    required String time,
    required String imagePath,
  }) {
    print('addActivity called');
    print('Controller instance: ${hashCode}');

    final newId = DateTime.now().millisecondsSinceEpoch.toString();

    final newItem = ScheduleItemModel(
      id: newId,
      imagePath: imagePath,
      title: name,
      time: time,
      isAsset: false,
    );

    print('🆕 New item created: ${newItem.toString()}');
    print('Items before insert: ${scheduleItems.length}');

    scheduleItems.insert(0, newItem);

    print('Items after insert: ${scheduleItems.length}');
    print('Activity added to list');

    Get.snackbar(
      'Success',
      'Activity added to schedule',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade900,
      duration: const Duration(seconds: 2),
    );
  }

  // Update Activity
  void updateActivity({
    required String id,
    required String name,
    required String time,
    required String imagePath,
  }) {
    print('updateActivity called for id: $id');
    print('Controller instance: ${hashCode}');

    final index = scheduleItems.indexWhere((item) => item.id == id);

    if (index != -1) {
      final oldItem = scheduleItems[index];

      final updatedItem = ScheduleItemModel(
        id: id,
        imagePath: imagePath,
        title: name,
        time: time,
        isAsset: oldItem.isAsset,
      );

      print('Updating item at index: $index');
      print('Old: ${oldItem.toString()}');
      print('New: ${updatedItem.toString()}');

      scheduleItems[index] = updatedItem;

      print('Activity updated in list');

      Get.snackbar(
        'Updated',
        'Activity updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.shade100,
        colorText: Colors.blue.shade900,
        duration: const Duration(seconds: 2),
      );
    } else {
      print('Item not found with id: $id');
    }
  }

  void deleteActivity(String id) {
    print('Delete activity called for id: $id');
    final item = scheduleItems.firstWhere((item) => item.id == id);
    scheduleItems.removeWhere((item) => item.id == id);
    print('Activity deleted: ${item.title}');
    print('Remaining items: ${scheduleItems.length}');

    Get.snackbar(
      'Deleted',
      '${item.title} removed from schedule',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange.shade100,
      colorText: Colors.orange.shade900,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void onClose() {
    print('VisualSchedulesController disposed - Instance: ${hashCode}');
    super.onClose();
  }
}

class ScheduleItemModel {
  final String id;
  final String imagePath;
  final String title;
  final String time;
  final bool isAsset;

  ScheduleItemModel({
    required this.id,
    required this.imagePath,
    required this.title,
    required this.time,
    this.isAsset = true,
  });

  @override
  String toString() {
    return 'ScheduleItemModel(id: $id, title: $title, time: $time, isAsset: $isAsset)';
  }
}
