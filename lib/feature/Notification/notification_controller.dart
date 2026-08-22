import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:chatter_bee/feature/Profile/controller/pro_status_controller.dart';
import 'package:chatter_bee/routes/app_routes.dart';
import 'package:chatter_bee/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String notificationType;
  bool isRead;
  final Map<String, dynamic>? data;
  final DateTime sentAt;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.notificationType,
    required this.isRead,
    this.data,
    required this.sentAt,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      notificationType: json['notification_type'] ?? 'push',
      isRead: json['is_read'] ?? false,
      data: json['data'] as Map<String, dynamic>?,
      sentAt: DateTime.parse(json['sent_at'] ?? json['created_at']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // Derive a display time string from sentAt
  String get timeString {
    final h = sentAt.toLocal().hour;
    final m = sentAt.toLocal().minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hour = h % 12 == 0 ? 12 : h % 12;
    return '$hour:$m $period';
  }

  // Helper: choose icon assets based on action / type
  String get imagePath {
    final action = data?['action'] ?? '';
    if (action.contains('hungry'))      return ImagesLink.hungryImg;
    if (action.contains('medicine') ||
        action.contains('schedule'))    return ImagesLink.textToSpeakImg;
    if (action.contains('break'))       return ImagesLink.breakImg;
    if (action.contains('help'))        return ImagesLink.helpMeImg;
    return ImagesLink.textToSpeakImg;
  }

  Color get iconBg {
    switch (notificationType) {
      case 'push':   return Colors.orange.withOpacity(0.15);
      case 'email':  return Colors.blue.withOpacity(0.15);
      case 'in_app': return Colors.green.withOpacity(0.15);
      default:       return Colors.grey.shade200;
    }
  }

  Color get iconColor {
    switch (notificationType) {
      case 'push':   return Colors.orange;
      case 'email':  return Colors.blue;
      case 'in_app': return Colors.green;
      default:       return Colors.grey.shade700;
    }
  }
}

class NotificationControllerdamo extends GetxController {
  final ApiClient _apiClient = ApiClient();

  // Pro check
  bool get _isPro => ProStatusController.to.isProUser.value;

  var buttonAlerts          = false.obs;
  var sentenceBuilderAlerts = false.obs;
  var myScheduleAlerts      = false.obs;

  var notifications = <NotificationModel>[].obs;

  var selectedTab = 0.obs;
  var isLoading   = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
    loadSettings();
  }

  // Change Tab
  void changeTab(int index) => selectedTab.value = index;

  // Loads the notification list
  Future<void> loadNotifications() async {
    isLoading.value = true;
    try {
      final response = await _apiClient.get<dynamic>('/api/notification/list/');
      if (response.isSuccess && response.data != null) {
        final List<dynamic> list = response.data['data'] ?? [];
        notifications.value =
            list.map((e) => NotificationModel.fromJson(e)).toList();
      } else {
        _showError(response.message);
      }
    } catch (e) {
      _showError('Failed to load notifications');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshNotifications() => loadNotifications();

  // Loads notification preferences
  Future<void> loadSettings() async {
    try {
      final response =
      await _apiClient.get<dynamic>('/api/notification/preferences/');
      if (response.isSuccess && response.data != null) {
        final d = response.data['data'] ?? response.data;
        buttonAlerts.value          = d['button_alerts']   ?? false;
        sentenceBuilderAlerts.value = d['sentence_alerts'] ?? false;
        myScheduleAlerts.value      = d['schedule_alerts'] ?? false;
      }
    } catch (e) {
      debugPrint('Load notification preferences error: $e');
    }
  }

  // push enabled is always true
  Future<void> _saveSettings() async {
    try {
      await _apiClient.put<dynamic>(
        '/api/notification/preferences/',
        data: {
          'push_enabled':     true,
          'button_alerts':    buttonAlerts.value,
          'sentence_alerts':  sentenceBuilderAlerts.value,
          'schedule_alerts':  myScheduleAlerts.value,
        },
      );
    } catch (e) {
      debugPrint('Save notification preferences error: $e');
    }
  }

  // Toggle helpers (pro-gated)
  void toggleButtonAlerts(bool value) {
    if (!_isPro) { _showProDialog('Button Alerts'); return; }
    buttonAlerts.value = value;
    _saveSettings();
  }

  void toggleSentenceBuilderAlerts(bool value) {
    if (!_isPro) { _showProDialog('Sentence Builder Alerts'); return; }
    sentenceBuilderAlerts.value = value;
    _saveSettings();
  }

  void toggleMyScheduleAlerts(bool value) {
    if (!_isPro) { _showProDialog('My Schedule Alerts'); return; }
    myScheduleAlerts.value = value;
    _saveSettings();
  }

  // Mark As Read
  Future<void> markAsRead(NotificationModel notification) async {
    try {
      final response = await _apiClient.post<dynamic>(
        '/api/notification/list/${notification.id}/mark_read/',
      );
      if (response.isSuccess) {
        final idx = notifications.indexWhere((n) => n.id == notification.id);
        if (idx != -1) {
          notifications[idx].isRead = true;
          notifications.refresh();
        }
      } else {
        _showError(response.message);
      }
    } catch (e) {
      _showError('Failed to mark notification as read');
    }
  }

  // Removes a notification locally
  void deleteNotification(NotificationModel notification) {
    notifications.remove(notification);
    Get.snackbar(
      'Deleted',
      '${notification.title} removed',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      mainButton: TextButton(
        onPressed: () { notifications.add(notification); Get.back(); },
        child: const Text('UNDO'),
      ),
    );
  }

  // Opens the notification detail sheet
  void onNotificationTap(NotificationModel notification) =>
      _showNotificationDialog(notification);

  void _showNotificationDialog(NotificationModel notification) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft:  Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(ImagesLink.success, height: 100),
                  const SizedBox(height: 20),

                  Text(
                    notification.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFDD268),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  Text(
                    notification.message,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF2D2D2D),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  Text(
                    'This notification will remain\nhighlighted until you mark it as read.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Color(0xFFFDD268)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Dismiss',
                            style: TextStyle(
                              color: Color(0xFFFDD268),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            Get.back();
                            await markAsRead(notification);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFDD268),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Mark as Read',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(Get.context!).padding.bottom),
                ],
              ),
            ),
          ],
        ),
      ),
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
    );
  }

  // Notifications received today
  List<NotificationModel> get todayNotifications {
    final now = DateTime.now();
    return notifications.where((n) {
      final d = n.sentAt.toLocal();
      return d.year == now.year && d.month == now.month && d.day == now.day;
    }).toList();
  }

  List<NotificationModel> get yesterdayNotifications {
    final yest = DateTime.now().subtract(const Duration(days: 1));
    return notifications.where((n) {
      final d = n.sentAt.toLocal();
      return d.year == yest.year && d.month == yest.month && d.day == yest.day;
    }).toList();
  }

  List<NotificationModel> get olderNotifications {
    final yest = DateTime.now().subtract(const Duration(days: 1));
    final cutoff = DateTime(yest.year, yest.month, yest.day);
    return notifications
        .where((n) => n.sentAt.toLocal().isBefore(cutoff))
        .toList();
  }

  // Notification Count
  int get notificationCount => notifications.length;
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  void _showError(String msg) {
    Get.snackbar('Error', msg,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3));
  }

  void _showProDialog(String featureName) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.workspace_premium, color: Colors.amber),
            SizedBox(width: 8),
            Text('Pro Required',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(
          'Upgrade to Pro to enable "$featureName".',
          style: const TextStyle(color: Color(0xFF636F85)),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed(AppRoutes.SUBSCRIPTION);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Upgrade to Pro',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
